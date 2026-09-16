import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:varavu_selavu/core/constants/app_constants.dart';

abstract class SecurityService {
  Future<bool> isAppLockEnabled();
  Future<void> setAppLockEnabled(bool enabled);

  Future<bool> isBiometricsEnabled();
  Future<void> setBiometricsEnabled(bool enabled);

  Future<bool> hasPinSet();
  Future<bool> verifyPin(String pin);
  Future<void> setPin(String pin);
  Future<void> removePin();

  Future<bool> canCheckBiometrics();
  Future<bool> authenticateWithBiometrics();
}

class SecurityServiceImpl implements SecurityService {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  SecurityServiceImpl({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<bool> isAppLockEnabled() async {
    final val = await _secureStorage.read(key: AppConstants.keyAppLockEnabled);
    return val == 'true';
  }

  @override
  Future<void> setAppLockEnabled(bool enabled) async {
    await _secureStorage.write(
      key: AppConstants.keyAppLockEnabled,
      value: enabled.toString(),
    );
  }

  @override
  Future<bool> isBiometricsEnabled() async {
    final val = await _secureStorage.read(key: AppConstants.keyBiometricsEnabled);
    return val == 'true';
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _secureStorage.write(
      key: AppConstants.keyBiometricsEnabled,
      value: enabled.toString(),
    );
  }

  @override
  Future<bool> hasPinSet() async {
    final hash = await _secureStorage.read(key: AppConstants.keyPinHash);
    return hash != null && hash.isNotEmpty;
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: AppConstants.keyPinHash);
    final storedSalt = await _secureStorage.read(key: AppConstants.keyPinSalt);

    if (storedHash == null || storedSalt == null) return false;

    final computedHash = _hashPin(pin, storedSalt);
    return computedHash == storedHash;
  }

  @override
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await _secureStorage.write(key: AppConstants.keyPinSalt, value: salt);
    await _secureStorage.write(key: AppConstants.keyPinHash, value: hash);
  }

  @override
  Future<void> removePin() async {
    await _secureStorage.delete(key: AppConstants.keyPinSalt);
    await _secureStorage.delete(key: AppConstants.keyPinHash);
    await setAppLockEnabled(false);
    await setBiometricsEnabled(false);
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await canCheckBiometrics();
      if (!canCheck) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to open Varavu Selavu',
      );
    } catch (_) {
      return false;
    }
  }

  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
