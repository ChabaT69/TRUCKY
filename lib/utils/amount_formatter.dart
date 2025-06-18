import 'package:trucky/services/currency_service.dart';

// Helper function to format amount with currency symbol after the amount
String formatAmountWithCurrencyAfter(double amount, String currencyCode) {
  final formatted = CurrencyService.formatAmount(amount, currencyCode);

  // Handle DH currency symbol specifically
  if (formatted.startsWith('DH')) {
    return formatted.substring(2) + 'DH';
  }

  // Handle other currency symbols
  if (formatted.startsWith('\$') ||
      formatted.startsWith('€') ||
      formatted.startsWith('£')) {
    return formatted.substring(1) + formatted[0];
  }

  // If formatted string has currency code at the end (like "10.00 USD")
  if (formatted.split(' ').length > 1) {
    final parts = formatted.split(' ');
    return '${parts[0]} ${parts[1]}';
  }

  // Default case: return as-is
  return formatted;
}
