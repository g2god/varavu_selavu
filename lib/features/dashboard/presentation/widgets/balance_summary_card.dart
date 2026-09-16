import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/extensions/number_extensions.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double availableBalance;
  final double moneyAdded;
  final double totalSpent;
  final double startingBalance;
  final VoidCallback? onEditStartingBalance;

  const BalanceSummaryCard({
    super.key,
    required this.availableBalance,
    required this.moneyAdded,
    required this.totalSpent,
    required this.startingBalance,
    this.onEditStartingBalance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(40)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              if (onEditStartingBalance != null)
                InkWell(
                  onTap: onEditStartingBalance,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          'Start: ${startingBalance.toCurrency()}',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_outlined, size: 12, color: theme.colorScheme.onSurface.withAlpha(120)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            availableBalance.toCurrency(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: availableBalance < 0 ? AppColors.expense : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Sub-metrics: Money Added and Spent
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'Money Added',
                  amount: moneyAdded,
                  amountColor: AppColors.income,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppColors.income,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: theme.colorScheme.outline.withAlpha(30),
              ),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'Spent',
                  amount: totalSpent,
                  amountColor: AppColors.expense,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required double amount,
    required Color amountColor,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(130),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount.toCurrency(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
