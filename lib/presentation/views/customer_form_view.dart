import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/money.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerFormView extends ConsumerStatefulWidget {
  final String? customerId;
  const CustomerFormView({super.key, this.customerId});

  @override
  ConsumerState<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends ConsumerState<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _creditLimitController = TextEditingController();

  CustomerEntity? _existingCustomer;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  void _init(List<CustomerEntity> customers) {
    if (_isInitialized) return;
    if (widget.customerId != null && widget.customerId != 'new') {
      final id = int.tryParse(widget.customerId!);
      if (id != null) {
        _existingCustomer = customers.where((c) => c.id == id).firstOrNull;
        if (_existingCustomer != null) {
          _nameController.text = _existingCustomer!.name;
          _phoneController.text = _existingCustomer!.phone ?? '';
          _addressController.text = _existingCustomer!.address ?? '';
          _creditLimitController.text = _existingCustomer!.creditLimit.asDouble.toString();
        }
      }
    }
    _isInitialized = true;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(customerRepositoryProvider);
      final limit = Money.fromDouble(double.tryParse(_creditLimitController.text) ?? 0);
      
      if (_existingCustomer == null) {
        await repo.addCustomer(
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          creditLimit: limit,
        );
      } else {
        await repo.updateCustomer(
          _existingCustomer!.id,
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          creditLimit: limit,
          isActive: _existingCustomer!.isActive,
          currentBalance: _existingCustomer!.currentBalance,
          createdAt: _existingCustomer!.createdAt,
        );
      }
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.customerId == 'new' ? 'New Customer' : 'Edit Customer')),
      body: customersAsync.when(
        data: (customers) {
          _init(customers);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _creditLimitController,
                    decoration: const InputDecoration(labelText: 'Credit Limit', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save Customer'),
                    ),
                  )
                ],
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
