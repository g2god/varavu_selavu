import 'package:equatable/equatable.dart';

class MonthlyConfig extends Equatable {
  final String monthKey; // e.g. "2026-09"
  final double startingBalance;
  final double budget;
  final DateTime updatedAt;

  const MonthlyConfig({
    required this.monthKey,
    required this.startingBalance,
    this.budget = 0.0,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [monthKey, startingBalance, budget, updatedAt];
}

class CategorySpending extends Equatable {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final double totalAmount;
  final double percentage;
  final int transactionCount;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        categoryIcon,
        categoryColor,
        totalAmount,
        percentage,
        transactionCount,
      ];
}

class MonthlySummary extends Equatable {
  final String monthKey;
  final double startingBalance;
  final double budget;
  final double totalIncome;
  final double totalExpense;
  final double availableBalance;
  final List<CategorySpending> categorySpendings;

  const MonthlySummary({
    required this.monthKey,
    required this.startingBalance,
    this.budget = 0.0,
    required this.totalIncome,
    required this.totalExpense,
    required this.availableBalance,
    required this.categorySpendings,
  });

  @override
  List<Object?> get props => [
        monthKey,
        startingBalance,
        budget,
        totalIncome,
        totalExpense,
        availableBalance,
        categorySpendings,
      ];
}
