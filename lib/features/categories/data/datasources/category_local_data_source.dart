import 'package:varavu_selavu/features/categories/data/models/category_model.dart';
import 'package:varavu_selavu/core/database/app_database.dart';
import 'package:varavu_selavu/core/database/database_tables.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<List<CategoryModel>> getCategoriesByType(String type);
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> insertCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase appDatabase;

  CategoryLocalDataSourceImpl({required this.appDatabase});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await appDatabase.database;
    final results = await db.query(
      DatabaseTables.categories,
      orderBy: '${DatabaseTables.colCatType} ASC, ${DatabaseTables.colCatName} ASC',
    );
    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final db = await appDatabase.database;
    final results = await db.query(
      DatabaseTables.categories,
      where: '${DatabaseTables.colCatType} = ?',
      whereArgs: [type],
      orderBy: '${DatabaseTables.colCatName} ASC',
    );
    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final db = await appDatabase.database;
    final results = await db.query(
      DatabaseTables.categories,
      where: '${DatabaseTables.colCatId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  @override
  Future<void> insertCategory(CategoryModel category) async {
    final db = await appDatabase.database;
    await db.insert(
      DatabaseTables.categories,
      category.toMap(),
    );
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final db = await appDatabase.database;
    await db.update(
      DatabaseTables.categories,
      category.toMap(),
      where: '${DatabaseTables.colCatId} = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await appDatabase.database;
    await db.delete(
      DatabaseTables.categories,
      where: '${DatabaseTables.colCatId} = ?',
      whereArgs: [id],
    );
  }
}
