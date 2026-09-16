import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    super.isDefault = true,
    required super.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DatabaseTables.colCatId] as String,
      name: map[DatabaseTables.colCatName] as String,
      icon: map[DatabaseTables.colCatIcon] as String,
      color: map[DatabaseTables.colCatColor] as int,
      type: CategoryType.fromString(map[DatabaseTables.colCatType] as String),
      isDefault: (map[DatabaseTables.colCatIsDefault] as int) == 1,
      createdAt: DateTime.parse(map[DatabaseTables.colCatCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colCatId: id,
      DatabaseTables.colCatName: name,
      DatabaseTables.colCatIcon: icon,
      DatabaseTables.colCatColor: color,
      DatabaseTables.colCatType: type.toDbString(),
      DatabaseTables.colCatIsDefault: isDefault ? 1 : 0,
      DatabaseTables.colCatCreatedAt: createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      type: entity.type,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
    );
  }
}
