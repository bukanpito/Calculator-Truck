import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.onCalculate});
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        'Ringkasan hari ini',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TOTAL MODAL HARI INI'),
            SizedBox(height: 12),
            Text('Rp0', style: TextStyle(fontSize: 36)),
            Text('0 muatan • 0 m³ • 0 transaksi'),
            SizedBox(height: 12),
            Text('Belum ada muatan. Kalkulasi demo tidak masuk laporan.'),
          ],
        ),
      ),
      FilledButton.icon(
        onPressed: onCalculate,
        icon: const Icon(Icons.calculate_outlined),
        label: const Text('Buka kalkulator'),
      ),
      const SectionCard(
        child: ListTile(
          title: Text('Harga pasar belum tersedia'),
          subtitle: Text(
            'Sumber harga dan pembaruan otomatis belum dikonfigurasi.',
          ),
        ),
      ),
    ],
  );
}

class SpreadsheetPage extends StatelessWidget {
  const SpreadsheetPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        'Spreadsheet harian',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SectionCard(child: Text('Belum ada transaksi')),
      const Text(
        'Database belum aktif. Hasil demo tidak dicatat sebagai transaksi.',
      ),
      const SizedBox(height: 16),
      const OutlinedButton(
        onPressed: null,
        child: Text('Ekspor Excel / PDF • belum aktif'),
      ),
    ],
  );
}

const demoMaterials = [
  'Pasir pasang',
  'Pasir cor',
  'Batu split',
  'Sirtu',
  'Tanah urug',
  'Lainnya',
];
