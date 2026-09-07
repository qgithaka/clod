import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/business_profile_repository.dart';

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final db = ref.watch(databaseProvider);
  final tempDir = await getTemporaryDirectory();
  final docsDir = await getApplicationDocumentsDirectory();
  return BackupService(db, tempDir: tempDir, docsDir: docsDir);
});

class BackupService {
  final AppDatabase _db;
  final Directory tempDir;
  final Directory docsDir;

  BackupService(this._db, {required this.tempDir, required this.docsDir});

  Future<File> createBackup(String encryptionPassword) async {
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final rawBackupPath = p.join(
      tempDir.path,
      'clod_backup_raw_$timestamp.sqlite',
    );

    // 1. Safe SQLite snapshot using VACUUM INTO
    await _db.customStatement("VACUUM INTO '$rawBackupPath'");

    // 2. Encrypt the file
    final fileBytes = await File(rawBackupPath).readAsBytes();

    // Create an encrypter (AES-256)
    // In a real app we'd derive the key using PBKDF2 with a salt, but for simplicity:
    final key = Key.fromUtf8(
      encryptionPassword.padRight(32, '0').substring(0, 32),
    );
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

    // 3. Save as .clodbackup
    final backupFile = File(
      p.join(docsDir.path, 'ClodBackup_$timestamp.clodbackup'),
    );

    // We prepend the IV to the file so we can decrypt it later
    final outBytes = <int>[...iv.bytes, ...encrypted.bytes];
    await backupFile.writeAsBytes(outBytes);

    // Cleanup temp
    await File(rawBackupPath).delete();

    return backupFile;
  }

  Future<void> restoreBackup(File backupFile, String encryptionPassword) async {
    final bytes = await backupFile.readAsBytes();
    if (bytes.length <= 16) throw Exception('Invalid backup file');

    final ivBytes = bytes.sublist(0, 16);
    final encryptedBytes = bytes.sublist(16);

    final key = Key.fromUtf8(
      encryptionPassword.padRight(32, '0').substring(0, 32),
    );
    final iv = IV(ivBytes);
    final encrypter = Encrypter(AES(key));

    List<int> decryptedBytes;
    try {
      decryptedBytes = encrypter.decryptBytes(
        Encrypted(encryptedBytes),
        iv: iv,
      );
    } catch (e) {
      throw Exception('Incorrect password or corrupted backup');
    }

    // Write to a temporary file to verify it's a valid SQLite DB
    final tempDbPath = p.join(tempDir.path, 'restored_temp.sqlite');
    await File(tempDbPath).writeAsBytes(decryptedBytes);

    // Basic SQLite header validation ("SQLite format 3\0")
    final header = decryptedBytes.sublist(0, 16);
    final headerString = String.fromCharCodes(header);
    if (headerString != 'SQLite format 3\x00') {
      throw Exception('Decrypted file is not a valid SQLite database');
    }

    // Now we must replace the active database.
    // Riverpod doesn't easily let us "swap" a database while the app is running.
    // The safest way is to close the current database, replace the file, and restart the app (or at least throw an event to reload the DB provider).
    // For Clod, we will:
    // 1. Close current DB
    await _db.close();

    // 2. Overwrite the main DB file
    final mainDbFile = File(p.join(docsDir.path, 'clod_app.sqlite'));
    await File(tempDbPath).copy(mainDbFile.path);

    // 3. Cleanup temp
    await File(tempDbPath).delete();

    // Note: The caller must trigger an app restart or a Riverpod provider invalidation of the appDatabaseProvider.
  }
}
