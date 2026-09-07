import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/daos.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final businessProfileDaoProvider = Provider<BusinessProfileDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.businessProfileDao;
});

final businessProfileProvider = StreamProvider<BusinessProfileData?>((ref) {
  final dao = ref.watch(businessProfileDaoProvider);
  return dao.watchProfile();
});

class BusinessProfileRepository {
  final BusinessProfileDao _dao;

  BusinessProfileRepository(this._dao);

  Future<void> saveProfile(BusinessProfileCompanion profile) async {
    await _dao.insertOrUpdate(profile);
  }
}

final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>((ref) {
  final dao = ref.watch(businessProfileDaoProvider);
  return BusinessProfileRepository(dao);
});
