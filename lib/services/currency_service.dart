import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  static const String defaultCurrency = 'MAD'; // Moroccan Dirham as default
  static String? _cachedCurrency;

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

  static String formatAmount(double amount, String currencyCode) {
    final symbol = _currencySymbols[currencyCode] ?? currencyCode;
    return '${amount.toStringAsFixed(2)} $symbol';
  }

  static const Map<String, String> _currencySymbols = {
    'MAD': 'DH', // Moroccan Dirham
    'EUR': '€', // Euro
    'USD': '\$', // US Dollar
  };
}
