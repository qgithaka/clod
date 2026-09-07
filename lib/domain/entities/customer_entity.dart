import '../../core/money.dart';
import '../../data/database/app_database.dart';

class CustomerEntity {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final Money creditLimit;
  final Money currentBalance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    required this.creditLimit,
    required this.currentBalance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerEntity.fromData(Customer data) {
    return CustomerEntity(
      id: data.id,
      name: data.name,
      phone: data.phone,
      address: data.address,
      creditLimit: Money(data.creditLimitCents),
      currentBalance: Money(data.currentBalanceCents),
      isActive: data.isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        data.createdAt,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        data.updatedAt,
        isUtc: true,
      ),
    );
  }
}
