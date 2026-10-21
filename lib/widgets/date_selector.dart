import 'package:flutter/material.dart';

import '../services/date_format.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.date,
    required this.onChanged,
    this.label = 'Tanggal',
  });
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              tooltip: 'Hari sebelumnya',
              onPressed: () =>
                  onChanged(DateTime(date.year, date.month, date.day - 1)),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_outlined, size: 20),
                label: Text(
                  formattedDate(date),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100, 12, 31),
                    helpText: 'Pilih tanggal',
                    cancelText: 'Batal',
                    confirmText: 'Pilih',
                    fieldLabelText: 'Tanggal',
                    fieldHintText: 'DD/MM/YYYY',
                  );
                  if (selected != null) onChanged(selected);
                },
              ),
            ),
            IconButton(
              tooltip: 'Hari berikutnya',
              onPressed: () =>
                  onChanged(DateTime(date.year, date.month, date.day + 1)),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    ),
  );
}
