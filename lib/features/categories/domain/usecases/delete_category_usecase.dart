import 'package:varavu_selavu/features/categories/domain/repositories/category_repository.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;

  DeleteCategoryUseCase({
    required this.categoryRepository,
    required this.transactionRepository,
  });

  Future<int> getTransactionCount(String categoryId) async {
    return await transactionRepository.countTransactionsByCategoryId(categoryId);
  }

  Future<void> call({
    required String categoryId,
    String? fallbackCategoryId,
  }) async {
    // If fallback category is provided, migrate any existing transactions first
    if (fallbackCategoryId != null) {
      await transactionRepository.reassignCategoryTransactions(categoryId, fallbackCategoryId);
    }

    // Delete category
    await categoryRepository.deleteCategory(categoryId);
  }
}
