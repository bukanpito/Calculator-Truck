import 'package:flutter/material.dart';

import '../models/load_item.dart';
import '../services/calculation.dart';
import '../services/report_export.dart';
import '../widgets/date_selector.dart';
import '../widgets/load_card.dart';
import '../widgets/section_card.dart';

class LoadsPage extends StatelessWidget {
  const LoadsPage({
    super.key,
    required this.loads,
    required this.date,
    required this.onDate,
    required this.onEdit,
    required this.onDelete,
  });
  final List<LoadItem> loads;
  final DateTime date;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<LoadItem> onEdit;
  final Future<void> Function(LoadItem) onDelete;

  Future<void> export(BuildContext context, bool pdf) async {
    final box = context.findRenderObject() as RenderBox;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ReportExport.share(
        localDate(date),
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Spreadsheet harian',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      DateSelector(date: date, onChanged: onDate),
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
        child: Text(
          '${loads.length} transaksi • ${volumeText(loads.fold(0, (sum, row) => sum + row.value.volume))} m³\nTotal modal ${rupiah(loads.fold(0, (sum, row) => sum + row.value.total))}\n\n${loads.any((row) => row.value.profit != null) ? 'Estimasi keuntungan ${rupiah(loads.fold(0, (sum, row) => sum + (row.value.profit ?? 0)))}\nBerdasarkan ${loads.where((row) => row.value.profit != null).length} transaksi dengan harga jual.' : 'Keuntungan belum tersedia. Isi harga jual pada transaksi.'}',
        ),
      ),
      const SizedBox(height: 20),
      if (loads.isEmpty)
        const SectionCard(child: Text('Belum ada transaksi pada tanggal ini.')),
      for (final (index, row) in loads.indexed)
        LoadCard(
          number: index + 1,
          key: ValueKey(row.id),
          item: row,
          onEdit: () => onEdit(row),
          onDelete: () => onDelete(row),
        ),
      const SizedBox(height: 12),
      const Text('Ekspor tetap berisi seluruh kolom untuk tanggal terpilih.'),
    ],
  );
}
