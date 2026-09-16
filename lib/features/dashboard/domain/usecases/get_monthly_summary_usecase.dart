import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:varavu_selavu/features/dashboard/domain/repositories/monthly_config_repository.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';

class GetMonthlySummaryUseCase {
  final TransactionRepository transactionRepository;
  final MonthlyConfigRepository monthlyConfigRepository;

  GetMonthlySummaryUseCase({
    required this.transactionRepository,
    required this.monthlyConfigRepository,
  });

  Future<MonthlySummary> call(String yearMonthKey) async {
    // 1. Fetch transactions for month
    final transactions = await transactionRepository.getTransactionsByMonth(yearMonthKey);

    // 2. Fetch starting balance configuration for this month
    final config = await monthlyConfigRepository.getConfigForMonth(yearMonthKey);
    final startingBalance = config?.startingBalance ?? 0.0;
    final budget = config?.budget ?? 0.0;

    // 3. Derive total income and total expense strictly from transactions
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    // Available Balance = Starting Balance + Money Added - Expenses
    final availableBalance = startingBalance + totalIncome - totalExpense;

    // 4. Fetch category spendings breakdown
    final rawCategorySpendings = await transactionRepository.getCategorySpendingByMonth(yearMonthKey);
    final categorySpendings = rawCategorySpendings.map((raw) {
      final amount = (raw['total_amount'] as num).toDouble();
      final percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0.0;
      return CategorySpending(
        categoryId: raw['category_id'] as String,
        categoryName: raw['category_name'] as String? ?? 'Other',
        categoryIcon: raw['category_icon'] as String? ?? 'more_horiz',
        categoryColor: (raw['category_color'] as int?) ?? 0xFF64748B,
        totalAmount: amount,
        percentage: percentage,
        transactionCount: (raw['transaction_count'] as num).toInt(),
      );
    }).toList();

    return MonthlySummary(
      monthKey: yearMonthKey,
      startingBalance: startingBalance,
      budget: budget,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      availableBalance: availableBalance,
      categorySpendings: categorySpendings,
    );
  }
}
