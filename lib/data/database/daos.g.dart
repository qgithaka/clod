// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$BusinessProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessProfileTable get businessProfile => attachedDatabase.businessProfile;
  BusinessProfileDaoManager get managers => BusinessProfileDaoManager(this);
}

class BusinessProfileDaoManager {
  final _$BusinessProfileDaoMixin _db;
  BusinessProfileDaoManager(this._db);
  $$BusinessProfileTableTableManager get businessProfile =>
      $$BusinessProfileTableTableManager(
        _db.attachedDatabase,
        _db.businessProfile,
      );
}

mixin _$CustomerDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  CustomerDaoManager get managers => CustomerDaoManager(this);
}

class CustomerDaoManager {
  final _$CustomerDaoMixin _db;
  CustomerDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
}

mixin _$ItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  ItemDaoManager get managers => ItemDaoManager(this);
}

class ItemDaoManager {
  final _$ItemDaoMixin _db;
  ItemDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
}

mixin _$SaleDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $SalesTable get sales => attachedDatabase.sales;
  $ItemsTable get items => attachedDatabase.items;
  $SaleItemsTable get saleItems => attachedDatabase.saleItems;
  SaleDaoManager get managers => SaleDaoManager(this);
}

class SaleDaoManager {
  final _$SaleDaoMixin _db;
  SaleDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db.attachedDatabase, _db.sales);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db.attachedDatabase, _db.saleItems);
}

mixin _$CreditTransactionDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $SalesTable get sales => attachedDatabase.sales;
  $CreditTransactionsTable get creditTransactions =>
      attachedDatabase.creditTransactions;
  CreditTransactionDaoManager get managers => CreditTransactionDaoManager(this);
}

class CreditTransactionDaoManager {
  final _$CreditTransactionDaoMixin _db;
  CreditTransactionDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db.attachedDatabase, _db.sales);
  $$CreditTransactionsTableTableManager get creditTransactions =>
      $$CreditTransactionsTableTableManager(
        _db.attachedDatabase,
        _db.creditTransactions,
      );
}

mixin _$PurchaseDaoMixin on DatabaseAccessor<AppDatabase> {
  $PurchasesTable get purchases => attachedDatabase.purchases;
  $ItemsTable get items => attachedDatabase.items;
  $PurchaseItemsTable get purchaseItems => attachedDatabase.purchaseItems;
  PurchaseDaoManager get managers => PurchaseDaoManager(this);
}

class PurchaseDaoManager {
  final _$PurchaseDaoMixin _db;
  PurchaseDaoManager(this._db);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db.attachedDatabase, _db.purchases);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$PurchaseItemsTableTableManager get purchaseItems =>
      $$PurchaseItemsTableTableManager(_db.attachedDatabase, _db.purchaseItems);
}

mixin _$StockMovementDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  StockMovementDaoManager get managers => StockMovementDaoManager(this);
}

class StockMovementDaoManager {
  final _$StockMovementDaoMixin _db;
  StockMovementDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
        _db.attachedDatabase,
        _db.stockMovements,
      );
}

mixin _$ExpenseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExpensesTable get expenses => attachedDatabase.expenses;
  ExpenseDaoManager get managers => ExpenseDaoManager(this);
}

class ExpenseDaoManager {
  final _$ExpenseDaoMixin _db;
  ExpenseDaoManager(this._db);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
}

mixin _$DocumentDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $DocumentsTable get documents => attachedDatabase.documents;
  DocumentDaoManager get managers => DocumentDaoManager(this);
}

class DocumentDaoManager {
  final _$DocumentDaoMixin _db;
  DocumentDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db.attachedDatabase, _db.documents);
}
