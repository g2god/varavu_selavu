import 'package:varavu_selavu/features/dashboard/data/datasources/monthly_config_local_data_source.dart';
import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:varavu_selavu/features/dashboard/domain/repositories/monthly_config_repository.dart';

class MonthlyConfigRepositoryImpl implements MonthlyConfigRepository {
  final MonthlyConfigLocalDataSource localDataSource;

  MonthlyConfigRepositoryImpl({required this.localDataSource});

  @override
  Future<MonthlyConfig?> getConfigForMonth(String monthKey) async {
    return await localDataSource.getConfigForMonth(monthKey);
  }

  @override
  Future<void> setStartingBalance(String monthKey, double startingBalance) async {
    await localDataSource.setStartingBalance(monthKey, startingBalance);
  }

  @override
  Future<void> setBudget(String monthKey, double budget) async {
    await localDataSource.setBudget(monthKey, budget);
  }

  @override
  Future<List<MonthlyConfig>> getAllConfigs() async {
    return await localDataSource.getAllConfigs();
  }
}
