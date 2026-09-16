import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/features/analytics/domain/usecases/get_analytics_data_usecase.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;
  const AnalyticsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetAnalyticsDataUseCase getAnalyticsDataUseCase;

  AnalyticsCubit({required this.getAnalyticsDataUseCase}) : super(AnalyticsInitial());

  Future<void> loadAnalytics(String monthKey) async {
    emit(AnalyticsLoading());
    try {
      final data = await getAnalyticsDataUseCase(monthKey);
      emit(AnalyticsLoaded(data));
    } catch (e) {
      emit(AnalyticsError('Failed to load analytics: $e'));
    }
  }
}
