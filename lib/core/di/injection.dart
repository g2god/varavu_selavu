import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:varavu_selavu/core/database/app_database.dart';
import 'package:varavu_selavu/core/security/security_service.dart';
import 'package:varavu_selavu/core/theme/theme_cubit.dart';
import 'package:varavu_selavu/features/analytics/domain/usecases/get_analytics_data_usecase.dart';
import 'package:varavu_selavu/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:varavu_selavu/features/categories/data/datasources/category_local_data_source.dart';
import 'package:varavu_selavu/features/categories/data/repositories/category_repository_impl.dart';
import 'package:varavu_selavu/features/categories/domain/repositories/category_repository.dart';
import 'package:varavu_selavu/features/categories/domain/usecases/add_category_usecase.dart';
import 'package:varavu_selavu/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:varavu_selavu/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:varavu_selavu/features/categories/presentation/cubit/category_cubit.dart';
import 'package:varavu_selavu/features/dashboard/data/datasources/monthly_config_local_data_source.dart';
import 'package:varavu_selavu/features/dashboard/data/repositories/monthly_config_repository_impl.dart';
import 'package:varavu_selavu/features/dashboard/domain/repositories/monthly_config_repository.dart';
import 'package:varavu_selavu/features/dashboard/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:varavu_selavu/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:varavu_selavu/features/security/presentation/bloc/security_bloc.dart';
import 'package:varavu_selavu/features/settings/data/services/data_portability_service.dart';
import 'package:varavu_selavu/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:varavu_selavu/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:varavu_selavu/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:varavu_selavu/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:varavu_selavu/features/transactions/presentation/bloc/transaction_bloc.dart';



final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core infrastructure
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());

  sl.registerLazySingleton<SecurityService>(
    () => SecurityServiceImpl(
      secureStorage: sl<FlutterSecureStorage>(),
      localAuth: sl<LocalAuthentication>(),
    ),
  );

  sl.registerLazySingleton<DataPortabilityService>(
    () => DataPortabilityService(appDatabase: sl<AppDatabase>()),
  );

  // Data sources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(appDatabase: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(appDatabase: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<MonthlyConfigLocalDataSource>(
    () => MonthlyConfigLocalDataSourceImpl(appDatabase: sl<AppDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl<CategoryLocalDataSource>()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl<TransactionLocalDataSource>()),
  );
  sl.registerLazySingleton<MonthlyConfigRepository>(
    () => MonthlyConfigRepositoryImpl(localDataSource: sl<MonthlyConfigLocalDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<AddCategoryUseCase>(
    () => AddCategoryUseCase(sl<CategoryRepository>()),
  );
  sl.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(
      categoryRepository: sl<CategoryRepository>(),
      transactionRepository: sl<TransactionRepository>(),
    ),
  );
  sl.registerLazySingleton<GetTransactionsByMonthUseCase>(
    () => GetTransactionsByMonthUseCase(sl<TransactionRepository>()),
  );
  sl.registerLazySingleton<AddTransactionUseCase>(
    () => AddTransactionUseCase(sl<TransactionRepository>()),
  );
  sl.registerLazySingleton<UpdateTransactionUseCase>(
    () => UpdateTransactionUseCase(sl<TransactionRepository>()),
  );
  sl.registerLazySingleton<DeleteTransactionUseCase>(
    () => DeleteTransactionUseCase(sl<TransactionRepository>()),
  );
  sl.registerLazySingleton<GetRecentTransactionsUseCase>(
    () => GetRecentTransactionsUseCase(sl<TransactionRepository>()),
  );
  sl.registerLazySingleton<GetMonthlySummaryUseCase>(
    () => GetMonthlySummaryUseCase(
      transactionRepository: sl<TransactionRepository>(),
      monthlyConfigRepository: sl<MonthlyConfigRepository>(),
    ),
  );
  sl.registerLazySingleton<GetAnalyticsDataUseCase>(
    () => GetAnalyticsDataUseCase(
      transactionRepository: sl<TransactionRepository>(),
      getMonthlySummaryUseCase: sl<GetMonthlySummaryUseCase>(),
    ),
  );

  // BLoCs / Cubits (Singleton for app-wide categories, factories for screen-scoped)
  sl.registerLazySingleton<CategoryCubit>(
    () => CategoryCubit(
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
      addCategoryUseCase: sl<AddCategoryUseCase>(),
      deleteCategoryUseCase: sl<DeleteCategoryUseCase>(),
    ),
  );
  sl.registerLazySingleton<TransactionBloc>(
    () => TransactionBloc(
      getTransactionsByMonthUseCase: sl<GetTransactionsByMonthUseCase>(),
      addTransactionUseCase: sl<AddTransactionUseCase>(),
      updateTransactionUseCase: sl<UpdateTransactionUseCase>(),
      deleteTransactionUseCase: sl<DeleteTransactionUseCase>(),
    ),
  );
  sl.registerLazySingleton<DashboardBloc>(
    () => DashboardBloc(
      getMonthlySummaryUseCase: sl<GetMonthlySummaryUseCase>(),
      getRecentTransactionsUseCase: sl<GetRecentTransactionsUseCase>(),
      monthlyConfigRepository: sl<MonthlyConfigRepository>(),
    ),
  );
  sl.registerFactory<AnalyticsCubit>(
    () => AnalyticsCubit(getAnalyticsDataUseCase: sl<GetAnalyticsDataUseCase>()),
  );
  sl.registerFactory<SecurityBloc>(
    () => SecurityBloc(securityService: sl<SecurityService>()),
  );
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      securityService: sl<SecurityService>(),
      dataPortabilityService: sl<DataPortabilityService>(),
      getMonthlySummaryUseCase: sl<GetMonthlySummaryUseCase>(),
      getTransactionsByMonthUseCase: sl<GetTransactionsByMonthUseCase>(),
      transactionRepository: sl<TransactionRepository>(),
    ),
  );
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(secureStorage: sl<FlutterSecureStorage>()),
  );
}
