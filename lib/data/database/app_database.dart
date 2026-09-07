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
  int get schemaVersion => 1;
}
