import 'package:sqflite/sqflite.dart';
import 'package:varavu_selavu/features/dashboard/data/models/monthly_config_model.dart';
import 'package:varavu_selavu/core/database/app_database.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

abstract class MonthlyConfigLocalDataSource {
  Future<MonthlyConfigModel?> getConfigForMonth(String monthKey);
  Future<void> setStartingBalance(String monthKey, double startingBalance);
  Future<void> setBudget(String monthKey, double budget);
  Future<List<MonthlyConfigModel>> getAllConfigs();
}

class MonthlyConfigLocalDataSourceImpl implements MonthlyConfigLocalDataSource {
  final AppDatabase appDatabase;

  MonthlyConfigLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<MonthlyConfigModel?> getConfigForMonth(String monthKey) async {
    final db = await appDatabase.database;
    final results = await db.query(
      DatabaseTables.monthlyConfigs,
      where: '${DatabaseTables.colMonthKey} = ?',
      whereArgs: [monthKey],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return MonthlyConfigModel.fromMap(results.first);
  }

  @override
  Future<void> setStartingBalance(String monthKey, double startingBalance) async {
    final db = await appDatabase.database;
    final existing = await getConfigForMonth(monthKey);
    final model = MonthlyConfigModel(
      monthKey: monthKey,
      startingBalance: startingBalance,
      budget: existing?.budget ?? 0.0,
      updatedAt: DateTime.now(),
    );
    await db.insert(
      DatabaseTables.monthlyConfigs,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> setBudget(String monthKey, double budget) async {
    final db = await appDatabase.database;
    final existing = await getConfigForMonth(monthKey);
    final model = MonthlyConfigModel(
      monthKey: monthKey,
      startingBalance: existing?.startingBalance ?? 0.0,
      budget: budget,
      updatedAt: DateTime.now(),
    );
    await db.insert(
      DatabaseTables.monthlyConfigs,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<MonthlyConfigModel>> getAllConfigs() async {
    final db = await appDatabase.database;
    final results = await db.query(
      DatabaseTables.monthlyConfigs,
      orderBy: '${DatabaseTables.colMonthKey} DESC',
    );
    return results.map((m) => MonthlyConfigModel.fromMap(m)).toList();
  }
}
