import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';

class QuickActionButtons extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddMoney;

  const QuickActionButtons({
    super.key,
    required this.onAddExpense,
    required this.onAddMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Add Expense Action
        Expanded(
          child: InkWell(
            onTap: onAddExpense,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.expenseLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.expenseBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_circle_outline, color: AppColors.expense, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Expense',
                    style: TextStyle(
                      color: AppColors.expense,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Add Money Action
        Expanded(
          child: InkWell(
            onTap: onAddMoney,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.incomeLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.incomeBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.income, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Money',
                    style: TextStyle(
                      color: AppColors.income,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
