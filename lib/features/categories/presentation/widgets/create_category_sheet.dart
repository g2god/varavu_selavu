import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/utils/category_icon_helper.dart';
import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/presentation/cubit/category_cubit.dart';

class CreateCategorySheet extends StatefulWidget {
  final CategoryType defaultType;
  final ValueChanged<Category>? onCategoryCreated;

  const CreateCategorySheet({
    super.key,
    required this.defaultType,
    this.onCategoryCreated,
  });

  @override
  State<CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends State<CreateCategorySheet> {
  final _nameController = TextEditingController();
  late CategoryType _selectedType;
  String _selectedIcon = 'fastfood';
  int _selectedColor = 0xFFFB923C;
  String? _error;
  bool _isSubmitting = false;

  final List<int> _colorPalette = const [
    0xFFFB923C, // Orange
    0xFFEF4444, // Red
    0xFFEC4899, // Pink
    0xFF8B5CF6, // Purple
    0xFF6366F1, // Indigo
    0xFF3B82F6, // Blue
    0xFF0EA5E9, // Sky
    0xFF14B8A6, // Teal
    0xFF10B981, // Emerald
    0xFF84CC16, // Lime
    0xFFF59E0B, // Amber
    0xFF64748B, // Slate
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.defaultType;
    if (_selectedType == CategoryType.income) {
      _selectedIcon = 'account_balance_wallet';
      _selectedColor = 0xFF10B981;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter category name');
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    final cubit = context.read<CategoryCubit>();
    final newCategory = await cubit.createCategory(
      name: name,
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (newCategory != null) {
        widget.onCategoryCreated?.call(newCategory);
        Navigator.pop(context, newCategory);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Category',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Preview Badge
            Center(
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Color(_selectedColor).withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(_selectedColor), width: 2),
                    ),
                    child: Icon(
                      CategoryIconHelper.getIconData(_selectedIcon),
                      color: Color(_selectedColor),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nameController.text.trim().isEmpty ? 'Category Name' : _nameController.text.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Color(_selectedColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Name Field
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Snacks, Gym, Coffee',
                errorText: _error,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
            ),
            const SizedBox(height: 18),

            // Icon Picker
            Text(
              'Select Icon',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 130,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: CategoryIconHelper.availableIcons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final item = CategoryIconHelper.availableIcons[index];
                  final isSelected = item['name'] == _selectedIcon;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedIcon = item['name']);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Color(_selectedColor).withAlpha(35) : theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Color(_selectedColor) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isSelected ? Color(_selectedColor) : theme.colorScheme.onSurface.withAlpha(180),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Color Palette Picker
            Text(
              'Select Color',
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colorPalette.map((colorValue) {
                final isSelected = colorValue == _selectedColor;
                final color = Color(colorValue);

                return InkWell(
                  onTap: () {
                    setState(() => _selectedColor = colorValue);
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.onSurface, width: 2.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(120),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(_selectedColor),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
