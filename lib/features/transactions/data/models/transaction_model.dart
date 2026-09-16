import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

class TransactionModel extends AppTransaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.categoryId,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
    required super.date,
    super.note,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[DatabaseTables.colTxId] as String,
      type: TransactionType.fromString(map[DatabaseTables.colTxType] as String),
      amount: (map[DatabaseTables.colTxAmount] as num).toDouble(),
      categoryId: map[DatabaseTables.colTxCategoryId] as String,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      categoryColor: map['category_color'] as int?,
      date: DateTime.parse(map[DatabaseTables.colTxDate] as String),
      note: map[DatabaseTables.colTxNote] as String?,
      createdAt: DateTime.parse(map[DatabaseTables.colTxCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseTables.colTxUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colTxId: id,
      DatabaseTables.colTxType: type.toDbString(),
      DatabaseTables.colTxAmount: amount,
      DatabaseTables.colTxCategoryId: categoryId,
      DatabaseTables.colTxDate: date.toIso8601String().split('T').first, // YYYY-MM-DD
      DatabaseTables.colTxNote: note,
      DatabaseTables.colTxCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.colTxUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromEntity(AppTransaction entity) {
    return TransactionModel(
      id: entity.id,
      type: entity.type,
      amount: entity.amount,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      categoryColor: entity.categoryColor,
      date: entity.date,
      note: entity.note,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
