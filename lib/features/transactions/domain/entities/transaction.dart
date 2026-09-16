import 'package:equatable/equatable.dart';

enum TransactionType {
  expense,
  income;

  static TransactionType fromString(String value) {
    return value.toLowerCase() == 'income' ? TransactionType.income : TransactionType.expense;
  }

  String toDbString() => name;
}

class AppTransaction extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final int? categoryColor;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  AppTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColor,
        date,
        note,
        createdAt,
        updatedAt,
      ];
}
