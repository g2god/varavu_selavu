import 'package:flutter/material.dart';
import 'package:varavu_selavu/core/theme/app_colors.dart';

class PinSetupPage extends StatefulWidget {
  final ValueChanged<String> onPinSet;

  const PinSetupPage({super.key, required this.onPinSet});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _error;

  void _onDigit(String d) {
    if (!_isConfirming) {
      if (_pin.length < 4) {
        setState(() => _pin += d);
        if (_pin.length == 4) {
          setState(() {
            _isConfirming = true;
            _error = null;
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin += d);
        if (_confirmPin.length == 4) {
          if (_confirmPin == _pin) {
            widget.onPinSet(_pin);
            Navigator.pop(context, true);
          } else {
            setState(() {
              _error = 'PINs do not match. Please try again.';
              _pin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
      }
    }
  }

  void _onDelete() {
    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(
          () => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1),
        );
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      appBar: AppBar(title: const Text('Setup App PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                _isConfirming ? 'Confirm your PIN' : 'Create a 4-digit PIN',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? 'Re-enter your 4-digit PIN to confirm'
                    : 'This PIN will be required whenever you open the app',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final isFilled = i < activePin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isFilled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withAlpha(120),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              // Keypad
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 64, height: 64),
                        _buildBtn('0'),
                        InkWell(
                          onTap: _onDelete,
                          borderRadius: BorderRadius.circular(32),
                          child: const SizedBox(
                            width: 64,
                            height: 64,
                            child: Icon(Icons.backspace_outlined, size: 24),
                          ),
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

  Widget _buildRow(List<String> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((e) => _buildBtn(e)).toList(),
    );
  }

  Widget _buildBtn(String digit) {
    return InkWell(
      onTap: () => _onDigit(digit),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardTheme.color,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(40),
          ),
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
