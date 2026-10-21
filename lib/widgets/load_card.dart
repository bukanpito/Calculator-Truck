import 'package:flutter/material.dart';

import '../models/load_item.dart';
import '../services/calculation.dart';

class LoadCard extends StatelessWidget {
  const LoadCard({
    super.key,
    required this.item,
    required this.number,
    required this.onEdit,
    required this.onDelete,
  });
  final LoadItem item;
  final int number;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  Future<void> remove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: Text(
          'Transaksi #$number (${item.material}) akan dihapus dari Spreadsheet, Dashboard dan laporan. Material tidak dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDelete();
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '#$number • ${item.createdAt.substring(11, 16)}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(item.material, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '${volumeText(item.value.volume)} m³ • modal / m³ '
            '${rupiah(item.value.costPerM3)}',
          ),
          if (item.value.destination.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Kirim ke: ${item.value.destination}'),
          ],
          const Divider(height: 24),
          const Text('Total modal'),
          const SizedBox(height: 4),
          Text(
            rupiah(item.value.total),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            title: const Text('Rincian transaksi'),
            children: [
              if (item.value.ritCost != null)
                line('Modal per rit', rupiah(item.value.ritCost!)),
              line('Modal / m³', rupiah(item.value.costPerM3)),
              line('Biaya tambahan', rupiah(item.value.extra)),
              line(
                'Harga jual / m³',
                item.value.salePrice == null
                    ? 'Belum diisi'
                    : rupiah(item.value.salePrice!),
              ),
              line(
                'Total penjualan',
                item.value.sales == null ? '—' : rupiah(item.value.sales!),
              ),
              line(
                'Estimasi keuntungan',
                item.value.profit == null ? '—' : rupiah(item.value.profit!),
              ),
              if (item.value.destination.isNotEmpty)
                line('Lokasi kirim', item.value.destination),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => remove(context),
                icon: const Icon(Icons.delete_outline, size: 18),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                label: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );
}
