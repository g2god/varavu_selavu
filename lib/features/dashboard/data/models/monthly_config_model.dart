import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

class MonthlyConfigModel extends MonthlyConfig {
  const MonthlyConfigModel({
    required super.monthKey,
    required super.startingBalance,
    super.budget = 0.0,
    required super.updatedAt,
  });

  factory MonthlyConfigModel.fromMap(Map<String, dynamic> map) {
    return MonthlyConfigModel(
      monthKey: map[DatabaseTables.colMonthKey] as String,
      startingBalance: (map[DatabaseTables.colStartingBalance] as num).toDouble(),
      budget: ((map[DatabaseTables.colBudget] ?? 0.0) as num).toDouble(),
      updatedAt: DateTime.parse(map[DatabaseTables.colMonthUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colMonthKey: monthKey,
      DatabaseTables.colStartingBalance: startingBalance,
      DatabaseTables.colBudget: budget,
      DatabaseTables.colMonthUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory MonthlyConfigModel.fromEntity(MonthlyConfig entity) {
    return MonthlyConfigModel(
      monthKey: entity.monthKey,
      startingBalance: entity.startingBalance,
      budget: entity.budget,
      updatedAt: entity.updatedAt,
    );
  }
}
