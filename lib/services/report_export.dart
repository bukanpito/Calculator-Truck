import 'dart:io';
import 'dart:ui' show Rect;

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/load_item.dart';

class ReportExport {
  static List<List<Object?>> rows(List<LoadItem> loads) {
    final counters = <String, int>{};
    return [
      [
        'No.',
        'Tanggal',
        'Waktu',
        'Material',
        'Lokasi kirim',
        'Volume m3',
        'Modal per rit',
        'Modal / m3',
        'Biaya tambahan',
        'Total modal',
        'Jual / m3',
        'Penjualan',
        'Keuntungan',
      ],
      for (final row in loads)
        [
          counters[row.date] = (counters[row.date] ?? 0) + 1,
          row.date,
          row.createdAt.substring(11, 16),
          row.material,
          row.value.destination,
          row.value.volume / 1000000,
          row.value.ritCost ?? row.value.subtotal,
          row.value.costPerM3,
          row.value.extra,
          row.value.total,
          row.value.salePrice,
          row.value.sales,
          row.value.profit,
        ],
      [
        'TOTAL',
        '',
        '',
        '${loads.length} transaksi',
        '',
        loads.fold<int>(0, (s, r) => s + r.value.volume) / 1000000,
        loads.fold<int>(0, (s, r) => s + (r.value.ritCost ?? r.value.subtotal)),
        null,
        loads.fold<int>(0, (s, r) => s + r.value.extra),
        loads.fold<int>(0, (s, r) => s + r.value.total),
        null,
        loads.any((r) => r.value.sales != null)
            ? loads.fold<int>(0, (s, r) => s + (r.value.sales ?? 0))
            : null,
        loads.any((r) => r.value.profit != null)
            ? loads.fold<int>(0, (s, r) => s + (r.value.profit ?? 0))
            : null,
      ],
    ];
  }

  static Uint8List xlsx(String label, List<LoadItem> loads) {
    final book = Excel.createExcel();
    final sheet = book['Muatan'];
    book.delete('Sheet1');
    sheet.appendRow([
      TextCellValue('Material Tracker $label • Rupiah • volume m3'),
    ]);
    for (final row in rows(loads)) {
      sheet.appendRow([
        for (final cell in row)
          cell == null
              ? null
              : cell is int
              ? IntCellValue(cell)
              : cell is double
              ? DoubleCellValue(cell)
              : TextCellValue('$cell'),
      ]);
    }
    final moneyStyle = CellStyle(
      numberFormat: const CustomNumericNumFormat(formatCode: '"Rp" #,##0'),
    );
    for (var row = 2; row <= loads.length + 2; row++) {
      for (var column = 6; column <= 12; column++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
        );
        if (cell.value is IntCellValue) cell.cellStyle = moneyStyle;
      }
    }
    sheet.appendRow([
      TextCellValue(
        'Keuntungan hanya untuk transaksi dengan harga jual. Biaya tambahan sudah masuk total modal.',
      ),
    ]);
    return Uint8List.fromList(book.encode()!);
  }

  static Future<Uint8List> pdf(String label, List<LoadItem> loads) async {
    final doc = pw.Document();
    final data = rows(loads);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => [
          pw.Text(
            'Material Tracker | Laporan $label',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Mata uang Rupiah. Tanggal sesuai tanggal lokal transaksi. Volume dalam m3.',
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: data.first.map((v) => '$v').toList(),
            data: data
                .skip(1)
                .map((r) => r.map((v) => v == null ? '-' : '$v').toList())
                .toList(),
            cellStyle: const pw.TextStyle(fontSize: 7),
            headerStyle: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green100),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Keuntungan hanya mencakup transaksi dengan harga jual. Total modal = subtotal + biaya tambahan.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<String?> share(
    String label,
    List<LoadItem> loads,
    bool asPdf, {
    required Rect origin,
  }) async {
    if (loads.isEmpty) throw StateError('Tidak ada transaksi untuk diekspor.');
    final bytes = asPdf ? await pdf(label, loads) : xlsx(label, loads);
    final directory = await getTemporaryDirectory();
    final safeLabel = label.replaceAll(RegExp(r'[^0-9A-Za-z]+'), '_');
    final name = 'MaterialTracker_$safeLabel.${asPdf ? 'pdf' : 'xlsx'}';

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final folder = await getDownloadsDirectory() ?? directory;
      final file = File('${folder.path}/$name');
      await file.writeAsBytes(bytes, flush: true);
      if (Platform.isWindows) {
        await Process.run('explorer.exe', ['/select,${file.path}']);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', file.path]);
      }
      return file.path;
    }

    final file = File('${directory.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], sharePositionOrigin: origin),
    );
    if (result.status == ShareResultStatus.unavailable) {
      throw StateError('Berbagi file tidak tersedia.');
    }
    return null;
  }
}
