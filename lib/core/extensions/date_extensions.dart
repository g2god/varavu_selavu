import 'package:intl/intl.dart';

extension DateFormattingX on DateTime {
  String toIsoDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String toYearMonthKey() {
    return DateFormat('yyyy-MM').format(this);
  }

  String toMonthYearString() {
    return DateFormat('MMMM yyyy').format(this);
  }

  String toDisplayDateString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(year, month, day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM yyyy').format(this);
    }
  }

  String toDayMonthString() {
    return DateFormat('d MMM').format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  DateTime startOfMonth() {
    return DateTime(year, month, 1);
  }

  DateTime endOfMonth() {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }
}
