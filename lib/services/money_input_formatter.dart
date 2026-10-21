import 'package:flutter/services.dart';

/// Formats Rupiah input with thousand separators while typing.
///
/// Typing `100000` becomes `100.000`; pasted text like `Rp 100.000` is
/// cleaned back to digits first.
class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.length > 15) digits = digits.substring(0, 15);
    final text = _group(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static String _group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
