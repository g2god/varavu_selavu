import 'package:intl/intl.dart';
import 'package:varavu_selavu/core/constants/app_constants.dart';

extension NumberFormattingX on num {
  String toCurrency({String symbol = AppConstants.defaultCurrencySymbol, int decimalDigits = 0}) {
    final format = NumberFormat.currency(
      symbol: '$symbol ',
      decimalDigits: this % 1 == 0 ? 0 : decimalDigits,
      locale: 'en_IN', // Default Indian numbering system (lakhs/crores)
    );
    return format.format(this);
  }

  String toCompactCurrency({String symbol = AppConstants.defaultCurrencySymbol}) {
    if (this >= 10000000) {
      return '$symbol ${(this / 10000000).toStringAsFixed(1)}Cr';
    } else if (this >= 100000) {
      return '$symbol ${(this / 100000).toStringAsFixed(1)}L';
    } else if (this >= 1000) {
      return '$symbol ${(this / 1000).toStringAsFixed(1)}k';
    }
    return toCurrency(symbol: symbol);
  }
}
