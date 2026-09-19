import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:varavu_selavu/core/constants/app_constants.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/core/utils/category_icon_helper.dart';

import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/presentation/cubit/category_cubit.dart';
import 'package:varavu_selavu/features/categories/presentation/widgets/category_picker_sheet.dart';

import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_event.dart';

class AddEditTransactionPage extends StatefulWidget {
  final TransactionType initialType;
  final AppTransaction? existingTransaction;

  const AddEditTransactionPage({
    super.key,
    required this.initialType,
    this.existingTransaction,
  });

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  late TransactionType _selectedType;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();

  Category? _selectedCategory;
  late DateTime _selectedDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existingTransaction?.type ?? widget.initialType;
    _selectedDate = widget.existingTransaction?.date ?? DateTime.now();

    if (widget.existingTransaction != null) {
      _amountController.text = widget.existingTransaction!.amount % 1 == 0
          ? widget.existingTransaction!.amount.toInt().toString()
          : widget.existingTransaction!.amount.toString();
      _noteController.text = widget.existingTransaction!.note ?? '';
    }

    // Auto-focus amount field for speedy input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context, List<Category> availableCategories) {
    setState(() => _errorMessage = null);

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(
        () => _errorMessage = 'Please enter a valid amount greater than zero.',
      );
      return;
    }

    // Default category fallback if none picked
    final category =
        _selectedCategory ??
        (availableCategories.isNotEmpty
            ? availableCategories.first
            : Category(
                id: 'exp_other',
                name: 'Other',
                icon: 'more_horiz',
                color: 0xFF64748B,
                type: _selectedType == TransactionType.expense
                    ? CategoryType.expense
                    : CategoryType.income,
                createdAt: DateTime.now(),
              ));

    final now = DateTime.now();
    final isEditing = widget.existingTransaction != null;

    final transaction = AppTransaction(
      id: isEditing ? widget.existingTransaction!.id : const Uuid().v4(),
      type: _selectedType,
      amount: amount,
      categoryId: category.id,
      categoryName: category.name,
      categoryIcon: category.icon,
      categoryColor: category.color,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: isEditing ? widget.existingTransaction!.createdAt : now,
      updatedAt: now,
    );

    final transactionBloc = sl<TransactionBloc>();
    if (isEditing) {
      transactionBloc.add(UpdateTransactionSubmitted(transaction));
    } else {
      transactionBloc.add(AddTransactionSubmitted(transaction));
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = _selectedType == TransactionType.income;
    final primaryThemeColor = isIncome ? AppColors.income : AppColors.expense;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, catState) {
        List<Category> categories = [];
        if (catState is CategoryLoaded) {
          categories = isIncome
              ? catState.incomeCategories
              : catState.expenseCategories;
          // Select default or matching category if not set or if previously selected category was deleted
          final isCurrentSelectedValid =
              _selectedCategory != null &&
              categories.any((c) => c.id == _selectedCategory!.id);

          if (!isCurrentSelectedValid) {
            if (widget.existingTransaction != null) {
              final match = catState.allCategories.where(
                (c) => c.id == widget.existingTransaction!.categoryId,
              );
              if (match.isNotEmpty &&
                  categories.any((c) => c.id == match.first.id)) {
                _selectedCategory = match.first;
              } else {
                _selectedCategory = categories.isNotEmpty
                    ? categories.first
                    : null;
              }
            } else {
              _selectedCategory = categories.isNotEmpty
                  ? categories.first
                  : null;
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.existingTransaction != null
                  ? 'Edit ${isIncome ? "Income" : "Expense"}'
                  : 'Add ${isIncome ? "Money" : "Expense"}',
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type toggle (Expense vs Income)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeSegment(
                            title: 'Expense',
                            isSelected: !isIncome,
                            activeColor: AppColors.expense,
                            onTap: () {
                              setState(() {
                                _selectedType = TransactionType.expense;
                                _selectedCategory = null;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildTypeSegment(
                            title: 'Money Added',
                            isSelected: isIncome,
                            activeColor: AppColors.income,
                            onTap: () {
                              setState(() {
                                _selectedType = TransactionType.income;
                                _selectedCategory = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Amount Input Section
                  Center(
                    child: Text(
                      'AMOUNT',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(120),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppConstants.defaultCurrencySymbol,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: primaryThemeColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 40),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: primaryThemeColor,
                              height: 1.1,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: primaryThemeColor.withAlpha(100),
                                height: 1.1,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 36),

                  // Category Selector
                  _buildSectionHeader('CATEGORY'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      if (categories.isNotEmpty) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => CategoryPickerSheet(
                            categories: categories,
                            selectedCategoryId: _selectedCategory?.id,
                            currentType: _selectedType == TransactionType.income
                                ? CategoryType.income
                                : CategoryType.expense,
                            onCategorySelected: (cat) {
                              setState(() => _selectedCategory = cat);
                            },
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_selectedCategory != null) ...[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color(_selectedCategory!.color)
                                    .withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CategoryIconHelper.getIconData(
                                  _selectedCategory!.icon,
                                ),
                                color: Color(_selectedCategory!.color),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedCategory!.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.category_outlined, size: 22),
                            const SizedBox(width: 12),
                            const Text('Choose Category'),
                          ],
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date Picker Selector
                  _buildSectionHeader('DATE'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate.toDisplayDateString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _selectedDate.toIsoDateString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Note Input Field
                  _buildSectionHeader('NOTE (OPTIONAL)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: isIncome
                          ? 'e.g. Freelance payment, gift'
                          : 'e.g. Lunch with team, grocery run',
                      prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                    ),
                    maxLength: 100,
                  ),

                  const SizedBox(height: 36),

                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryThemeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _onSave(context, categories),
                    child: Text(
                      widget.existingTransaction != null
                          ? 'Update'
                          : (isIncome ? 'Save Income' : 'Save Expense'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSegment({
    required String title,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(130),
      ),
    );
  }
}
