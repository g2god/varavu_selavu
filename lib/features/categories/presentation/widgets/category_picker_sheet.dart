import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/utils/category_icon_helper.dart';
import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/presentation/cubit/category_cubit.dart';
import 'package:varavu_selavu/features/categories/presentation/widgets/create_category_sheet.dart';

class CategoryPickerSheet extends StatelessWidget {
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
                'Select Category',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: categories.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                // Last item is "+ Add Category" button
                if (index == categories.length) {
                  return InkWell(
                    onTap: () async {
                      final newCat = await showModalBottomSheet<Category>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BlocProvider.value(
                          value: sl<CategoryCubit>(),
                          child: CreateCategorySheet(defaultType: currentType),
                        ),
                      );

                      if (newCat != null && context.mounted) {
                        onCategorySelected(newCat);
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withAlpha(120),
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
                        Text(
                          '+ Add New',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  );
                }

                final cat = categories[index];
                final isSelected = cat.id == selectedCategoryId;
                final catColor = Color(cat.color);
                final iconData = CategoryIconHelper.getIconData(cat.icon);

                return InkWell(
                  onTap: () {
                    onCategorySelected(cat);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? catColor : catColor.withAlpha(25),
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
                      Text(
                        cat.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? catColor : theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
