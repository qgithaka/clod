import '../../core/money.dart';
import '../../data/database/app_database.dart';

class CreditTransactionEntity {
  final int id;
  final int customerId;
  final int? saleId;
  final String type;
  final Money amount;
  final String? referenceNote;
  final DateTime createdAt;

  const CreditTransactionEntity({
    required this.id,
    required this.customerId,
    this.saleId,
    required this.type,
    required this.amount,
    this.referenceNote,
    required this.createdAt,
  });

  factory CreditTransactionEntity.fromData(CreditTransaction data) {
    return CreditTransactionEntity(
      id: data.id,
      customerId: data.customerId,
      saleId: data.referenceSaleId,
      type: data.amountCents > 0 ? 'CHARGE' : 'PAYMENT',
      amount: Money(data.amountCents.abs()),
      referenceNote: data.note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        data.createdAt,
        isUtc: true,
      ),
    );
  }
}
