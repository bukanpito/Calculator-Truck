import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key, required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  static const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
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
              '${date.year} ${months[date.month - 1]} ${date.day}',
              textAlign: TextAlign.center,
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
                fieldHintText: 'MM/DD/YYYY',
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
  );
}
