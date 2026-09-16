import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<Category>> call({CategoryType? type}) async {
    if (type != null) {
      return await repository.getCategoriesByType(type);
    }
    return await repository.getAllCategories();
  }
}
