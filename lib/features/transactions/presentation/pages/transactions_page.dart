import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/core/widgets/empty_state_view.dart';
import 'package:varavu_selavu/core/widgets/error_view.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:varavu_selavu/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:varavu_selavu/features/transactions/presentation/pages/add_edit_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  final String currentMonthKey;

  const TransactionsPage({super.key, required this.currentMonthKey});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final TransactionBloc _transactionBloc;
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _transactionBloc = sl<TransactionBloc>()..add(LoadTransactions(monthKey: widget.currentMonthKey));
  }

  @override
  void didUpdateWidget(covariant TransactionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonthKey != widget.currentMonthKey) {
      _transactionBloc.add(LoadTransactions(monthKey: widget.currentMonthKey));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _transactionBloc.add(FilterTransactionsQuery(
      searchQuery: query,
      typeFilter: _selectedTypeFilter,
    ));
  }

  void _onTypeFilterSelected(TransactionType? type) {
    setState(() => _selectedTypeFilter = type);
    _transactionBloc.add(FilterTransactionsQuery(
      searchQuery: _searchController.text,
      typeFilter: _selectedTypeFilter,
    ));
  }

  Map<String, List<AppTransaction>> _groupTransactionsByDate(List<AppTransaction> transactions) {
    final Map<String, List<AppTransaction>> groups = {};
    for (final tx in transactions) {
      final dateKey = tx.date.toDisplayDateString();
      groups.putIfAbsent(dateKey, () => []).add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _transactionBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
        ),
        body: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildFilterChip('All', _selectedTypeFilter == null, () => _onTypeFilterSelected(null)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Expenses', _selectedTypeFilter == TransactionType.expense,
                          () => _onTypeFilterSelected(TransactionType.expense)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Income', _selectedTypeFilter == TransactionType.income,
                          () => _onTypeFilterSelected(TransactionType.income)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Transactions grouped list
            Expanded(
              child: BlocConsumer<TransactionBloc, TransactionState>(
                listener: (context, state) {
                  if (state is TransactionOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), duration: const Duration(seconds: 2)),
                    );
                    _transactionBloc.add(LoadTransactions(monthKey: widget.currentMonthKey));
                  }
                },
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TransactionError) {
                    return ErrorStateView(
                      message: state.message,
                      onRetry: () => _transactionBloc.add(LoadTransactions(monthKey: widget.currentMonthKey)),
                    );
                  }

                  if (state is TransactionLoaded) {
                    if (state.filteredTransactions.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: state.allTransactions.isEmpty ? 'No transactions in this month' : 'No matching transactions',
                        description: state.allTransactions.isEmpty
                            ? 'Tap the + button below to log your first expense or money added.'
                            : 'Try adjusting your search query or filters.',
                        actionLabel: state.allTransactions.isEmpty ? 'Add Expense' : null,
                        onAction: state.allTransactions.isEmpty
                            ? () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddEditTransactionPage(initialType: TransactionType.expense),
                                  ),
                                );
                                if (res == true) {
                                  _transactionBloc.add(LoadTransactions(monthKey: widget.currentMonthKey));
                                }
                              }
                            : null,
                      );
                    }

                    final grouped = _groupTransactionsByDate(state.filteredTransactions);

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, groupIndex) {
                        final dateHeader = grouped.keys.elementAt(groupIndex);
                        final items = grouped[dateHeader]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Text(
                                dateHeader,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface.withAlpha(140),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            ...items.map((tx) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: TransactionTile(
                                    transaction: tx,
                                    onTap: () async {
                                      final updated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditTransactionPage(
                                            initialType: tx.type,
                                            existingTransaction: tx,
                                          ),
                                        ),
                                      );
                                      if (updated == true) {
                                        _transactionBloc.add(LoadTransactions(monthKey: widget.currentMonthKey));
                                      }
                                    },
                                    onDelete: () {
                                      _transactionBloc.add(DeleteTransactionSubmitted(
                                        id: tx.id,
                                        monthKey: widget.currentMonthKey,
                                      ));
                                    },
                                  ),
                                )),
                          ],
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withAlpha(50),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
