import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final String formattedAmount;
  final TextStyle? style;
  final Color? color;
  final bool isExpense;
  final bool isIncome;

  const AmountDisplay({
    super.key,
    required this.formattedAmount,
    this.style,
    this.color,
    this.isExpense = false,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = isExpense ? '-' : (isIncome ? '+' : '');
    return Text(
      '$prefix$formattedAmount',
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
