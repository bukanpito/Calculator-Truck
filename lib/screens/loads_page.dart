import 'package:flutter/material.dart';

import '../models/load_item.dart';
import '../services/calculation.dart';
import '../services/date_format.dart';
import '../services/report_export.dart';
import '../widgets/load_card.dart';
import '../widgets/range_selector.dart';
import '../widgets/section_card.dart';

class LoadsPage extends StatelessWidget {
  const LoadsPage({
    super.key,
    required this.loads,
    required this.start,
    required this.end,
    required this.onRange,
    required this.onEdit,
    required this.onDelete,
  });
  final List<LoadItem> loads;
  final DateTime start, end;
  final void Function(DateTime start, DateTime end) onRange;
  final ValueChanged<LoadItem> onEdit;
  final Future<void> Function(LoadItem) onDelete;

  int get days => end.difference(start).inDays + 1;

  String get label => formattedRange(start, end);

  static DateTime _dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<(String, DateTime, DateTime)> get presets {
    final today = _dayOf(DateTime.now());
    return [
      ('Hari ini', today, today),
      ('7 hari', today.subtract(const Duration(days: 6)), today),
      ('30 hari', today.subtract(const Duration(days: 29)), today),
      ('Bulan ini', DateTime(today.year, today.month), today),
    ];
  }

  Future<void> export(BuildContext context, bool pdf) async {
    final box = context.findRenderObject() as RenderBox;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ReportExport.share(
        label,
        List.of(loads),
        pdf,
        origin: box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ekspor gagal. Coba kembali.')),
      );
    }
  }

  Future<void> openExport(BuildContext context) async {
    final pdf = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('Excel (XLSX)'),
              subtitle: const Text('Data transaksi + total, siap diolah.'),
              onTap: () => Navigator.pop(sheet, false),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('PDF'),
              subtitle: const Text('Laporan siap cetak atau dibagikan.'),
              onTap: () => Navigator.pop(sheet, true),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (pdf == null || !context.mounted) return;
    await export(context, pdf);
  }

  @override
  Widget build(BuildContext context) {
    final numbered = <(int, LoadItem)>[];
    final counters = <String, int>{};
    for (final row in loads) {
      final number = (counters[row.date] ?? 0) + 1;
      counters[row.date] = number;
      numbered.add((number, row));
    }
    final priced = loads.where((row) => row.value.profit != null);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Spreadsheet', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Pilih rentang tanggal untuk rekap dan ekspor.'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (title, from, to) in presets)
              ChoiceChip(
                label: Text(title),
                selected: _sameDay(start, from) && _sameDay(end, to),
                onSelected: (_) => onRange(from, to),
              ),
          ],
        ),
        RangeSelector(start: start, end: end, onChanged: onRange),
        OutlinedButton.icon(
          onPressed: loads.isEmpty ? null : () => openExport(context),
          icon: const Icon(Icons.ios_share),
          label: const Text('Ekspor'),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${loads.length} transaksi • '
                '${volumeText(loads.fold(0, (sum, row) => sum + row.value.volume))} m³',
              ),
              const SizedBox(height: 4),
              Text(
                'Total modal '
                '${rupiah(loads.fold(0, (sum, row) => sum + row.value.total))}',
              ),
              if (priced.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Estimasi keuntungan '
                  '${rupiah(priced.fold(0, (sum, row) => sum + (row.value.profit ?? 0)))} '
                  '• ${priced.length} transaksi dengan harga jual',
                ),
              ] else ...[
                const SizedBox(height: 4),
                const Text('Keuntungan belum tersedia. Isi harga jual.'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (loads.isEmpty)
          SectionCard(
            child: Text(
              days == 1
                  ? 'Belum ada transaksi pada tanggal ini.'
                  : 'Belum ada transaksi pada rentang ini.',
            ),
          ),
        for (final (number, row) in numbered)
          LoadCard(
            number: number,
            key: ValueKey(row.id),
            item: row,
            showDate: days > 1,
            onEdit: () => onEdit(row),
            onDelete: () => onDelete(row),
          ),
        const SizedBox(height: 12),
        const Text(
          'Ekspor mengikuti rentang tanggal yang dipilih. Nomor transaksi '
          'mulai dari #1 setiap hari.',
        ),
      ],
    );
  }
}
