import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/extensions/number_extensions.dart';
import 'package:varavu_selavu/core/utils/category_icon_helper.dart';
import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';

class FullCategoryBreakdownList extends StatelessWidget {
  final List<CategorySpending> categorySpendings;
  final double totalExpense;

  const FullCategoryBreakdownList({
    super.key,
    required this.categorySpendings,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categorySpendings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withAlpha(40)),
        ),
        child: Center(
          child: Text(
            'No expense categories to show.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(120)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Breakdown',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: ${totalExpense.toCurrency()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...categorySpendings.map((cat) {
            final catColor = Color(cat.categoryColor);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CategoryIconHelper.getIconData(cat.categoryIcon),
                          color: catColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.categoryName,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${cat.transactionCount} transaction${cat.transactionCount == 1 ? "" : "s"}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withAlpha(120),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            cat.totalAmount.toCurrency(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${cat.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (cat.percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: theme.colorScheme.outline.withAlpha(25),
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
