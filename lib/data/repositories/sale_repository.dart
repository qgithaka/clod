import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../../core/providers/cart_provider.dart';
import '../../domain/entities/item_entity.dart';
import 'business_profile_repository.dart';

class SaleRepository {
  final AppDatabase _db;

  SaleRepository(this._db);

  Future<int> processCheckout(CartState cart, bool isCredit) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return await _db.transaction(() async {
      // 1. Insert Sale
      final saleId = await _db.saleDao.insertSale(
        SalesCompanion.insert(
          customerId: Value(cart.customer?.id),
          totalAmountCents: cart.total.cents,
          paymentMethod: isCredit ? 'credit' : 'cash',
          createdAt: now,
        ),
      );

      // 2. Insert Sale Items and Deduct Stock
      for (final line in cart.items) {
        await _db.saleDao.insertSaleItem(
          SaleItemsCompanion.insert(
            saleId: saleId,
            itemId: line.item.id,
            quantity: line.quantity,
            unitPriceCents: line.overridePrice.cents,
            totalLineCents: line.lineTotal.cents,
          ),
        );

        if (line.item.type == ItemType.product) {
          // Get current stock
          final itemRec = await _db.itemDao.getItem(line.item.id);
          if (itemRec.stockQuantity != null) {
            await _db.itemDao.updateItem(
              ItemsCompanion(
                id: Value(itemRec.id),
                stockQuantity: Value(itemRec.stockQuantity! - line.quantity),
                updatedAt: Value(now),
              ),
            );
          }
        }
      }

      // 3. If credit, record credit transaction and update customer balance
      if (isCredit && cart.customer != null) {
        final custId = cart.customer!.id;
        final custRec = await _db.customerDao.getCustomer(custId);

        // Add to debt (positive amount)
        await _db.creditTransactionDao.insertTransaction(
          CreditTransactionsCompanion.insert(
            customerId: custId,
            amountCents: cart.total.cents,
            referenceSaleId: Value(saleId),
            note: Value('Sale #$saleId'),
            createdAt: now,
          ),
        );

        // Update balance
        await _db.customerDao.updateCustomer(
          CustomersCompanion(
            id: Value(custId),
            name: Value(custRec.name),
            phone: Value(custRec.phone),
            address: Value(custRec.address),
            creditLimitCents: Value(custRec.creditLimitCents),
            currentBalanceCents: Value(
              custRec.currentBalanceCents + cart.total.cents,
            ),
            isActive: Value(custRec.isActive),
            createdAt: Value(custRec.createdAt),
            updatedAt: Value(now),
          ),
        );
      }

      return saleId;
    });
  }
}

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository(ref.watch(databaseProvider));
});
