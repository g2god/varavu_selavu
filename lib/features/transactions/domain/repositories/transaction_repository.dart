import '../../domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<AppTransaction>> getTransactionsByMonth(String yearMonthKey);
  Future<List<AppTransaction>> getAllTransactions();
  Future<AppTransaction?> getTransactionById(String id);
  Future<void> addTransaction(AppTransaction transaction);
  Future<void> updateTransaction(AppTransaction transaction);
  Future<void> deleteTransaction(String id);
  Future<List<Map<String, dynamic>>> getCategorySpendingByMonth(String yearMonthKey);
  Future<List<AppTransaction>> getRecentTransactions({int limit = 5});
  Future<int> countTransactionsByCategoryId(String categoryId);
  Future<void> reassignCategoryTransactions(String oldCategoryId, String newCategoryId);
}
