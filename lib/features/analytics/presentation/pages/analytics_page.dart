import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/extensions/number_extensions.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/core/widgets/error_view.dart';
import 'package:varavu_selavu/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:varavu_selavu/features/analytics/presentation/widgets/full_category_breakdown_list.dart';
import 'package:varavu_selavu/features/analytics/presentation/widgets/month_comparison_chart.dart';
import 'package:varavu_selavu/features/analytics/presentation/widgets/spending_trend_chart.dart';

class AnalyticsPage extends StatefulWidget {
  final String currentMonthKey;

  const AnalyticsPage({super.key, required this.currentMonthKey});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late final AnalyticsCubit _analyticsCubit;

  @override
  void initState() {
    super.initState();
    _analyticsCubit = sl<AnalyticsCubit>()..loadAnalytics(widget.currentMonthKey);
  }

  @override
  void didUpdateWidget(covariant AnalyticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonthKey != widget.currentMonthKey) {
      _analyticsCubit.loadAnalytics(widget.currentMonthKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _analyticsCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
        ),
        body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AnalyticsError) {
              return ErrorStateView(
                message: state.message,
                onRetry: () => _analyticsCubit.loadAnalytics(widget.currentMonthKey),
              );
            }

            if (state is AnalyticsLoaded) {
              final data = state.data;

              return RefreshIndicator(
                onRefresh: () async {
                  await _analyticsCubit.loadAnalytics(widget.currentMonthKey);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Key Stats Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.outline.withAlpha(40)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildMetric(
                                context,
                                label: 'Total Spent',
                                value: data.totalExpense.toCurrency(),
                                color: AppColors.expense,
                              ),
                            ),
                            Container(width: 1, height: 40, color: theme.colorScheme.outline.withAlpha(30)),
                            Expanded(
                              child: _buildMetric(
                                context,
                                label: 'Daily Average',
                                value: data.averageDailyExpense.toCurrency(),
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Container(width: 1, height: 40, color: theme.colorScheme.outline.withAlpha(30)),
                            Expanded(
                              child: _buildMetric(
                                context,
                                label: 'Money Added',
                                value: data.totalIncome.toCurrency(),
                                color: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daily spending line trend
                      SpendingTrendChart(dailyTrend: data.dailyTrend),
                      const SizedBox(height: 16),

                      // Category breakdown
                      FullCategoryBreakdownList(
                        categorySpendings: data.categoryBreakdown,
                        totalExpense: data.totalExpense,
                      ),
                      const SizedBox(height: 16),

                      // Month-over-month comparison
                      MonthComparisonChart(items: data.monthComparison),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, {required String label, required String value, required Color color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(120),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
