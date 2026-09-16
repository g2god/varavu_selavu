import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:varavu_selavu/core/security/security_service.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();
  @override
  List<Object?> get props => [];
}

class CheckSecurityStatus extends SecurityEvent {}

class LockApp extends SecurityEvent {}

class UnlockWithPinSubmitted extends SecurityEvent {
  final String pin;
  const UnlockWithPinSubmitted(this.pin);

  @override
  List<Object?> get props => [pin];
}

class UnlockWithBiometricsRequested extends SecurityEvent {}

class SetupPinSubmitted extends SecurityEvent {
  final String pin;
  const SetupPinSubmitted(this.pin);

  @override
  List<Object?> get props => [pin];
}

class ToggleAppLockRequested extends SecurityEvent {
  final bool enabled;
  const ToggleAppLockRequested(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleBiometricsRequested extends SecurityEvent {
  final bool enabled;
  const ToggleBiometricsRequested(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class DisableSecurityRequested extends SecurityEvent {}

abstract class SecurityState extends Equatable {
  final bool isAppLockEnabled;
  final bool isBiometricsEnabled;
  final bool hasPinSet;

  const SecurityState({
    this.isAppLockEnabled = false,
    this.isBiometricsEnabled = false,
    this.hasPinSet = false,
  });

  @override
  List<Object?> get props => [isAppLockEnabled, isBiometricsEnabled, hasPinSet];
}

class SecurityInitial extends SecurityState {
  const SecurityInitial() : super();
}

class SecurityUnlocked extends SecurityState {
  const SecurityUnlocked({
    required super.isAppLockEnabled,
    required super.isBiometricsEnabled,
    required super.hasPinSet,
  });
}

class SecurityLocked extends SecurityState {
  final String? errorMessage;

  const SecurityLocked({
    required super.isAppLockEnabled,
    required super.isBiometricsEnabled,
    required super.hasPinSet,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  final SecurityService securityService;

  SecurityBloc({required this.securityService}) : super(const SecurityInitial()) {
    on<CheckSecurityStatus>(_onCheckSecurityStatus);
    on<LockApp>(_onLockApp);
    on<UnlockWithPinSubmitted>(_onUnlockWithPin);
    on<UnlockWithBiometricsRequested>(_onUnlockWithBiometrics);
    on<SetupPinSubmitted>(_onSetupPin);
    on<ToggleAppLockRequested>(_onToggleAppLock);
    on<ToggleBiometricsRequested>(_onToggleBiometrics);
    on<DisableSecurityRequested>(_onDisableSecurity);
  }

  Future<void> _onCheckSecurityStatus(
    CheckSecurityStatus event,
    Emitter<SecurityState> emit,
  ) async {
    final isLockedEnabled = await securityService.isAppLockEnabled();
    final isBioEnabled = await securityService.isBiometricsEnabled();
    final hasPin = await securityService.hasPinSet();

    if (isLockedEnabled && hasPin) {
      emit(SecurityLocked(
        isAppLockEnabled: isLockedEnabled,
        isBiometricsEnabled: isBioEnabled,
        hasPinSet: hasPin,
      ));
    } else {
      emit(SecurityUnlocked(
        isAppLockEnabled: isLockedEnabled,
        isBiometricsEnabled: isBioEnabled,
        hasPinSet: hasPin,
      ));
    }
  }

  void _onLockApp(LockApp event, Emitter<SecurityState> emit) {
    if (state.isAppLockEnabled && state.hasPinSet) {
      emit(SecurityLocked(
        isAppLockEnabled: state.isAppLockEnabled,
        isBiometricsEnabled: state.isBiometricsEnabled,
        hasPinSet: state.hasPinSet,
      ));
    }
  }

  Future<void> _onUnlockWithPin(
    UnlockWithPinSubmitted event,
    Emitter<SecurityState> emit,
  ) async {
    final isValid = await securityService.verifyPin(event.pin);
    if (isValid) {
      emit(SecurityUnlocked(
        isAppLockEnabled: state.isAppLockEnabled,
        isBiometricsEnabled: state.isBiometricsEnabled,
        hasPinSet: state.hasPinSet,
      ));
    } else {
      emit(SecurityLocked(
        isAppLockEnabled: state.isAppLockEnabled,
        isBiometricsEnabled: state.isBiometricsEnabled,
        hasPinSet: state.hasPinSet,
        errorMessage: 'Incorrect PIN. Please try again.',
      ));
    }
  }

  Future<void> _onUnlockWithBiometrics(
    UnlockWithBiometricsRequested event,
    Emitter<SecurityState> emit,
  ) async {
    if (!state.isBiometricsEnabled) return;

    final authenticated = await securityService.authenticateWithBiometrics();
    if (authenticated) {
      emit(SecurityUnlocked(
        isAppLockEnabled: state.isAppLockEnabled,
        isBiometricsEnabled: state.isBiometricsEnabled,
        hasPinSet: state.hasPinSet,
      ));
    } else {
      // Biometric cancelled or failed -> stays on lock screen with fallback to PIN
      emit(SecurityLocked(
        isAppLockEnabled: state.isAppLockEnabled,
        isBiometricsEnabled: state.isBiometricsEnabled,
        hasPinSet: state.hasPinSet,
        errorMessage: 'Biometric verification unsuccessful. Please enter PIN.',
      ));
    }
  }

  Future<void> _onSetupPin(
    SetupPinSubmitted event,
    Emitter<SecurityState> emit,
  ) async {
    await securityService.setPin(event.pin);
    await securityService.setAppLockEnabled(true);
    emit(SecurityUnlocked(
      isAppLockEnabled: true,
      isBiometricsEnabled: state.isBiometricsEnabled,
      hasPinSet: true,
    ));
  }

  Future<void> _onToggleAppLock(
    ToggleAppLockRequested event,
    Emitter<SecurityState> emit,
  ) async {
    await securityService.setAppLockEnabled(event.enabled);
    emit(SecurityUnlocked(
      isAppLockEnabled: event.enabled,
      isBiometricsEnabled: state.isBiometricsEnabled,
      hasPinSet: state.hasPinSet,
    ));
  }

  Future<void> _onToggleBiometrics(
    ToggleBiometricsRequested event,
    Emitter<SecurityState> emit,
  ) async {
    await securityService.setBiometricsEnabled(event.enabled);
    emit(SecurityUnlocked(
      isAppLockEnabled: state.isAppLockEnabled,
      isBiometricsEnabled: event.enabled,
      hasPinSet: state.hasPinSet,
    ));
  }

  Future<void> _onDisableSecurity(
    DisableSecurityRequested event,
    Emitter<SecurityState> emit,
  ) async {
    await securityService.removePin();
    emit(const SecurityUnlocked(
      isAppLockEnabled: false,
      isBiometricsEnabled: false,
      hasPinSet: false,
    ));
  }
}
