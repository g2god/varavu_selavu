import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/domain/usecases/add_category_usecase.dart';
import 'package:varavu_selavu/features/categories/domain/usecases/get_categories_usecase.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> allCategories;
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;

  const CategoryLoaded({
    required this.allCategories,
    required this.expenseCategories,
    required this.incomeCategories,
  });

  @override
  List<Object?> get props => [allCategories, expenseCategories, incomeCategories];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;

  CategoryCubit({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
  }) : super(CategoryInitial());

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      final categories = await getCategoriesUseCase();
      final expense = categories.where((c) => c.type == CategoryType.expense).toList();
      final income = categories.where((c) => c.type == CategoryType.income).toList();

      emit(CategoryLoaded(
        allCategories: categories,
        expenseCategories: expense,
        incomeCategories: income,
      ));
    } catch (e) {
      emit(CategoryError('Failed to load categories: $e'));
    }
  }

  Future<Category?> createCategory({
    required String name,
    required CategoryType type,
    required String icon,
    required int color,
  }) async {
    try {
      final category = Category(
        id: const Uuid().v4(),
        name: name.trim(),
        icon: icon,
        color: color,
        type: type,
        isDefault: false,
        createdAt: DateTime.now(),
      );

      await addCategoryUseCase(category);
      await loadCategories();
      return category;
    } catch (e) {
      emit(CategoryError('Failed to add category: $e'));
      return null;
    }
  }
}

