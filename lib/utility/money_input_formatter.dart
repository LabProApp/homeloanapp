import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats monetary input in Indian number style (e.g. 12,34,567) as the user
/// types. Controllers that use this formatter will contain commas; always use
/// [parse] / [parseInt] to extract the raw value before arithmetic.
class MoneyInputFormatter extends TextInputFormatter {
  static final _fmt = NumberFormat('#,##,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final number = int.tryParse(digits);
    if (number == null) return oldValue;

    final formatted = _fmt.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Strip commas and parse as double. Returns null for empty / invalid input.
  static double? parse(String text) =>
      double.tryParse(text.replaceAll(',', '').trim());

  /// Strip commas and parse as int. Returns null for empty / invalid input.
  static int? parseInt(String text) =>
      int.tryParse(text.replaceAll(',', '').trim());

  /// Format a number for pre-filling a controller.
  static String format(num value) => _fmt.format(value.toInt());
}
