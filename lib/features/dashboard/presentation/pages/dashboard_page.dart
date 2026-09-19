import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/core/widgets/empty_state_view.dart';
import 'package:varavu_selavu/core/widgets/error_view.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:varavu_selavu/features/transactions/presentation/pages/add_edit_transaction_page.dart';
import 'package:varavu_selavu/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:varavu_selavu/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:varavu_selavu/features/dashboard/presentation/widgets/balance_summary_card.dart';
import 'package:varavu_selavu/features/dashboard/presentation/widgets/category_spending_summary.dart';
import 'package:varavu_selavu/features/dashboard/presentation/widgets/month_selector.dart';
import 'package:varavu_selavu/features/dashboard/presentation/widgets/monthly_budget_card.dart';
import 'package:varavu_selavu/features/dashboard/presentation/widgets/quick_action_buttons.dart';

class DashboardPage extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onNavigateToTransactions;
  final VoidCallback onNavigateToAnalytics;

  const DashboardPage({
    super.key,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onNavigateToTransactions,
    required this.onNavigateToAnalytics,
  });

  void _showBudgetDialog(BuildContext context, double currentBudget) {
    final controller = TextEditingController(
      text: currentBudget > 0
          ? (currentBudget % 1 == 0
                ? currentBudget.toInt().toString()
                : currentBudget.toString())
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Set Monthly Spending Budget'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set a maximum spending limit for ${selectedDate.toMonthYearString()} to track your safe daily spending allowance.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: 'e.g. 20000',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim()) ?? 0.0;
              context.read<DashboardBloc>().add(
                UpdateMonthlyBudget(
                  monthKey: selectedDate.toYearMonthKey(),
                  budget: val,
                ),
              );
              Navigator.pop(dialogCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStartingBalanceDialog(BuildContext context, double currentBalance) {
    final controller = TextEditingController(
      text: currentBalance > 0
          ? (currentBalance % 1 == 0
                ? currentBalance.toInt().toString()
                : currentBalance.toString())
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Set Starting Balance'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the initial balance you had at the start of ${selectedDate.toMonthYearString()}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: '0',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim()) ?? 0.0;
              context.read<DashboardBloc>().add(
                UpdateStartingBalance(
                  monthKey: selectedDate.toYearMonthKey(),
                  startingBalance: val,
                ),
              );
              Navigator.pop(dialogCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Varavu Selavu'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MonthSelector(
              selectedDate: selectedDate,
              onMonthChanged: onMonthChanged,
            ),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return ErrorStateView(
              message: state.message,
              onRetry: () => context.read<DashboardBloc>().add(
                LoadDashboard(monthKey: selectedDate.toYearMonthKey()),
              ),
            );
          }

          if (state is DashboardLoaded) {
            final summary = state.summary;
            final hasActivity =
                summary.totalIncome > 0 ||
                summary.totalExpense > 0 ||
                summary.startingBalance > 0 ||
                state.recentTransactions.isNotEmpty;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(
                  LoadDashboard(monthKey: selectedDate.toYearMonthKey()),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Available Balance Card
                    BalanceSummaryCard(
                      availableBalance: summary.availableBalance,
                      moneyAdded: summary.totalIncome,
                      totalSpent: summary.totalExpense,
                      startingBalance: summary.startingBalance,
                      onEditStartingBalance: () => _showStartingBalanceDialog(
                        context,
                        summary.startingBalance,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Monthly Spending Budget & Safe Daily Allowance Card
                    MonthlyBudgetCard(
                      budget: summary.budget,
                      totalSpent: summary.totalExpense,
                      selectedMonth: selectedDate,
                      onSetBudget: () =>
                          _showBudgetDialog(context, summary.budget),
                    ),
                    const SizedBox(height: 16),

                    // Quick Action Buttons (Add Expense / Add Money)
                    QuickActionButtons(
                      onAddExpense: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditTransactionPage(
                              initialType: TransactionType.expense,
                            ),
                          ),
                        );
                        if (context.mounted) {
                          final monthKey = selectedDate.toYearMonthKey();
                          context.read<DashboardBloc>().add(
                            LoadDashboard(monthKey: monthKey),
                          );
                          sl<TransactionBloc>().add(
                            LoadTransactions(monthKey: monthKey),
                          );
                        }
                      },
                      onAddMoney: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditTransactionPage(
                              initialType: TransactionType.income,
                            ),
                          ),
                        );
                        if (context.mounted) {
                          final monthKey = selectedDate.toYearMonthKey();
                          context.read<DashboardBloc>().add(
                            LoadDashboard(monthKey: monthKey),
                          );
                          sl<TransactionBloc>().add(
                            LoadTransactions(monthKey: monthKey),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category Spending Breakdown Preview
                    if (summary.categorySpendings.isNotEmpty) ...[
                      CategorySpendingSummary(
                        categorySpendings: summary.categorySpendings,
                        onViewAll: onNavigateToAnalytics,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Recent Transactions Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.recentTransactions.isNotEmpty)
                          GestureDetector(
                            onTap: onNavigateToTransactions,
                            child: Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (!hasActivity)
                      EmptyStateView(
                        icon: Icons.account_balance_wallet_outlined,
                        title:
                            'No activity in ${selectedDate.toMonthYearString()}',
                        description: 'Record an expense or add money to start monitoring your balance.',
                        actionLabel: 'Add Expense',
                        onAction: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddEditTransactionPage(
                                initialType: TransactionType.expense,
                              ),
                            ),
                          );
                          if (res == true && context.mounted) {
                            context.read<DashboardBloc>().add(
                              LoadDashboard(
                                monthKey: selectedDate.toYearMonthKey(),
                              ),
                            );
                          }
                        },
                      )
                    else if (state.recentTransactions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No recent transactions found.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                        ),
                      )
                    else
                      ...state.recentTransactions.map(
                        (tx) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TransactionTile(
                            transaction: tx,
                            onTap: () async {
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditTransactionPage(
                                    initialType: tx.type,
                                    existingTransaction: tx,
                                  ),
                                ),
                              );
                              if (res == true && context.mounted) {
                                context.read<DashboardBloc>().add(
                                  LoadDashboard(
                                    monthKey: selectedDate.toYearMonthKey(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
