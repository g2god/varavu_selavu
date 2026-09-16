import 'package:equatable/equatable.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String monthKey;
  const LoadTransactions({required this.monthKey});

  @override
  List<Object?> get props => [monthKey];
}

class AddTransactionSubmitted extends TransactionEvent {
  final AppTransaction transaction;
  const AddTransactionSubmitted(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionSubmitted extends TransactionEvent {
  final AppTransaction transaction;
  const UpdateTransactionSubmitted(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionSubmitted extends TransactionEvent {
  final String id;
  final String monthKey;
  const DeleteTransactionSubmitted({required this.id, required this.monthKey});

  @override
  List<Object?> get props => [id, monthKey];
}

class FilterTransactionsQuery extends TransactionEvent {
  final String? searchQuery;
  final TransactionType? typeFilter;
  final String? categoryIdFilter;

  const FilterTransactionsQuery({
    this.searchQuery,
    this.typeFilter,
    this.categoryIdFilter,
  });

  @override
  List<Object?> get props => [searchQuery, typeFilter, categoryIdFilter];
}
