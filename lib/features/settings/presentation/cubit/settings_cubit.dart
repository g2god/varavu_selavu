import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:varavu_selavu/core/security/security_service.dart';
import 'package:varavu_selavu/core/utils/file_storage_helper.dart';
import 'package:varavu_selavu/features/dashboard/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:varavu_selavu/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:varavu_selavu/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:varavu_selavu/features/settings/data/services/data_portability_service.dart';

abstract class SettingsState extends Equatable {
  final bool isAppLockEnabled;
  final bool isBiometricsEnabled;
  final bool hasPinSet;
  final bool canUseBiometrics;

  const SettingsState({
    this.isAppLockEnabled = false,
    this.isBiometricsEnabled = false,
    this.hasPinSet = false,
    this.canUseBiometrics = false,
  });

  @override
  List<Object?> get props => [
    isAppLockEnabled,
    isBiometricsEnabled,
    hasPinSet,
    canUseBiometrics,
  ];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required super.isAppLockEnabled,
    required super.isBiometricsEnabled,
    required super.hasPinSet,
    required super.canUseBiometrics,
  });

  SettingsLoaded copyWith({
    bool? isAppLockEnabled,
    bool? isBiometricsEnabled,
    bool? hasPinSet,
    bool? canUseBiometrics,
  }) {
    return SettingsLoaded(
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      hasPinSet: hasPinSet ?? this.hasPinSet,
      canUseBiometrics: canUseBiometrics ?? this.canUseBiometrics,
    );
  }
}

class SettingsActionInProgress extends SettingsState {
  final String actionMessage;
  const SettingsActionInProgress(this.actionMessage);

  @override
  List<Object?> get props => [actionMessage];
}

class SettingsActionSuccess extends SettingsState {
  final String message;
  const SettingsActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsActionError extends SettingsState {
  final String message;
  const SettingsActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsCubit extends Cubit<SettingsState> {
  final SecurityService securityService;
  final DataPortabilityService dataPortabilityService;
  final GetMonthlySummaryUseCase getMonthlySummaryUseCase;
  final GetTransactionsByMonthUseCase getTransactionsByMonthUseCase;
  final TransactionRepository transactionRepository;

  SettingsCubit({
    required this.securityService,
    required this.dataPortabilityService,
    required this.getMonthlySummaryUseCase,
    required this.getTransactionsByMonthUseCase,
    required this.transactionRepository,
  }) : super(SettingsInitial());

  Future<void> loadSettings() async {
    final isLocked = await securityService.isAppLockEnabled();
    final isBio = await securityService.isBiometricsEnabled();
    final hasPin = await securityService.hasPinSet();
    final canBio = await securityService.canCheckBiometrics();

    emit(
      SettingsLoaded(
        isAppLockEnabled: isLocked,
        isBiometricsEnabled: isBio,
        hasPinSet: hasPin,
        canUseBiometrics: canBio,
      ),
    );
  }

  Future<void> toggleAppLock(bool value) async {
    await securityService.setAppLockEnabled(value);
    await loadSettings();
  }

  Future<void> toggleBiometrics(bool value) async {
    await securityService.setBiometricsEnabled(value);
    await loadSettings();
  }

  Future<void> exportPdfReport(String monthKey) async {
    emit(const SettingsActionInProgress('Generating PDF statement...'));
    try {
      final summary = await getMonthlySummaryUseCase(monthKey);
      final transactions = await getTransactionsByMonthUseCase(monthKey);

      final pdfBytes = await dataPortabilityService.generateMonthlyPdf(
        summary: summary,
        transactions: transactions,
      );

      final savedFile = await FileStorageHelper.saveBinaryFile(
        fileName: 'Varavu_Selavu_Report_$monthKey.pdf',
        bytes: pdfBytes,
      );

      emit(SettingsActionSuccess('PDF saved to: ${savedFile.path}'));
      await loadSettings();
    } catch (e) {
      emit(SettingsActionError('Failed to generate PDF: $e'));
      await loadSettings();
    }
  }

  Future<void> exportCsv() async {
    emit(const SettingsActionInProgress('Exporting CSV...'));
    try {
      final allTransactions = await transactionRepository.getAllTransactions();
      final csvString = dataPortabilityService.generateCsv(allTransactions);

      final fileName =
          'varavu_selavu_transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
      final savedFile = await FileStorageHelper.saveTextFile(
        fileName: fileName,
        content: csvString,
      );

      emit(SettingsActionSuccess('CSV saved to: ${savedFile.path}'));
      await loadSettings();
    } catch (e) {
      emit(SettingsActionError('Failed to export CSV: $e'));
      await loadSettings();
    }
  }

  Future<void> createBackup() async {
    emit(const SettingsActionInProgress('Creating backup file...'));
    try {
      final jsonBackup = await dataPortabilityService.createBackupJson();
      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/varavu_selavu_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonBackup);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Varavu Selavu Database Backup',
        ),
      );
      emit(const SettingsActionSuccess('Backup exported successfully.'));
      await loadSettings();
    } catch (e) {
      emit(SettingsActionError('Failed to create backup: $e'));
      await loadSettings();
    }
  }

  Future<void> restoreBackup() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty || files.first.path == null) {
        return; // User cancelled
      }

      emit(const SettingsActionInProgress('Restoring data...'));
      final filePath = files.first.path!;
      final file = File(filePath);
      final jsonString = await file.readAsString();

      final counts = await dataPortabilityService.restoreBackupJson(jsonString);

      emit(
        SettingsActionSuccess(
          'Restored ${counts['transactions']} transactions and ${counts['categories']} categories successfully.',
        ),
      );
      await loadSettings();
    } catch (e) {
      emit(SettingsActionError('Restore failed: $e'));
      await loadSettings();
    }
  }
}
