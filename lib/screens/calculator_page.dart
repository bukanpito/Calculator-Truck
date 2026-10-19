import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/calculation.dart';
import '../widgets/calculation_summary.dart';
import '../widgets/section_card.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, required this.materials});
  final List<String> materials;
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final form = GlobalKey<FormState>();
  final fields = List.generate(4, (_) => TextEditingController());
  String? material;
  Calculation? result;
  String? error;
  static const labels = [
    'Volume muatan',
    'Harga modal per m³',
    'Biaya tambahan',
    'Harga jual per m³ (opsional)',
  ];

  @override
  void initState() {
    super.initState();
    material = widget.materials.firstOrNull;
  }

  @override
  void didUpdateWidget(covariant CalculatorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.materials.contains(material)) {
      material = widget.materials.firstOrNull;
      result = null;
      error = null;
    }
  }

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  void clearResult() => setState(() {
    result = null;
    error = null;
  });

  void calculate() {
    FocusScope.of(context).unfocus();
    if (!form.currentState!.validate()) return;
    try {
      final amounts = [
        for (var i = 1; i <= 3; i++)
          parseMoney(fields[i].text, optional: i > 1),
      ];
      final value = Calculation(
        volume: parseVolume(fields[0].text),
        price: amounts[0],
        extra: amounts[1],
        salePrice: fields[3].text.trim().isEmpty ? null : amounts[2],
      );
      setState(() {
        result = value;
        error = null;
      });
    } on FormatException catch (e) {
      setState(() {
        result = null;
        error = e.message;
      });
    }
  }

  void example() {
    form.currentState?.reset();
    const values = ['24,17', '370.000', '0', ''];
    for (var i = 0; i < values.length; i++) {
      fields[i].text = values[i];
    }
    calculate();
  }

  Future<void> copy() async {
    final value = result;
    if (value == null) return;
    try {
      await Clipboard.setData(
        ClipboardData(text: calculationText(material!, value)),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Hasil disalin')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat menyalin hasil. Coba kembali.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        'Kalkulasi muatan',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const Text(
        'Isi angka sendiri atau gunakan contoh. Hasil tidak disimpan.',
      ),
      TextButton(
        onPressed: example,
        child: const Text('Isi contoh 24,17 × 370.000'),
      ),
      SectionCard(
        child: Form(
          key: form,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(material),
                initialValue: material,
                decoration: const InputDecoration(labelText: 'Material'),
                items: [
                  for (final name in widget.materials)
                    DropdownMenuItem(value: name, child: Text(name)),
                ],
                onChanged: (value) {
                  material = value;
                  clearResult();
                },
                validator: (value) => value == null
                    ? 'Tambahkan material di menu Material.'
                    : null,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < labels.length; i++) ...[
                TextFormField(
                  key: ValueKey('input_$i'),
                  controller: fields[i],
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: i == 0,
                  ),
                  decoration: InputDecoration(
                    labelText: labels[i],
                    suffixText: i == 0 ? 'm³' : null,
                    prefixText: i == 0 ? null : 'Rp ',
                    helperText: i == 0
                        ? 'Contoh: 24,17 • maksimal 6 desimal'
                        : (i == 1
                              ? 'Contoh: 370000 atau 370.000'
                              : 'Boleh kosong'),
                  ),
                  onChanged: (_) => clearResult(),
                  validator: (text) {
                    try {
                      if (i == 0) {
                        parseVolume(text ?? '');
                      } else {
                        parseMoney(text ?? '', optional: i > 1);
                      }
                      return null;
                    } on FormatException catch (e) {
                      return e.message;
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: calculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Hitung'),
          ),
          OutlinedButton(
            onPressed: () {
              form.currentState?.reset();
              for (final field in fields) {
                field.clear();
              }
              clearResult();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      if (result != null) ...[
        CalculationSummary(material: material!, value: result!),
        OutlinedButton.icon(
          onPressed: copy,
          icon: const Icon(Icons.copy),
          label: const Text('Salin Hasil'),
        ),
      ],
      const SizedBox(height: 16),
      const Text(
        'Simpan Muatan belum aktif. Database akan ditambahkan pada tahap berikutnya.',
      ),
      const SizedBox(height: 24),
    ],
  );
}
