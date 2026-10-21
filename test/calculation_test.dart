import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_truck/services/calculation.dart';

void main() {
  test('Contoh utama dan format Indonesia', () {
    final value = Calculation(
      volume: parseVolume('24,17'),
      price: parseMoney('370.000'),
    );
    expect(value.total, 8942900);
    expect(rupiah(value.total), 'Rp8.942.900');
    expect(volumeText(value.volume), '24,17');
    expect(value.profit, isNull);
  });
  test('Modal per rit: 8.200.000 / 26,46 m³', () {
    final value = Calculation(
      volume: parseVolume('26,46'),
      price: 0,
      ritCost: parseMoney('8.200.000'),
      salePrice: parseMoney('350.000'),
      destination: 'Proyek Bekasi',
    );
    expect(value.costPerM3, 309902);
    expect(value.subtotal, 8200000);
    expect(value.total, 8200000);
    expect(value.sales, 9261000);
    expect(value.profit, 1061000);
    expect(value.destination, 'Proyek Bekasi');
  });
  test('Biaya, diskon dan keuntungan tidak dihitung ganda', () {
    final value = Calculation(
      volume: parseVolume('2.5'),
      price: 100,
      extra: 20,
      shipping: 30,
      discount: 10,
      salePrice: 200,
    );
    expect(value.subtotal, 250);
    expect(value.total, 290);
    expect(value.sales, 500);
    expect(value.profit, 210);
    expect(Calculation(volume: 500000, price: 1).total, 1);
    expect(Calculation(volume: 1000000, price: 100, salePrice: 0).profit, -100);
  });
  test('Input kosong, negatif, terlalu besar, ambigu ditolak', () {
    for (final input in [
      '',
      '0',
      '-1',
      'abc',
      '1,1234567',
      '1.000,5',
      '1000001',
    ]) {
      expect(() => parseVolume(input), throwsFormatException);
    }
    for (final input in ['', '-1', '1,5', '12.34', '1000000001']) {
      expect(() => parseMoney(input), throwsFormatException);
    }
    expect(parseMoney('', optional: true), 0);
    expect(
      () => Calculation(volume: 1000000, price: 10, discount: 11),
      throwsFormatException,
    );
  });
}
