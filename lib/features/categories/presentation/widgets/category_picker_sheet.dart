import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/core/utils/category_icon_helper.dart';
import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/presentation/cubit/category_cubit.dart';
import 'package:varavu_selavu/features/categories/presentation/widgets/create_category_sheet.dart';
import 'package:varavu_selavu/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_event.dart';

class CategoryPickerSheet extends StatefulWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<Category> onCategorySelected;
  final CategoryType currentType;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.currentType = CategoryType.expense,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  bool _isEditMode = false;

  Future<void> _handleDeleteCategory(BuildContext context, Category cat) async {
    final cubit = sl<CategoryCubit>();
    final count = await cubit.getTransactionCount(cat.id);

    if (!context.mounted) return;

    final fallbackId = widget.currentType == CategoryType.income
        ? 'inc_other'
        : 'exp_other';

    if (count == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Delete Category?'),
          content: Text('Are you sure you want to delete "${cat.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        await cubit.deleteCategory(
          categoryId: cat.id,
          fallbackCategoryId: null,
        );
        final nowMonthKey = DateTime.now().toYearMonthKey();
        sl<DashboardBloc>().add(LoadDashboard(monthKey: nowMonthKey));
        sl<TransactionBloc>().add(LoadTransactions(monthKey: nowMonthKey));
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Category in Use'),
          content: Text(
            'This category is currently used in $count transaction${count == 1 ? '' : 's'}.\n\n'
            'Do you want to delete "${cat.name}" and move those transactions to "Other"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              child: const Text(
                'Move & Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        await cubit.deleteCategory(
          categoryId: cat.id,
          fallbackCategoryId: fallbackId,
        );
        // Refresh transactions and dashboard so the re-assigned transactions update everywhere
        final nowMonthKey = DateTime.now().toYearMonthKey();
        sl<DashboardBloc>().add(LoadDashboard(monthKey: nowMonthKey));
        sl<TransactionBloc>().add(LoadTransactions(monthKey: nowMonthKey));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditMode ? 'Manage Categories' : 'Select Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditMode)
                    TextButton(
                      onPressed: () => setState(() => _isEditMode = false),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          if (_isEditMode) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Tap the "X" badge to remove a category.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Flexible(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                final activeCategories = state is CategoryLoaded
                    ? (widget.currentType == CategoryType.income
                          ? state.incomeCategories
                          : state.expenseCategories)
                    : widget.categories;

                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: activeCategories.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    // Last item is "+ Add Category" button
                    if (index == activeCategories.length) {
                      return InkWell(
                        onTap: () async {
                          final newCat = await showModalBottomSheet<Category>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BlocProvider.value(
                              value: sl<CategoryCubit>(),
                              child: CreateCategorySheet(
                                defaultType: widget.currentType,
                              ),
                            ),
                          );

                          if (newCat != null && context.mounted) {
                            widget.onCategorySelected(newCat);
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(20),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary.withAlpha(
                                    120,
                                  ),
                                  style: BorderStyle.solid,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 28,
                              child: Center(
                                child: Text(
                                  '+ Add New',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final cat = activeCategories[index];
                    final isSelected = cat.id == widget.selectedCategoryId;
                    final catColor = Color(cat.color);
                    final iconData = CategoryIconHelper.getIconData(cat.icon);
                    // Safe guard default "Other" categories from deletion
                    final isDeletable =
                        cat.id != 'exp_other' && cat.id != 'inc_other';

                    return InkWell(
                      onTap: () {
                        if (_isEditMode) return;
                        widget.onCategorySelected(cat);
                        Navigator.pop(context);
                      },
                      onLongPress: () {
                        setState(() => _isEditMode = !_isEditMode);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? catColor
                                      : catColor.withAlpha(25),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(color: catColor, width: 2)
                                      : Border.all(color: Colors.transparent),
                                ),
                                child: Icon(
                                  iconData,
                                  color: isSelected ? Colors.white : catColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 28,
                                child: Center(
                                  child: Text(
                                    cat.name == 'Entertainment' ? 'Movies & Fun' : cat.name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10.5,
                                      height: 1.15,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? catColor
                                          : theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Red "X" delete badge in edit mode
                          if (_isEditMode && isDeletable)
                            Positioned(
                              top: 2,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    _handleDeleteCategory(context, cat),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: AppColors.expense,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(40),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
