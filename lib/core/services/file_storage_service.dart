import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileStorageService {
  Future<String> saveLogo(String sourceFilePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final clodDir = Directory(p.join(docsDir.path, 'clod', 'logos'));
    if (!await clodDir.exists()) {
      await clodDir.create(recursive: true);
    }

    final extension = p.extension(sourceFilePath);
    final fileName =
        'business_logo_${DateTime.now().millisecondsSinceEpoch}$extension';
    final targetPath = p.join(clodDir.path, fileName);

    final sourceFile = File(sourceFilePath);
    await sourceFile.copy(targetPath);

    return targetPath;
  }
}

final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  return FileStorageService();
});
