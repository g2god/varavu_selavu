import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/extensions/number_extensions.dart';
import 'package:varavu_selavu/core/utils/category_icon_helper.dart';
import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';

class CategorySpendingSummary extends StatelessWidget {
  final List<CategorySpending> categorySpendings;
  final VoidCallback? onViewAll;

  const CategorySpendingSummary({
    super.key,
    required this.categorySpendings,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topCategories = categorySpendings.take(4).toList();

    if (categorySpendings.isEmpty) {
      return const SizedBox.shrink();
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
                'Top Spending',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'See Analytics',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...topCategories.map((cat) {
            final catColor = Color(cat.categoryColor);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: catColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CategoryIconHelper.getIconData(cat.categoryIcon),
                          color: catColor,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat.categoryName,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        cat.totalAmount.toCurrency(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${cat.percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (cat.percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: theme.colorScheme.outline.withAlpha(30),
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                      minHeight: 4,
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
