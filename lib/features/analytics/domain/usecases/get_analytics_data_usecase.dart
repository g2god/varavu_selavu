import 'package:equatable/equatable.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';
import 'package:varavu_selavu/features/dashboard/domain/usecases/get_monthly_summary_usecase.dart';

class DailySpendingPoint extends Equatable {
  final int day;
  final double amount;

  const DailySpendingPoint({required this.day, required this.amount});

  @override
  List<Object?> get props => [day, amount];
}

class MonthComparisonItem extends Equatable {
  final String monthKey;
  final String monthLabel;
  final double totalExpense;
  final double totalIncome;

  const MonthComparisonItem({
    required this.monthKey,
    required this.monthLabel,
    required this.totalExpense,
    required this.totalIncome,
  });

  @override
  List<Object?> get props => [monthKey, monthLabel, totalExpense, totalIncome];
}

class AnalyticsData extends Equatable {
  final String currentMonthKey;
  final List<DailySpendingPoint> dailyTrend;
  final List<CategorySpending> categoryBreakdown;
  final List<MonthComparisonItem> monthComparison;
  final double totalExpense;
  final double totalIncome;
  final double averageDailyExpense;

  const AnalyticsData({
    required this.currentMonthKey,
    required this.dailyTrend,
    required this.categoryBreakdown,
    required this.monthComparison,
    required this.totalExpense,
    required this.totalIncome,
    required this.averageDailyExpense,
  });

  @override
  List<Object?> get props => [
        currentMonthKey,
        dailyTrend,
        categoryBreakdown,
        monthComparison,
        totalExpense,
        totalIncome,
        averageDailyExpense,
      ];
}

class GetAnalyticsDataUseCase {
  final TransactionRepository transactionRepository;
  final GetMonthlySummaryUseCase getMonthlySummaryUseCase;

  GetAnalyticsDataUseCase({
    required this.transactionRepository,
    required this.getMonthlySummaryUseCase,
  });

  Future<AnalyticsData> call(String yearMonthKey) async {
    final parts = yearMonthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // 1. Current Month Summary
    final currentSummary = await getMonthlySummaryUseCase(yearMonthKey);

    // 2. Fetch all transactions for this month to group into daily trend
    final transactions = await transactionRepository.getTransactionsByMonth(yearMonthKey);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final dailyMap = <int, double>{};
    for (int i = 1; i <= daysInMonth; i++) {
      dailyMap[i] = 0.0;
    }

    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        final day = tx.date.day;
        dailyMap[day] = (dailyMap[day] ?? 0.0) + tx.amount;
      }
    }

    final dailyTrend = dailyMap.entries
        .map((e) => DailySpendingPoint(day: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    final now = DateTime.now();
    final elapsedDays = (now.year == year && now.month == month) ? now.day : daysInMonth;
    final averageDaily = elapsedDays > 0 ? (currentSummary.totalExpense / elapsedDays) : 0.0;

    // 3. Compare past 4 months
    final monthComparison = <MonthComparisonItem>[];
    for (int i = 3; i >= 0; i--) {
      final targetDate = DateTime(year, month - i, 1);
      final targetKey = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';
      
      final txs = await transactionRepository.getTransactionsByMonth(targetKey);
      double exp = 0;
      double inc = 0;
      for (final t in txs) {
        if (t.type == TransactionType.expense) {
          exp += t.amount;
        } else {
          inc += t.amount;
        }
      }

      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final label = '${monthNames[targetDate.month - 1]} ${targetDate.year.toString().substring(2)}';

      monthComparison.add(MonthComparisonItem(
        monthKey: targetKey,
        monthLabel: label,
        totalExpense: exp,
        totalIncome: inc,
      ));
    }

    return AnalyticsData(
      currentMonthKey: yearMonthKey,
      dailyTrend: dailyTrend,
      categoryBreakdown: currentSummary.categorySpendings,
      monthComparison: monthComparison,
      totalExpense: currentSummary.totalExpense,
      totalIncome: currentSummary.totalIncome,
      averageDailyExpense: averageDaily,
    );
  }
}
