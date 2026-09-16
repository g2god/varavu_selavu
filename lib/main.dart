import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:varavu_selavu/core/constants/app_constants.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/theme/app_theme.dart';
import 'package:varavu_selavu/core/theme/theme_cubit.dart';

import 'package:varavu_selavu/features/categories/presentation/cubit/category_cubit.dart';
import 'package:varavu_selavu/features/navigation/presentation/pages/main_navigation_scaffold.dart';
import 'package:varavu_selavu/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:varavu_selavu/features/security/presentation/bloc/security_bloc.dart';
import 'package:varavu_selavu/features/security/presentation/pages/lock_screen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const VaravuSelavuApp());
}

class VaravuSelavuApp extends StatefulWidget {
  const VaravuSelavuApp({super.key});

  @override
  State<VaravuSelavuApp> createState() => _VaravuSelavuAppState();
}

class _VaravuSelavuAppState extends State<VaravuSelavuApp> with WidgetsBindingObserver {
  late final SecurityBloc _securityBloc;
  bool _isOnboardingDone = false;
  bool _isInitChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _securityBloc = sl<SecurityBloc>()..add(CheckSecurityStatus());
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final storage = sl<FlutterSecureStorage>();
    final done = await storage.read(key: AppConstants.keyOnboardingCompleted);
    setState(() {
      _isOnboardingDone = done == 'true';
      _isInitChecked = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _securityBloc.add(LockApp());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _finishOnboarding() async {
    final storage = sl<FlutterSecureStorage>();
    await storage.write(key: AppConstants.keyOnboardingCompleted, value: 'true');
    setState(() {
      _isOnboardingDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _securityBloc),
        BlocProvider.value(value: sl<CategoryCubit>()..loadCategories()),
        BlocProvider.value(value: sl<ThemeCubit>()..loadThemeMode()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: !_isInitChecked
                ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                : BlocBuilder<SecurityBloc, SecurityState>(
                    builder: (context, state) {
                      // If App Lock is enabled and locked
                      if (state is SecurityLocked) {
                        return LockScreenPage(
                          isBiometricsAvailable: state.isBiometricsEnabled,
                          errorMessage: state.errorMessage,
                          onPinSubmitted: (pin) {
                            _securityBloc.add(UnlockWithPinSubmitted(pin));
                          },
                          onBiometricsRequested: () {
                            _securityBloc.add(UnlockWithBiometricsRequested());
                          },
                        );
                      }

                      // First-launch minimal onboarding
                      if (!_isOnboardingDone) {
                        return WelcomePage(
                          onCompleted: _finishOnboarding,
                        );
                      }

                      // Main app navigation
                      return const MainNavigationScaffold();
                    },
                  ),
          );
        },
      ),
    );
  }
}
