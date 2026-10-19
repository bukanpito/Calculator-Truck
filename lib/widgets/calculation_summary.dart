import 'package:flutter/material.dart';

import '../services/calculation.dart';
import 'section_card.dart';

String calculationText(String material, Calculation value) => [
  'MaterialTrack • hasil demo (tidak disimpan)',
  'Material: $material',
  'Volume: ${volumeText(value.volume)} m³',
  'Modal per m³: ${rupiah(value.price)}',
  'Subtotal material: ${rupiah(value.subtotal)}',
  'Biaya tambahan: ${rupiah(value.extra)}',
  'Total modal: ${rupiah(value.total)}',
  if (value.sales != null) ...[
    'Harga jual per m³: ${rupiah(value.salePrice!)}',
    'Total penjualan: ${rupiah(value.sales!)}',
    'Estimasi keuntungan: ${rupiah(value.profit!)}',
  ] else
    'Harga jual belum diisi. Keuntungan belum dihitung.',
].join('\n');

class CalculationSummary extends StatelessWidget {
  const CalculationSummary({
    super.key,
    required this.material,
    required this.value,
  });
  final String material;
  final Calculation value;

  @override
  Widget build(BuildContext context) => SectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(material, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const Text('TOTAL MODAL'),
        const SizedBox(height: 8),
        Text(
          rupiah(value.total),
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        const Divider(height: 24),
        _line('Volume muatan', '${volumeText(value.volume)} m³'),
        _line('Harga modal / m³', rupiah(value.price)),
        _line('Subtotal material', rupiah(value.subtotal)),
        _line('Biaya tambahan', rupiah(value.extra)),
        if (value.sales != null) ...[
          const Divider(height: 24),
          _line('Harga jual / m³', rupiah(value.salePrice!)),
          _line('Total penjualan', rupiah(value.sales!)),
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: value.profit! < 0
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.profit! < 0
                      ? 'Estimasi kerugian'
                      : 'Estimasi keuntungan',
                ),
                const SizedBox(height: 6),
                Text(
                  rupiah(value.profit!),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Isi harga jual untuk melihat estimasi keuntungan.'),
          ),
        const SizedBox(height: 12),
        const Text('Subtotal dibulatkan ke Rupiah terdekat (setengah naik).'),
      ],
    ),
  );
  Widget _line(String label, String amount) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
