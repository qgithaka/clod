import 'package:drift/drift.dart';

class BusinessProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get logoPath => text().nullable()();
  IntColumn get updatedAt => integer()();
}

@TableIndex(name: 'customer_name_idx', columns: {#name})
@TableIndex(name: 'customer_is_active_idx', columns: {#isActive})
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  IntColumn get creditLimitCents => integer().withDefault(const Constant(0))();
  IntColumn get currentBalanceCents =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

@TableIndex(name: 'item_name_idx', columns: {#name})
@TableIndex(name: 'item_type_idx', columns: {#type})
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'product' or 'service'
  IntColumn get sellingPriceCents => integer()();
  IntColumn get buyingPriceCents => integer().nullable()();
  IntColumn get stockQuantity => integer().nullable()();
  IntColumn get lowStockThreshold => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

@TableIndex(name: 'sales_created_at_idx', columns: {#createdAt})
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get totalAmountCents => integer()();
  TextColumn get paymentMethod => text()(); // 'cash' or 'credit'
  IntColumn get createdAt => integer()();
}

@TableIndex(name: 'sale_items_sale_id_idx', columns: {#saleId})
@TableIndex(name: 'sale_items_item_id_idx', columns: {#itemId})
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get itemId => integer().references(Items, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get totalLineCents => integer()();
}

@TableIndex(name: 'credit_tx_customer_id_idx', columns: {#customerId})
@TableIndex(name: 'credit_tx_created_at_idx', columns: {#createdAt})
class CreditTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get amountCents =>
      integer()(); // Positive for debt (sale), negative for repayment
  IntColumn get referenceSaleId =>
      integer().nullable().references(Sales, #id)();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
}

class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get status => text()(); // 'draft', 'ordered', 'received'
  IntColumn get totalAmountCents => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get receivedAt => integer().nullable()();
}

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer().references(Purchases, #id)();
  IntColumn get itemId => integer().references(Items, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitCostCents => integer()();
}

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  IntColumn get quantityChange => integer()(); // positive or negative
  TextColumn get reason => text()(); // 'sale', 'purchase', 'damaged', 'expired', 'lost', 'adjustment'
  IntColumn get referenceId => integer().nullable()(); // sale_id or purchase_id
  IntColumn get createdAt => integer()();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  IntColumn get amountCents => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get occurredAt => integer()();
  IntColumn get createdAt => integer()();
}

class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'quote' or 'invoice'
  TextColumn get status =>
      text()(); // 'draft', 'sent', 'accepted', 'paid', 'cancelled'
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get totalAmountCents => integer()();
  TextColumn get contentJson => text()(); // serialized line items
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class BackupLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get status => text()(); // 'success', 'failed'
  IntColumn get createdAt => integer()();
}
