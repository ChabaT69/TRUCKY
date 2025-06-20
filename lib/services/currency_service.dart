import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  static const String defaultCurrency = 'MAD'; // Moroccan Dirham as default
  static String? _cachedCurrency;

  // Exchange rates relative to MAD
  static const Map<String, double> _exchangeRates = {
    'MAD': 1.0,
    'EUR': 10.8, // 1 EUR = 10.8 MAD
    'USD': 9.9, // 1 USD = 9.9 MAD
    'CAD': 7.2, // 1 CAD = 7.2 MAD
  };

  static Future<void> setCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
    _cachedCurrency = currencyCode;
  }

  static Future<String> getCurrency() async {
    if (_cachedCurrency != null) return _cachedCurrency!;
    final prefs = await SharedPreferences.getInstance();
    _cachedCurrency = prefs.getString(_currencyKey) ?? defaultCurrency;
    return _cachedCurrency!;
  }

  static String get currentCurrency {
    if (_cachedCurrency == null) {
      throw Exception('Currency not initialized. Call getCurrency() first.');
    }
    return _cachedCurrency!;
  }

  static double convertAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    // Normalize legacy 'Dollar' to 'USD'
    final normalizedFromCurrency =
        fromCurrency == 'Dollar' ? 'USD' : fromCurrency;
    final normalizedToCurrency = toCurrency == 'Dollar' ? 'USD' : toCurrency;

    if (!_exchangeRates.containsKey(normalizedFromCurrency) ||
        !_exchangeRates.containsKey(normalizedToCurrency)) {
      throw Exception('Invalid currency code.');
    }
    if (normalizedFromCurrency == normalizedToCurrency) {
      return amount;
    }

    // Convert from 'fromCurrency' to MAD (base currency)
    final amountInMAD = amount * _exchangeRates[normalizedFromCurrency]!;

    // Convert from MAD to 'toCurrency'
    final convertedAmount = amountInMAD / _exchangeRates[normalizedToCurrency]!;

    return convertedAmount;
  }

  static String formatAmount(double amount, String currencyCode) {
    final symbol = _currencySymbols[currencyCode] ?? currencyCode;
    return '${amount.toStringAsFixed(2)} $symbol';
  }

  static const Map<String, String> _currencySymbols = {
    'MAD': 'DH', // Moroccan Dirham
    'EUR': '€', // Euro
    'USD': '\$', // US Dollar
    'CAD': 'CA\$', // Canadian Dollar
  };
}
