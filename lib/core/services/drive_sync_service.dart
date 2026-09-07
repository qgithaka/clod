import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final driveSyncServiceProvider = Provider<DriveSyncService>((ref) {
  return DriveSyncService();
});

class MockUser {
  final String email = 'user@example.com';
}

class MockDriveFile {
  final String? id;
  final String? name;
  MockDriveFile({this.id, this.name});
}

class DriveSyncService {
  MockUser? _currentUser;

  MockUser? get currentUser => _currentUser;

  Future<MockUser?> signIn() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = MockUser();
    return _currentUser;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  Future<void> uploadBackup(File backupFile) async {
    if (_currentUser == null) throw Exception('User not signed in');
    await Future.delayed(const Duration(seconds: 2));
    print('Mock uploaded ${backupFile.path} to Drive');
  }

  Future<List<MockDriveFile>> listBackups() async {
    if (_currentUser == null) throw Exception('User not signed in');
    await Future.delayed(const Duration(seconds: 1));
    return [MockDriveFile(id: 'mock-1', name: 'ClodBackup_mock.clodbackup')];
  }

  Future<File> downloadBackup(MockDriveFile file) async {
    if (_currentUser == null) throw Exception('User not signed in');
    throw Exception('Mock download not implemented for real restores');
  }
}
