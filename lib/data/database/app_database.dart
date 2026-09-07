import 'package:drift/drift.dart';
import 'connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
