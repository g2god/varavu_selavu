import 'package:equatable/equatable.dart';
import 'package:varavu_selavu/features/transactions/domain/entities/transaction.dart';
import 'package:varavu_selavu/features/dashboard/domain/entities/monthly_summary.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String monthKey; // e.g. "2026-09"
  const LoadDashboard({required this.monthKey});

  @override
  List<Object?> get props => [monthKey];
}

class ChangeSelectedMonth extends DashboardEvent {
  final String newMonthKey;
  const ChangeSelectedMonth(this.newMonthKey);

  @override
  List<Object?> get props => [newMonthKey];
}

class UpdateStartingBalance extends DashboardEvent {
  final String monthKey;
  final double startingBalance;
  const UpdateStartingBalance({required this.monthKey, required this.startingBalance});

  @override
  List<Object?> get props => [monthKey, startingBalance];
}

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final MonthlySummary summary;
  final List<AppTransaction> recentTransactions;

  const DashboardLoaded({
    required this.summary,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [summary, recentTransactions];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
