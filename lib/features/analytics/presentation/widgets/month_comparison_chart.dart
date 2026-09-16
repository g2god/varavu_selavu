import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/features/analytics/domain/usecases/get_analytics_data_usecase.dart';

class MonthComparisonChart extends StatelessWidget {
  final List<MonthComparisonItem> items;

  const MonthComparisonChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxExp = items.map((e) => e.totalExpense).fold<double>(0.0, (prev, el) => el > prev ? el : prev);
    final maxInc = items.map((e) => e.totalIncome).fold<double>(0.0, (prev, el) => el > prev ? el : prev);
    final maxY = maxExp > maxInc ? maxExp : maxInc;

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
                'Month Comparison',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildLegend(AppColors.income, 'Income'),
                  const SizedBox(width: 12),
                  _buildLegend(AppColors.expense, 'Expense'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY > 0 ? maxY * 1.2 : 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < items.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              items[idx].monthLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withAlpha(140),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? (maxY / 3).ceilToDouble() : 1,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: theme.colorScheme.outline.withAlpha(20),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: item.totalIncome,
                        color: AppColors.income,
                        width: 10,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: item.totalExpense,
                        color: AppColors.expense,
                        width: 10,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
