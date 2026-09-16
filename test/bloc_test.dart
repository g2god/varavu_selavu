import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:varavu_selavu/features/categories/domain/entities/category.dart';
import 'package:varavu_selavu/features/categories/domain/usecases/add_category_usecase.dart';
import 'package:varavu_selavu/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:varavu_selavu/features/categories/presentation/cubit/category_cubit.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:varavu_selavu/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_state.dart';

// Fake implementations for testing without SQLite binary dependency in pure test runner
class FakeTransactionRepository implements TransactionRepository {
  final List<AppTransaction> _items = [];

  @override
  Future<void> addTransaction(AppTransaction transaction) async {
    _items.add(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _items.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<AppTransaction>> getAllTransactions() async => _items;

  @override
  Future<List<Map<String, dynamic>>> getCategorySpendingByMonth(String yearMonthKey) async => [];

  @override
  Future<List<AppTransaction>> getRecentTransactions({int limit = 5}) async => _items.take(limit).toList();

  @override
  Future<AppTransaction?> getTransactionById(String id) async {
    final list = _items.where((t) => t.id == id);
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<List<AppTransaction>> getTransactionsByMonth(String yearMonthKey) async {
    return _items.where((t) => t.date.toIso8601String().startsWith(yearMonthKey)).toList();
  }

  @override
  Future<void> updateTransaction(AppTransaction transaction) async {
    final idx = _items.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) {
      _items[idx] = transaction;
    }
  }
}

class FakeGetCategoriesUseCase implements GetCategoriesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Category>> call({CategoryType? type}) async {
    final list = [
      Category(
        id: 'exp_food',
        name: 'Food',
        icon: 'restaurant',
        color: 0xFFEF4444,
        type: CategoryType.expense,
        createdAt: DateTime(2026),
      ),
      Category(
        id: 'inc_salary',
        name: 'Salary',
        icon: 'account_balance_wallet',
        color: 0xFF059669,
        type: CategoryType.income,
        createdAt: DateTime(2026),
      ),
    ];
    if (type != null) return list.where((c) => c.type == type).toList();
    return list;
  }
}

class FakeAddCategoryUseCase implements AddCategoryUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> call(Category category) async {}
}

void main() {
  group('TransactionBloc BLoC Unit Tests', () {
    late FakeTransactionRepository fakeRepo;
    late GetTransactionsByMonthUseCase getTxs;
    late AddTransactionUseCase addTx;
    late UpdateTransactionUseCase updateTx;
    late DeleteTransactionUseCase deleteTx;

    setUp(() {
      fakeRepo = FakeTransactionRepository();
      getTxs = GetTransactionsByMonthUseCase(fakeRepo);
      addTx = AddTransactionUseCase(fakeRepo);
      updateTx = UpdateTransactionUseCase(fakeRepo);
      deleteTx = DeleteTransactionUseCase(fakeRepo);
    });

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionLoading, TransactionLoaded] when LoadTransactions is added',
      build: () => TransactionBloc(
        getTransactionsByMonthUseCase: getTxs,
        addTransactionUseCase: addTx,
        updateTransactionUseCase: updateTx,
        deleteTransactionUseCase: deleteTx,
      ),
      act: (bloc) => bloc.add(const LoadTransactions(monthKey: '2026-09')),
      expect: () => [
        isA<TransactionLoading>(),
        isA<TransactionLoaded>().having((s) => s.currentMonthKey, 'currentMonthKey', '2026-09'),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [TransactionOperationSuccess] when AddTransactionSubmitted is added with valid transaction',
      build: () => TransactionBloc(
        getTransactionsByMonthUseCase: getTxs,
        addTransactionUseCase: addTx,
        updateTransactionUseCase: updateTx,
        deleteTransactionUseCase: deleteTx,
      ),
      act: (bloc) {
        final tx = AppTransaction(
          id: 'tx1',
          type: TransactionType.expense,
          amount: 500,
          categoryId: 'exp_food',
          date: DateTime(2026, 9, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        bloc.add(AddTransactionSubmitted(tx));
      },
      expect: () => [
        isA<TransactionOperationSuccess>(),
      ],
    );
  });

  group('CategoryCubit Unit Tests', () {
    blocTest<CategoryCubit, CategoryState>(
      'emits [CategoryLoading, CategoryLoaded] on loadCategories()',
      build: () => CategoryCubit(
        getCategoriesUseCase: FakeGetCategoriesUseCase(),
        addCategoryUseCase: FakeAddCategoryUseCase(),
      ),
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>().having((s) => s.allCategories.length, 'total categories', 2),
      ],
    );
  });
}
