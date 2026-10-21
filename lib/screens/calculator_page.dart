import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/calculation.dart';
import '../services/money_input_formatter.dart';
import '../models/material_item.dart';
import '../widgets/calculation_summary.dart';
import '../widgets/section_card.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    super.key,
    required this.materials,
    required this.onSave,
  });
  final Future<void> Function(String, Calculation) onSave;
  final List<MaterialItem> materials;
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final form = GlobalKey<FormState>();
  final fields = List.generate(5, (_) => TextEditingController());
  int? materialId;
  String? get material =>
      widget.materials.where((m) => m.id == materialId).firstOrNull?.name;

  void selectMaterial(MaterialItem? item) {
    materialId = item?.id;
    fields[2].text = item?.price == null ? '' : moneyText(item!.price!);
  }

  Calculation? result;
  String? error;
  bool saving = false;
  bool saved = false;
  static const labels = [
    'Volume muatan',
    'Modal per rit',
    'Harga jual per m³ (opsional)',
    'Biaya tambahan',
    'Lokasi kirim',
  ];

  @override
  void initState() {
    super.initState();
    selectMaterial(widget.materials.firstOrNull);
  }

  @override
  void didUpdateWidget(covariant CalculatorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = widget.materials
        .where((m) => m.id == materialId)
        .firstOrNull;
    final previous = oldWidget.materials
        .where((m) => m.id == materialId)
        .firstOrNull;
    if (selected == null || selected != previous) {
      selectMaterial(selected ?? widget.materials.firstOrNull);
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
    saved = false;
    result = null;
    error = null;
  });

  void calculate() {
    FocusScope.of(context).unfocus();
    if (!form.currentState!.validate()) return;
    try {
      final value = Calculation(
        volume: parseVolume(fields[0].text),
        price: 0,
        ritCost: parseMoney(fields[1].text),
        salePrice: fields[2].text.trim().isEmpty
            ? null
            : parseMoney(fields[2].text),
        extra: parseMoney(fields[3].text, optional: true),
        destination: fields[4].text.trim(),
      );
      setState(() {
        saved = false;
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
    const values = ['26,46', '8.200.000', '350.000', '0', 'Proyek Bekasi'];
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
  Widget build(BuildContext context) => AbsorbPointer(
    absorbing: saving,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Kalkulasi muatan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Text(
          'Isi angka, hitung, lalu tekan Simpan Muatan untuk mencatat transaksi.',
        ),
        TextButton(
          onPressed: example,
          child: const Text('Isi contoh rit Rp8.200.000 / 26,46 m³'),
        ),
        SectionCard(
          child: Form(
            key: form,
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  key: ValueKey(materialId),
                  initialValue: materialId,
                  decoration: const InputDecoration(labelText: 'Material'),
                  items: [
                    for (final item in widget.materials)
                      DropdownMenuItem(value: item.id, child: Text(item.name)),
                  ],
                  onChanged: (value) {
                    selectMaterial(
                      widget.materials.where((m) => m.id == value).firstOrNull,
                    );
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
                    maxLength: i == 4 ? 200 : null,
                    keyboardType: i == 4
                        ? TextInputType.text
                        : TextInputType.numberWithOptions(decimal: i == 0),
                    textCapitalization: i == 4
                        ? TextCapitalization.sentences
                        : TextCapitalization.none,
                    inputFormatters: i >= 1 && i <= 3
                        ? const [MoneyInputFormatter()]
                        : null,
                    decoration: InputDecoration(
                      labelText: labels[i],
                      suffixText: i == 0 ? 'm³' : null,
                      prefixText: i >= 1 && i <= 3 ? 'Rp ' : null,
                      helperText: switch (i) {
                        0 => 'Contoh: 26,46 • maksimal 6 desimal',
                        1 => 'Total modal satu rit, contoh 8.200.000',
                        2 => 'Terisi dari material • boleh kosong',
                        3 => 'Boleh kosong',
                        _ => 'Contoh: Proyek Jatiasih',
                      },
                    ),
                    onChanged: (_) => clearResult(),
                    validator: (text) {
                      try {
                        if (i == 0) {
                          parseVolume(text ?? '');
                        } else if (i == 4) {
                          return null;
                        } else {
                          parseMoney(text ?? '', optional: i == 2 || i == 3);
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
          FilledButton.icon(
            onPressed: saving || saved
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => saving = true);
                    try {
                      await widget.onSave(material!, result!);
                      if (mounted) setState(() => saved = true);
                    } catch (_) {
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Muatan gagal disimpan. Coba kembali.',
                            ),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => saving = false);
                    }
                  },
            icon: const Icon(Icons.save_outlined),
            label: Text(
              saving
                  ? 'Menyimpan…'
                  : saved
                  ? 'Muatan tersimpan'
                  : 'Simpan Muatan',
            ),
          ),
          OutlinedButton.icon(
            onPressed: copy,
            icon: const Icon(Icons.copy),
            label: const Text('Salin Hasil'),
          ),
        ],
        const SizedBox(height: 16),
        const SizedBox(height: 24),
      ],
    ),
  );
}
