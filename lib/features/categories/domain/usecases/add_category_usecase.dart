import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/domain/repositories/category_repository.dart';

class AddCategoryUseCase {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return await repository.addCategory(category);
  }
}
