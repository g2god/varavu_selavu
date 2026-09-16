import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/features/analytics/domain/usecases/get_analytics_data_usecase.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<DailySpendingPoint> dailyTrend;

  const SpendingTrendChart({super.key, required this.dailyTrend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount = dailyTrend.map((e) => e.amount).fold<double>(0.0, (prev, elem) => elem > prev ? elem : prev);

    final spots = dailyTrend.map((p) => FlSpot(p.day.toDouble(), p.amount)).toList();

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
          Text(
            'Daily Spending Trend',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: spots.isEmpty || maxAmount == 0
                ? Center(
                    child: Text(
                      'No expense activity logged for this month yet.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(120)),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxAmount > 0 ? (maxAmount / 3).ceilToDouble() : 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.colorScheme.outline.withAlpha(20),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurface.withAlpha(120),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 1,
                      maxX: dailyTrend.isNotEmpty ? dailyTrend.last.day.toDouble() : 31,
                      minY: 0,
                      maxY: maxAmount > 0 ? maxAmount * 1.15 : 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: AppColors.expense,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.expense.withAlpha(20),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
