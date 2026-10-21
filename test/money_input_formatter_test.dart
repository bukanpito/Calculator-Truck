import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_truck/services/calculation.dart';
import 'package:calculator_truck/services/money_input_formatter.dart';

void main() {
  const formatter = MoneyInputFormatter();
  TextEditingValue format(String text) => formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );

  test('Menambahkan titik ribuan saat mengetik', () {
    expect(format('100000').text, '100.000');
    expect(format('1000').text, '1.000');
    expect(format('999').text, '999');
    expect(format('8200000').text, '8.200.000');
    expect(format('1234567890').text, '1.234.567.890');
  });

  test('Membersihkan input tempelan dan nol di depan', () {
    expect(format('Rp 100.000').text, '100.000');
    expect(format('0005000').text, '5.000');
    expect(format('').text, '');
    expect(format('abc').text, '');
  });

  test('Hasil formatter tetap bisa dibaca parseMoney', () {
    expect(parseMoney(format('350000').text), 350000);
    expect(parseMoney(format('8200000').text), 8200000);
  });
}
