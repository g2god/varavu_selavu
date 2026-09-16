import 'package:equatable/equatable.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionOperationSuccess extends TransactionState {
  final String message;
  const TransactionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionLoaded extends TransactionState {
  final String currentMonthKey;
  final List<AppTransaction> allTransactions;
  final List<AppTransaction> filteredTransactions;
  final String? searchQuery;
  final TransactionType? typeFilter;
  final String? categoryIdFilter;

  const TransactionLoaded({
    required this.currentMonthKey,
    required this.allTransactions,
    required this.filteredTransactions,
    this.searchQuery,
    this.typeFilter,
    this.categoryIdFilter,
  });

  TransactionLoaded copyWith({
    String? currentMonthKey,
    List<AppTransaction>? allTransactions,
    List<AppTransaction>? filteredTransactions,
    String? searchQuery,
    TransactionType? typeFilter,
    String? categoryIdFilter,
  }) {
    return TransactionLoaded(
      currentMonthKey: currentMonthKey ?? this.currentMonthKey,
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      categoryIdFilter: categoryIdFilter ?? this.categoryIdFilter,
    );
  }

  @override
  List<Object?> get props => [
        currentMonthKey,
        allTransactions,
        filteredTransactions,
        searchQuery,
        typeFilter,
        categoryIdFilter,
      ];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
