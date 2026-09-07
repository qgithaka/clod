import 'package:drift/drift.dart';
import 'connection.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
