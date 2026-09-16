import 'package:sqflite/sqflite.dart';
import 'package:varavu_selavu/features/dashboard/data/models/monthly_config_model.dart';
import 'package:varavu_selavu/core/database/app_database.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

abstract class MonthlyConfigLocalDataSource {
  Future<MonthlyConfigModel?> getConfigForMonth(String monthKey);
  Future<void> setStartingBalance(String monthKey, double startingBalance);
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
    final model = MonthlyConfigModel(
      monthKey: monthKey,
      startingBalance: startingBalance,
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
