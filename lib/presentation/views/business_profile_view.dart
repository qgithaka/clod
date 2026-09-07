import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/app_database.dart';
import '../../data/repositories/business_profile_repository.dart';
import '../../core/services/file_storage_service.dart';

class BusinessProfileView extends ConsumerStatefulWidget {
  const BusinessProfileView({super.key});

  @override
  ConsumerState<BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends ConsumerState<BusinessProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _currencyCode = 'USD';
  String? _logoPath;

  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final storage = ref.read(fileStorageServiceProvider);
      final newPath = await storage.saveLogo(file.path);
      setState(() {
        _logoPath = newPath;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(businessProfileRepositoryProvider);
      await repo.saveProfile(BusinessProfileCompanion(
        id: const drift.Value(1),
        name: drift.Value(_nameController.text),
        phone: drift.Value(_phoneController.text),
        address: drift.Value(_addressController.text),
        currencyCode: drift.Value(_currencyCode),
        logoPath: drift.Value(_logoPath),
        updatedAt: drift.Value(DateTime.now().toUtc().millisecondsSinceEpoch),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Business Profile')),
      body: profileAsync.when(
        data: (profile) {
          if (!_isInitialized) {
            _nameController.text = profile?.name ?? '';
            _phoneController.text = profile?.phone ?? '';
            _addressController.text = profile?.address ?? '';
            _currencyCode = profile?.currencyCode ?? 'USD';
            _logoPath = profile?.logoPath;
            _isInitialized = true;
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickLogo,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _logoPath != null ? FileImage(File(_logoPath!)) : null,
                        child: _logoPath == null ? const Icon(Icons.add_a_photo, size: 30) : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text('Tap to change logo')),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _currencyCode,
                    decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      DropdownMenuItem(value: 'KES', child: Text('KES')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _currencyCode = v);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
                  )
                ],
              ),
            ),
            ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
