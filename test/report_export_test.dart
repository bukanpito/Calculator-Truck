import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_truck/models/load_item.dart';
import 'package:calculator_truck/services/calculation.dart';
import 'package:calculator_truck/services/report_export.dart';

void main() {
  test('Excel berisi transaksi dan total numerik; PDF valid', () async {
    final loads = [
      LoadItem(
        id: 42,
        material: 'Pasir',
        createdAt: '2026-10-19T10:30:00',
        date: '2026-10-19',
        value: Calculation(
          volume: parseVolume('24,17'),
          price: 370000,
          salePrice: 400000,
        ),
      ),
    ];
    final excel = Excel.decodeBytes(ReportExport.xlsx('2026-10-19', loads));
    final rows = excel['Muatan'].rows;
    expect((rows[2][0]!.value as IntCellValue).value, 1);
    expect(rows[2][3]!.value.toString(), 'Pasir');
    expect((rows[2][9]!.value as IntCellValue).value, 8942900);
    expect((rows[3][9]!.value as IntCellValue).value, 8942900);
    expect(
      rows[2][9]!.cellStyle!.numberFormat,
      const CustomNumericNumFormat(formatCode: '"Rp" #,##0'),
    );
    expect(
      rows[3][9]!.cellStyle!.numberFormat,
      const CustomNumericNumFormat(formatCode: '"Rp" #,##0'),
    );
    expect((rows[3][12]!.value as IntCellValue).value, 725100);
    final pdf = await ReportExport.pdf('2026-10-19', loads);
    expect(ascii.decode(pdf.take(4).toList()), '%PDF');
  });
}
