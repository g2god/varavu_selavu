import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/constants/app_constants.dart';
import 'package:varavu_selavu/core/di/injection.dart';
import 'package:varavu_selavu/core/extensions/date_extensions.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';
import 'package:varavu_selavu/features/dashboard/domain/repositories/monthly_config_repository.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onCompleted;

  const WelcomePage({super.key, required this.onCompleted});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _balanceController = TextEditingController();

  Future<void> _onGetStarted() async {
    final balanceText = _balanceController.text.trim();
    final balance = double.tryParse(balanceText) ?? 0.0;

    final currentMonthKey = DateTime.now().toYearMonthKey();
    final configRepo = sl<MonthlyConfigRepository>();
    await configRepo.setStartingBalance(currentMonthKey, balance);

    widget.onCompleted();
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Calm App Badge
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 40, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome to\nVaravu Selavu',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'A minimal, butter-smooth personal money tracker. No ads, no cloud sync, 100% private to your device.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Starting Balance input
              Text(
                'STARTING BALANCE FOR ${DateTime.now().toMonthYearString().toUpperCase()}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.onSurface.withAlpha(130),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '${AppConstants.defaultCurrencySymbol} ',
                  prefixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  hintText: '0',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can update this or adjust months anytime in the dashboard.',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(110)),
              ),
              const Spacer(),

              // Get Started Button
              ElevatedButton(
                onPressed: _onGetStarted,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
