import 'package:equatable/equatable.dart';

enum CategoryType {
  expense,
  income;

  static CategoryType fromString(String value) {
    return value.toLowerCase() == 'income' ? CategoryType.income : CategoryType.expense;
  }

  String toDbString() => name;
}

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int color; // ARGB integer
  final CategoryType type;
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type, isDefault, createdAt];
}
