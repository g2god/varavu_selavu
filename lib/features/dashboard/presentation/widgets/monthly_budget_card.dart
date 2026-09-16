import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/extensions/number_extensions.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';

class MonthlyBudgetCard extends StatelessWidget {
  final double budget;
  final double totalSpent;
  final DateTime selectedMonth;
  final VoidCallback onSetBudget;

  const MonthlyBudgetCard({
    super.key,
    required this.budget,
    required this.totalSpent,
    required this.selectedMonth,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Days remaining calculation
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.year == now.year && selectedMonth.month == now.month;
    final totalDaysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final daysRemaining = isCurrentMonth
        ? (totalDaysInMonth - now.day + 1).clamp(1, totalDaysInMonth)
        : totalDaysInMonth;

    final remainingBudget = budget > 0 ? (budget - totalSpent) : 0.0;
    final progress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = budget > 0 && totalSpent > budget;

    // Dynamic color coding: Emerald -> Amber -> Rose
    Color progressColor = AppColors.income;
    if (isOverBudget || progress >= 0.90) {
      progressColor = AppColors.expense;
    } else if (progress >= 0.70) {
      progressColor = const Color(0xFFF59E0B); // Amber
    }

    final dailySafeSpend = (remainingBudget > 0 && daysRemaining > 0)
        ? (remainingBudget / daysRemaining)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget
              ? AppColors.expense.withAlpha(120)
              : theme.colorScheme.outline.withAlpha(40),
          width: isOverBudget ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: progressColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.track_changes_rounded, size: 16, color: progressColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Monthly Spending Budget',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onSetBudget,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        budget > 0 ? 'Edit' : '+ Set Budget',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (budget <= 0) ...[
            // Empty Budget Prompt
            InkWell(
              onTap: onSetBudget,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.outline.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_chart_rounded, size: 20, color: theme.colorScheme.onSurface.withAlpha(150)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Set a spending target to track your daily safe-to-spend allowance.',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(140)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Progress details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent: ${totalSpent.toCurrency()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Limit: ${budget.toCurrency()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withAlpha(130),
                      ),
                    ),
                  ],
                ),
                Text(
                  isOverBudget
                      ? 'Over by ${(totalSpent - budget).toCurrency()}'
                      : '${(progress * 100).toStringAsFixed(0)}% Used',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Animated progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.outline.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 14),

            // Daily Safe-to-Spend Allowance Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isOverBudget
                    ? AppColors.expense.withAlpha(15)
                    : theme.colorScheme.surfaceContainerHighest.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverBudget ? Icons.warning_amber_rounded : Icons.savings_outlined,
                    size: 16,
                    color: isOverBudget ? AppColors.expense : AppColors.income,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOverBudget
                          ? 'You have exceeded this month’s target.'
                          : daysRemaining > 0
                              ? 'Safe to spend: ${dailySafeSpend.toCurrency()} / day for the next $daysRemaining ${daysRemaining == 1 ? "day" : "days"}.'
                              : 'Remaining balance: ${remainingBudget.toCurrency()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOverBudget ? AppColors.expense : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
