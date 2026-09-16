import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/features/dashboard/domain/repositories/monthly_config_repository.dart';
import 'package:varavu_selavu/features/dashboard/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:varavu_selavu/features/transactions/domain/usecases/transaction_usecases.dart';
import 'dashboard_event_state.dart';

export 'dashboard_event_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetMonthlySummaryUseCase getMonthlySummaryUseCase;
  final GetRecentTransactionsUseCase getRecentTransactionsUseCase;
  final MonthlyConfigRepository monthlyConfigRepository;

  DashboardBloc({
    required this.getMonthlySummaryUseCase,
    required this.getRecentTransactionsUseCase,
    required this.monthlyConfigRepository,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<ChangeSelectedMonth>(_onChangeSelectedMonth);
    on<UpdateStartingBalance>(_onUpdateStartingBalance);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final summary = await getMonthlySummaryUseCase(event.monthKey);
      final recents = await getRecentTransactionsUseCase(limit: 5);
      emit(DashboardLoaded(
        summary: summary,
        recentTransactions: recents,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: $e'));
    }
  }

  Future<void> _onChangeSelectedMonth(
    ChangeSelectedMonth event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final summary = await getMonthlySummaryUseCase(event.newMonthKey);
      final recents = await getRecentTransactionsUseCase(limit: 5);
      emit(DashboardLoaded(
        summary: summary,
        recentTransactions: recents,
      ));
    } catch (e) {
      emit(DashboardError('Failed to update month: $e'));
    }
  }

  Future<void> _onUpdateStartingBalance(
    UpdateStartingBalance event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await monthlyConfigRepository.setStartingBalance(event.monthKey, event.startingBalance);
      add(LoadDashboard(monthKey: event.monthKey));
    } catch (e) {
      emit(DashboardError('Failed to update starting balance: $e'));
    }
  }
}
