import 'package:drift/drift.dart';

import 'connection.dart';
import 'daos.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    BusinessProfile,
    Customers,
    Items,
    Sales,
    SaleItems,
    CreditTransactions,
    Purchases,
    PurchaseItems,
    StockMovements,
    Expenses,
    Documents,
    AppSettings,
    BackupLogs,
  ],
  daos: [
    BusinessProfileDao,
    CustomerDao,
    ItemDao,
    SaleDao,
    CreditTransactionDao,
    PurchaseDao,
    StockMovementDao,
    ExpenseDao,
    DocumentDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Create newly added indexes
          await m.createIndex(customerNameIdx);
          await m.createIndex(customerIsActiveIdx);
          await m.createIndex(itemNameIdx);
          await m.createIndex(itemTypeIdx);
          await m.createIndex(salesCreatedAtIdx);
          await m.createIndex(saleItemsSaleIdIdx);
          await m.createIndex(saleItemsItemIdIdx);
          await m.createIndex(creditTxCustomerIdIdx);
          await m.createIndex(creditTxCreatedAtIdx);
        }
      },
    );
  }
}
