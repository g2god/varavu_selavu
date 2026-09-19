import 'package:varavu_selavu/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:varavu_selavu/features/transactions/data/models/transaction_model.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<AppTransaction>> getTransactionsByMonth(String yearMonthKey) async {
    return await localDataSource.getTransactionsByMonth(yearMonthKey);
  }

  @override
  Future<List<AppTransaction>> getAllTransactions() async {
    return await localDataSource.getAllTransactions();
  }

  @override
  Future<AppTransaction?> getTransactionById(String id) async {
    return await localDataSource.getTransactionById(id);
  }

  @override
  Future<void> addTransaction(AppTransaction transaction) async {
    await localDataSource.insertTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> updateTransaction(AppTransaction transaction) async {
    await localDataSource.updateTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await localDataSource.deleteTransaction(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategorySpendingByMonth(String yearMonthKey) async {
    return await localDataSource.getCategorySpendingByMonth(yearMonthKey);
  }

  @override
  Future<List<AppTransaction>> getRecentTransactions({int limit = 5}) async {
    return await localDataSource.getRecentTransactions(limit: limit);
  }

  @override
  Future<int> countTransactionsByCategoryId(String categoryId) async {
    return await localDataSource.countTransactionsByCategoryId(categoryId);
  }

  @override
  Future<void> reassignCategoryTransactions(String oldCategoryId, String newCategoryId) async {
    await localDataSource.reassignCategoryTransactions(oldCategoryId, newCategoryId);
  }
}
