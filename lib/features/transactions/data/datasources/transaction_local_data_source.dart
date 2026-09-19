import 'package:varavu_selavu/features/transactions/data/models/transaction_model.dart';
import 'package:varavu_selavu/core/database/app_database.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactionsByMonth(String yearMonthKey);
  Future<List<TransactionModel>> getAllTransactions();
  Future<TransactionModel?> getTransactionById(String id);
  Future<void> insertTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<Map<String, dynamic>>> getCategorySpendingByMonth(String yearMonthKey);
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5});
  Future<int> countTransactionsByCategoryId(String categoryId);
  Future<void> reassignCategoryTransactions(String oldCategoryId, String newCategoryId);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final AppDatabase appDatabase;

  TransactionLocalDataSourceImpl({required this.appDatabase});

  String get _selectWithCategorySql => '''
    SELECT 
      t.${DatabaseTables.colTxId},
      t.${DatabaseTables.colTxType},
      t.${DatabaseTables.colTxAmount},
      t.${DatabaseTables.colTxCategoryId},
      t.${DatabaseTables.colTxDate},
      t.${DatabaseTables.colTxNote},
      t.${DatabaseTables.colTxCreatedAt},
      t.${DatabaseTables.colTxUpdatedAt},
      c.${DatabaseTables.colCatName} AS category_name,
      c.${DatabaseTables.colCatIcon} AS category_icon,
      c.${DatabaseTables.colCatColor} AS category_color
    FROM ${DatabaseTables.transactions} t
    LEFT JOIN ${DatabaseTables.categories} c 
      ON t.${DatabaseTables.colTxCategoryId} = c.${DatabaseTables.colCatId}
  ''';

  @override
  Future<List<TransactionModel>> getTransactionsByMonth(String yearMonthKey) async {
    final db = await appDatabase.database;
    final results = await db.rawQuery(
      '''
      $_selectWithCategorySql
      WHERE t.${DatabaseTables.colTxDate} LIKE ?
      ORDER BY t.${DatabaseTables.colTxDate} DESC, t.${DatabaseTables.colTxCreatedAt} DESC
      ''',
      ['$yearMonthKey%'],
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await appDatabase.database;
    final results = await db.rawQuery(
      '''
      $_selectWithCategorySql
      ORDER BY t.${DatabaseTables.colTxDate} DESC, t.${DatabaseTables.colTxCreatedAt} DESC
      ''',
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final db = await appDatabase.database;
    final results = await db.rawQuery(
      '''
      $_selectWithCategorySql
      WHERE t.${DatabaseTables.colTxId} = ?
      LIMIT 1
      ''',
      [id],
    );
    if (results.isEmpty) return null;
    return TransactionModel.fromMap(results.first);
  }

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await appDatabase.database;
    await db.insert(
      DatabaseTables.transactions,
      transaction.toMap(),
    );
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await appDatabase.database;
    await db.update(
      DatabaseTables.transactions,
      transaction.toMap(),
      where: '${DatabaseTables.colTxId} = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await appDatabase.database;
    await db.delete(
      DatabaseTables.transactions,
      where: '${DatabaseTables.colTxId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCategorySpendingByMonth(String yearMonthKey) async {
    final db = await appDatabase.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        c.${DatabaseTables.colCatId} AS category_id,
        c.${DatabaseTables.colCatName} AS category_name,
        c.${DatabaseTables.colCatIcon} AS category_icon,
        c.${DatabaseTables.colCatColor} AS category_color,
        SUM(t.${DatabaseTables.colTxAmount}) AS total_amount,
        COUNT(t.${DatabaseTables.colTxId}) AS transaction_count
      FROM ${DatabaseTables.transactions} t
      JOIN ${DatabaseTables.categories} c 
        ON t.${DatabaseTables.colTxCategoryId} = c.${DatabaseTables.colCatId}
      WHERE t.${DatabaseTables.colTxType} = 'expense'
        AND t.${DatabaseTables.colTxDate} LIKE ?
      GROUP BY c.${DatabaseTables.colCatId}
      ORDER BY total_amount DESC
      ''',
      ['$yearMonthKey%'],
    );
    return results;
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final db = await appDatabase.database;
    final results = await db.rawQuery(
      '''
      $_selectWithCategorySql
      ORDER BY t.${DatabaseTables.colTxDate} DESC, t.${DatabaseTables.colTxCreatedAt} DESC
      LIMIT ?
      ''',
      [limit],
    );
    return results.map((map) => TransactionModel.fromMap(map)).toList();
  }

  @override
  Future<int> countTransactionsByCategoryId(String categoryId) async {
    final db = await appDatabase.database;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.transactions} WHERE ${DatabaseTables.colTxCategoryId} = ?',
      [categoryId],
    );
    if (results.isNotEmpty) {
      return (results.first['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  @override
  Future<void> reassignCategoryTransactions(String oldCategoryId, String newCategoryId) async {
    final db = await appDatabase.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      DatabaseTables.transactions,
      {
        DatabaseTables.colTxCategoryId: newCategoryId,
        DatabaseTables.colTxUpdatedAt: now,
      },
      where: '${DatabaseTables.colTxCategoryId} = ?',
      whereArgs: [oldCategoryId],
    );
  }
}
