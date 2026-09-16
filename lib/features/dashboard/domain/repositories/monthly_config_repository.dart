import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';

abstract class MonthlyConfigRepository {
  Future<MonthlyConfig?> getConfigForMonth(String monthKey);
  Future<void> setStartingBalance(String monthKey, double startingBalance);
  Future<List<MonthlyConfig>> getAllConfigs();
}
