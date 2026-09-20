import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';

class LockScreenPage extends StatefulWidget {
  final VoidCallback? onBiometricsRequested;
  final ValueChanged<String> onPinSubmitted;
  final bool isBiometricsAvailable;
  final String? errorMessage;

  const LockScreenPage({
    super.key,
    this.onBiometricsRequested,
    required this.onPinSubmitted,
    this.isBiometricsAvailable = false,
    this.errorMessage,
  });

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  String _enteredPin = '';

  @override
  void initState() {
    super.initState();
    if (widget.isBiometricsAvailable && widget.onBiometricsRequested != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onBiometricsRequested!();
      });
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += digit);
      if (_enteredPin.length == 4) {
        widget.onPinSubmitted(_enteredPin);
        setState(() => _enteredPin = '');
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Lock Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline_rounded, size: 32, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Varavu Selavu',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your 4-digit PIN to continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
              const SizedBox(height: 32),

              // PIN Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? theme.colorScheme.primary : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? theme.colorScheme.primary : theme.colorScheme.outline.withAlpha(120),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (widget.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.errorMessage!,
                  style: const TextStyle(color: AppColors.expense, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              // Numeric Keypad
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        widget.isBiometricsAvailable
                            ? _buildIconButton(
                                icon: Icons.fingerprint,
                                onTap: widget.onBiometricsRequested ?? () {},
                              )
                            : const SizedBox(width: 64, height: 64),
                        _buildKeypadButton('0'),
                        _buildIconButton(
                          icon: Icons.backspace_outlined,
                          onTap: _onDeletePressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKeypadButton(d)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardTheme.color,
          border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(40)),
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Icon(icon, size: 26),
      ),
    );
  }
}
