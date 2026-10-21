import 'package:flutter/material.dart';

import '../models/load_item.dart';
import '../services/calculation.dart';
import '../services/date_format.dart';
import '../services/report_export.dart';
import '../widgets/date_selector.dart';
import '../widgets/load_card.dart';
import '../widgets/section_card.dart';

class LoadsPage extends StatelessWidget {
  const LoadsPage({
    super.key,
    required this.loads,
    required this.date,
    required this.days,
    required this.onDate,
    required this.onDays,
    required this.onEdit,
    required this.onDelete,
  });
  final List<LoadItem> loads;
  final DateTime date;
  final int days;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<int> onDays;
  final ValueChanged<LoadItem> onEdit;
  final Future<void> Function(LoadItem) onDelete;

  static const presets = {1: '1 hari', 2: '2 hari', 7: '7 hari', 30: '30 hari'};

  DateTime get start => DateTime(date.year, date.month, date.day - (days - 1));

  String get label => days == 1
      ? formattedDate(date)
      : '${formattedDate(start)} – ${formattedDate(date)}';

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
            for (final entry in presets.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: days == entry.key,
                onSelected: (_) => onDays(entry.key),
              ),
          ],
        ),
        DateSelector(
          date: date,
          label: days == 1 ? 'Tanggal' : 'Tanggal akhir',
          onChanged: onDate,
        ),
        Text(
          days == 1 ? 'Menampilkan $label' : 'Rentang $label',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: loads.isEmpty ? null : () => export(context, false),
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Excel XLSX'),
            ),
            OutlinedButton.icon(
              onPressed: loads.isEmpty ? null : () => export(context, true),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
            ),
          ],
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
