import 'package:drift/drift.dart';
import 'app_database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [BusinessProfile])
class BusinessProfileDao extends DatabaseAccessor<AppDatabase> with _$BusinessProfileDaoMixin {
  BusinessProfileDao(super.db);

  Stream<BusinessProfileData?> watchProfile() => (select(businessProfile)..limit(1)).watchSingleOrNull();
  Future<BusinessProfileData?> getProfile() => (select(businessProfile)..limit(1)).getSingleOrNull();
  Future<int> insertOrUpdate(BusinessProfileCompanion profile) => into(businessProfile).insertOnConflictUpdate(profile);
}

@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase> with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Stream<List<Customer>> watchAllCustomers() => select(customers).watch();
  Future<List<Customer>> getAllCustomers() => select(customers).get();
  Future<Customer> getCustomer(int id) => (select(customers)..where((c) => c.id.equals(id))).getSingle();
  Future<int> insertCustomer(CustomersCompanion customer) => into(customers).insert(customer);
  Future<bool> updateCustomer(CustomersCompanion customer) => update(customers).replace(customer);
  Future<int> deleteCustomer(int id) => (delete(customers)..where((c) => c.id.equals(id))).go();
}

@DriftAccessor(tables: [Items])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  Stream<List<Item>> watchAllItems() => select(items).watch();
  Stream<List<Item>> watchAllActiveItems() => (select(items)..where((i) => i.isActive.equals(true))).watch();
  Future<List<Item>> getAllItems() => select(items).get();
  Future<Item> getItem(int id) => (select(items)..where((i) => i.id.equals(id))).getSingle();
  Future<int> insertItem(ItemsCompanion item) => into(items).insert(item);
  Future<bool> updateItem(ItemsCompanion item) => update(items).replace(item);
}

@DriftAccessor(tables: [Sales, SaleItems])
class SaleDao extends DatabaseAccessor<AppDatabase> with _$SaleDaoMixin {
  SaleDao(super.db);

  Stream<List<Sale>> watchAllSales() => select(sales).watch();
  Future<int> insertSale(SalesCompanion sale) => into(sales).insert(sale);
  Future<int> insertSaleItem(SaleItemsCompanion saleItem) => into(saleItems).insert(saleItem);
}

@DriftAccessor(tables: [CreditTransactions])
class CreditTransactionDao extends DatabaseAccessor<AppDatabase> with _$CreditTransactionDaoMixin {
  CreditTransactionDao(super.db);

  Stream<List<CreditTransaction>> watchTransactionsForCustomer(int customerId) {
    return (select(creditTransactions)..where((t) => t.customerId.equals(customerId))).watch();
  }
  Future<int> insertTransaction(CreditTransactionsCompanion txn) => into(creditTransactions).insert(txn);
}

@DriftAccessor(tables: [Purchases, PurchaseItems])
class PurchaseDao extends DatabaseAccessor<AppDatabase> with _$PurchaseDaoMixin {
  PurchaseDao(super.db);

  Stream<List<Purchase>> watchAllPurchases() => select(purchases).watch();
  Future<int> insertPurchase(PurchasesCompanion purchase) => into(purchases).insert(purchase);
}

@DriftAccessor(tables: [StockMovements])
class StockMovementDao extends DatabaseAccessor<AppDatabase> with _$StockMovementDaoMixin {
  StockMovementDao(super.db);

  Stream<List<StockMovement>> watchMovementsForItem(int itemId) {
    return (select(stockMovements)..where((m) => m.itemId.equals(itemId))).watch();
  }
  Future<int> insertMovement(StockMovementsCompanion movement) => into(stockMovements).insert(movement);
}

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase> with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();
  Future<int> insertExpense(ExpensesCompanion expense) => into(expenses).insert(expense);
}

@DriftAccessor(tables: [Documents])
class DocumentDao extends DatabaseAccessor<AppDatabase> with _$DocumentDaoMixin {
  DocumentDao(super.db);

  Stream<List<Document>> watchAllDocuments() => select(documents).watch();
  Future<int> insertDocument(DocumentsCompanion doc) => into(documents).insert(doc);
}
