import 'package:flutter/material.dart';

import '../services/date_format.dart';

/// Range picker: tap the button for a calendar range, or use the arrows to
/// shift the whole period.
class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.start,
    required this.end,
    required this.onChanged,
  });
  final DateTime start, end;
  final void Function(DateTime start, DateTime end) onChanged;

  int get days => end.difference(start).inDays + 1;

  Future<void> pick(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: DateTimeRange(start: start, end: end),
      helpText: 'Pilih rentang rekap',
      saveText: 'Pilih',
      cancelText: 'Batal',
      fieldStartLabelText: 'Dari',
      fieldEndLabelText: 'Sampai',
      fieldStartHintText: 'Tanggal awal',
      fieldEndHintText: 'Tanggal akhir',
    );
    if (picked != null && context.mounted) {
      onChanged(picked.start, picked.end);
    }
  }

  void shift(int direction) {
    final span = Duration(days: days * direction);
    onChanged(start.add(span), end.add(span));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rentang tanggal', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              tooltip: 'Rentang sebelumnya',
              onPressed: () => shift(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.date_range_outlined, size: 20),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedRange(start, end),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$days hari',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                onPressed: () => pick(context),
              ),
            ),
            IconButton(
              tooltip: 'Rentang berikutnya',
              onPressed: () => shift(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    ),
  );
}
