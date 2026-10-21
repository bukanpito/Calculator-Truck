import 'package:flutter/material.dart';

import '../models/load_item.dart';
import '../services/calculation.dart';
import '../services/money_input_formatter.dart';

class LoadEditor extends StatefulWidget {
  const LoadEditor({super.key, required this.item, required this.onSave});
  final LoadItem item;
  final Future<void> Function(String, Calculation) onSave;
  @override
  State<LoadEditor> createState() => _LoadEditorState();
}

class _LoadEditorState extends State<LoadEditor> {
  final form = GlobalKey<FormState>();
  late final fields = [
    for (final text in [
      widget.item.material,
      volumeText(widget.item.value.volume),
      moneyText(widget.item.value.ritCost ?? widget.item.value.subtotal),
      widget.item.value.salePrice == null
          ? ''
          : moneyText(widget.item.value.salePrice!),
      moneyText(widget.item.value.extra),
      widget.item.value.destination,
    ])
      TextEditingController(text: text),
  ];
  bool busy = false;
  String? error;
  @override
  void dispose() {
    for (final c in fields) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simpan perubahan?'),
        content: const Text(
          'Rekap akan dihitung ulang. Data sebelum perubahan disimpan dalam riwayat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onSave(
        fields[0].text.trim(),
        Calculation(
          volume: parseVolume(fields[1].text),
          price: 0,
          ritCost: parseMoney(fields[2].text),
          salePrice: fields[3].text.trim().isEmpty
              ? null
              : parseMoney(fields[3].text),
          extra: parseMoney(fields[4].text, optional: true),
          destination: fields[5].text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          busy = false;
          error = 'Perubahan gagal disimpan. Coba kembali.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Edit transaksi'),
      content: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tanggal dan waktu transaksi tetap dipertahankan.'),
              const SizedBox(height: 20),
              for (var i = 0; i < fields.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: fields[i],
                    enabled: !busy,
                    maxLength: i == 0 ? 80 : (i == 5 ? 200 : null),
                    keyboardType: i == 0 || i == 5
                        ? TextInputType.text
                        : const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: i >= 2 && i <= 4
                        ? const [MoneyInputFormatter()]
                        : null,
                    decoration: InputDecoration(
                      labelText: [
                        'Nama material',
                        'Volume m³',
                        'Modal per rit',
                        'Harga jual / m³ (opsional)',
                        'Biaya tambahan',
                        'Lokasi kirim',
                      ][i],
                    ),
                    validator: (text) {
                      try {
                        if (i == 0) {
                          if ((text ?? '').trim().isEmpty) {
                            return 'Nama wajib diisi.';
                          }
                        } else if (i == 1) {
                          parseVolume(text ?? '');
                        } else if (i == 5) {
                          return null;
                        } else {
                          parseMoney(text ?? '', optional: i == 3 || i == 4);
                        }
                        return null;
                      } on FormatException catch (e) {
                        return e.message;
                      }
                    },
                  ),
                ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: busy ? null : save,
          child: Text(busy ? 'Menyimpan…' : 'Simpan perubahan'),
        ),
      ],
    ),
  );
}
