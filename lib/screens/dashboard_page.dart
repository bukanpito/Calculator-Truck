import 'package:flutter/material.dart';

import '../models/load_item.dart';
import '../services/calculation.dart';
import '../widgets/section_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.loads,
    required this.onCalculate,
    required this.onReset,
    required this.reset,
  });
  final List<LoadItem> loads;
  final VoidCallback onCalculate;
  final VoidCallback onReset;
  final bool reset;
  @override
  Widget build(BuildContext context) {
    final priced = loads.where((row) => row.value.sales != null).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          reset ? 'Ringkasan sejak reset hari ini' : 'Ringkasan hari ini',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reset ? 'TOTAL MODAL SEJAK RESET' : 'TOTAL MODAL HARI INI'),
              const SizedBox(height: 12),
              Text(
                rupiah(loads.fold(0, (sum, row) => sum + row.value.total)),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Text(
                '${loads.length} muatan / transaksi • ${volumeText(loads.fold(0, (sum, row) => sum + row.value.volume))} m³',
              ),
              const Divider(height: 32),
              Text(
                priced.isEmpty
                    ? 'Belum ada harga jual.'
                    : 'Penjualan: ${rupiah(priced.fold(0, (sum, row) => sum + row.value.sales!))}\nEstimasi keuntungan: ${rupiah(priced.fold(0, (sum, row) => sum + row.value.profit!))}\nBerdasarkan ${priced.length} transaksi dengan harga jual.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: loads.isEmpty ? null : onReset,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset ringkasan'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onCalculate,
          icon: const Icon(Icons.calculate_outlined),
          label: const Text('Buka kalkulator'),
        ),
        if (loads.isEmpty)
          const SectionCard(
            child: Text('Belum ada muatan. Hitung lalu simpan muatan pertama.'),
          ),
      ],
    );
  }
}
