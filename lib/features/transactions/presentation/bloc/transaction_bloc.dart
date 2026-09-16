import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/transactions/domain/usecases/transaction_usecases.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsByMonthUseCase getTransactionsByMonthUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  TransactionBloc({
    required this.getTransactionsByMonthUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionSubmitted>(_onAddTransaction);
    on<UpdateTransactionSubmitted>(_onUpdateTransaction);
    on<DeleteTransactionSubmitted>(_onDeleteTransaction);
    on<FilterTransactionsQuery>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await getTransactionsByMonthUseCase(event.monthKey);
      emit(TransactionLoaded(
        currentMonthKey: event.monthKey,
        allTransactions: transactions,
        filteredTransactions: transactions,
      ));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionSubmitted event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await addTransactionUseCase(event.transaction);
      emit(const TransactionOperationSuccess('Transaction saved successfully'));
    } catch (e) {
      emit(TransactionError('Failed to save transaction: $e'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionSubmitted event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await updateTransactionUseCase(event.transaction);
      emit(const TransactionOperationSuccess('Transaction updated successfully'));
    } catch (e) {
      emit(TransactionError('Failed to update transaction: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionSubmitted event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await deleteTransactionUseCase(event.id);
      add(LoadTransactions(monthKey: event.monthKey));
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: $e'));
    }
  }

  void _onFilterTransactions(
    FilterTransactionsQuery event,
    Emitter<TransactionState> emit,
  ) {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      var filtered = List<AppTransaction>.from(current.allTransactions);

      // Search query filter (note or category)
      if (event.searchQuery != null && event.searchQuery!.trim().isNotEmpty) {
        final q = event.searchQuery!.toLowerCase().trim();
        filtered = filtered.where((tx) {
          final noteMatch = tx.note?.toLowerCase().contains(q) ?? false;
          final catMatch = tx.categoryName?.toLowerCase().contains(q) ?? false;
          return noteMatch || catMatch;
        }).toList();
      }

      // Type filter
      if (event.typeFilter != null) {
        filtered = filtered.where((tx) => tx.type == event.typeFilter).toList();
      }

      // Category filter
      if (event.categoryIdFilter != null && event.categoryIdFilter!.isNotEmpty) {
        filtered = filtered.where((tx) => tx.categoryId == event.categoryIdFilter).toList();
      }

      emit(current.copyWith(
        filteredTransactions: filtered,
        searchQuery: event.searchQuery,
        typeFilter: event.typeFilter,
        categoryIdFilter: event.categoryIdFilter,
      ));
    }
  }
}
