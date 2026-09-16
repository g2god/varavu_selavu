import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionsByMonthUseCase {
  final TransactionRepository repository;

  GetTransactionsByMonthUseCase(this.repository);

  Future<List<AppTransaction>> call(String yearMonthKey) async {
    return await repository.getTransactionsByMonth(yearMonthKey);
  }
}

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<void> call(AppTransaction transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError('Transaction amount must be greater than zero.');
    }
    await repository.addTransaction(transaction);
  }
}

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<void> call(AppTransaction transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError('Transaction amount must be greater than zero.');
    }
    await repository.updateTransaction(transaction);
  }
}

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteTransaction(id);
  }
}

class GetRecentTransactionsUseCase {
  final TransactionRepository repository;

  GetRecentTransactionsUseCase(this.repository);

  Future<List<AppTransaction>> call({int limit = 5}) async {
    return await repository.getRecentTransactions(limit: limit);
  }
}
