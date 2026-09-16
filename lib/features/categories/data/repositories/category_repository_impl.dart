import 'package:varavu_selavu/features/categories/data/datasources/category_local_data_source.dart';
import 'package:varavu_selavu/features/categories/data/models/category_model.dart';
import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Category>> getAllCategories() async {
    return await localDataSource.getAllCategories();
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    return await localDataSource.getCategoriesByType(type.toDbString());
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    return await localDataSource.getCategoryById(id);
  }

  @override
  Future<void> addCategory(Category category) async {
    await localDataSource.insertCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> updateCategory(Category category) async {
    await localDataSource.updateCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDataSource.deleteCategory(id);
  }
}
