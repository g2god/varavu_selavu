import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthSelector({
    super.key,
    required this.selectedDate,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCurrentMonth = selectedDate.year == now.year && selectedDate.month == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 22),
            onPressed: () {
              final prev = DateTime(selectedDate.year, selectedDate.month - 1, 1);
              onMonthChanged(prev);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Text(
            selectedDate.toShortMonthYearString(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: 22,
              color: isCurrentMonth ? theme.colorScheme.onSurface.withAlpha(50) : null,
            ),
            onPressed: isCurrentMonth
                ? null
                : () {
                    final next = DateTime(selectedDate.year, selectedDate.month + 1, 1);
                    onMonthChanged(next);
                  },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
