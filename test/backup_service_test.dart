import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:clod/core/services/backup_service.dart';
import 'package:clod/data/database/app_database.dart';

void main() {
  late AppDatabase db;
  late BackupService backupService;
  late File dbFile;

  setUp(() async {
    // Need a real file-based DB for VACUUM INTO to work, memory DB doesn't support VACUUM INTO a file easily.
    final temp = await Directory.systemTemp.createTemp();
    dbFile = File(p.join(temp.path, 'clod_app.sqlite'));
    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    backupService = BackupService(db, tempDir: temp, docsDir: temp);

    // Insert some data to verify
    await db.into(db.businessProfile).insert(
      BusinessProfileCompanion.insert(
        name: 'My Business',
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      )
    );
  });

  tearDown(() async {
    await db.close();
    if (dbFile.existsSync()) {
      dbFile.deleteSync();
    }
  });

  test('createBackup and restoreBackup flow', () async {
    // 1. Create Backup
    final backupFile = await backupService.createBackup('supersecret123');
    expect(backupFile.existsSync(), isTrue);

    // 2. Corrupt or change current DB to prove restore works
    await db.into(db.businessProfile).insert(
      BusinessProfileCompanion.insert(
        name: 'Hacked Business',
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      )
    );
    final countBeforeRestore = await db.select(db.businessProfile).get();
    expect(countBeforeRestore.length, 2);

    // 3. Restore Backup
    await backupService.restoreBackup(backupFile, 'supersecret123');

    // 4. Re-open DB and verify (since restoreBackup closes it)
    final restoredDb = AppDatabase.forTesting(NativeDatabase(dbFile));
    final profiles = await restoredDb.select(restoredDb.businessProfile).get();
    
    expect(profiles.length, 1);
    expect(profiles.first.name, 'My Business');

    await restoredDb.close();
    backupFile.deleteSync();
  });

  test('restoreBackup throws on wrong password', () async {
    final backupFile = await backupService.createBackup('supersecret123');
    
    expect(
      () => backupService.restoreBackup(backupFile, 'wrongpassword123'),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Incorrect password'))),
    );
  });
}
