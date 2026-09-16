import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:varavu_selavu/core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final FlutterSecureStorage secureStorage;

  ThemeCubit({required this.secureStorage}) : super(ThemeMode.system);

  Future<void> loadThemeMode() async {
    try {
      final saved = await secureStorage.read(key: AppConstants.keyThemeMode);
      if (saved != null) {
        switch (saved) {
          case 'light':
            emit(ThemeMode.light);
            break;
          case 'dark':
            emit(ThemeMode.dark);
            break;
          default:
            emit(ThemeMode.system);
            break;
        }
      }
    } catch (_) {
      emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      final value = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await secureStorage.write(key: AppConstants.keyThemeMode, value: value);
    } catch (_) {}
  }
}
