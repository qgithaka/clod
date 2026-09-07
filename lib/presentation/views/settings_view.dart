import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/backup_service.dart';
import '../../core/services/drive_sync_service.dart';

import 'package:go_router/go_router.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _isSyncing = false;
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleBackup() async {
    final pwd = await _showPasswordDialog(
      'Enter encryption password for backup',
    );
    if (pwd == null || pwd.isEmpty) return;

    setState(() => _isSyncing = true);
    try {
      final backupSvc = await ref.read(backupServiceProvider.future);
      final file = await backupSvc.createBackup(pwd);

      final driveSvc = ref.read(driveSyncServiceProvider);
      if (driveSvc.currentUser != null) {
        await driveSvc.uploadBackup(file);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully at ${file.path}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _handleRestore() async {
    final driveSvc = ref.read(driveSyncServiceProvider);

    // Simplification for the UI: We will just try to download the latest backup from drive if signed in
    if (driveSvc.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to Drive to restore backups.'),
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);
    try {
      final files = await driveSvc.listBackups();
      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No backups found in Drive.')),
          );
        }
        return;
      }

      final fileToRestore = files.first; // Restore newest
      final localFile = await driveSvc.downloadBackup(fileToRestore);

      if (mounted) {
        final pwd = await _showPasswordDialog(
          'Enter password to decrypt backup',
        );
        if (pwd == null || pwd.isEmpty) return;

        final backupSvc = await ref.read(backupServiceProvider.future);
        await backupSvc.restoreBackup(localFile, pwd);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restore successful! Restart app to see changes.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<String?> _showPasswordDialog(String title) {
    _passwordController.clear();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password (min 8 chars)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, _passwordController.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driveSvc = ref.watch(driveSyncServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Business Profile'),
            subtitle: const Text(
              'Update name, logo, address, and receipt message',
            ),
            onTap: () => context.go(
              '/settings/business_profile',
            ), // Assuming we use dashboard as root or separate
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Data & Backups',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Google Drive Sync'),
            subtitle: Text(
              driveSvc.currentUser == null
                  ? 'Not signed in'
                  : 'Signed in as ${driveSvc.currentUser!.email}',
            ),
            trailing: _isSyncing ? const CircularProgressIndicator() : null,
            onTap: () async {
              if (driveSvc.currentUser == null) {
                await driveSvc.signIn();
                setState(() {});
              } else {
                await driveSvc.signOut();
                setState(() {});
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.schedule),
            title: const Text('Auto-Backup Daily'),
            subtitle: const Text('Automatically backup at midnight'),
            value: false,
            onChanged: (v) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Auto-backup scheduling is not implemented in this milestone.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Create Encrypted Backup'),
            subtitle: const Text('Save a local .clodbackup and sync to Drive'),
            onTap: _isSyncing ? null : _handleBackup,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore from Drive'),
            subtitle: const Text('Download and restore the latest backup'),
            onTap: _isSyncing ? null : _handleRestore,
          ),
        ],
      ),
    );
  }
}
