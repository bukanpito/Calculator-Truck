import 'package:flutter/material.dart';

import '../models/material_item.dart';
import '../services/calculation.dart';
import '../services/money_input_formatter.dart';
import 'material_thumbnail.dart';

class MaterialEditor extends StatefulWidget {
  const MaterialEditor({super.key, this.item, required this.materials});
  final MaterialItem? item;
  final List<MaterialItem> materials;
  @override
  State<MaterialEditor> createState() => _MaterialEditorState();
}

class _MaterialEditorState extends State<MaterialEditor> {
  final form = GlobalKey<FormState>();
  late bool stone = widget.item?.stone ?? false;
  late final name = TextEditingController(text: widget.item?.name ?? '');
  late final price = TextEditingController(
    text: widget.item?.price == null ? '' : moneyText(widget.item!.price!),
  );
  @override
  void dispose() {
    name.dispose();
    price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.item == null ? 'Tambah material' : 'Edit material'),
    content: SingleChildScrollView(
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Pilih gambar material'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final option in [false, true])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Semantics(
                        button: true,
                        selected: stone == option,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => stone = option),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: stone == option
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                MaterialThumbnail(stone: option),
                                const SizedBox(height: 8),
                                Text(option ? 'Batu' : 'Pasir'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: name,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Nama material'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Nama wajib diisi.';
                if (widget.materials.any(
                  (m) =>
                      m.id != widget.item?.id &&
                      m.name.toLowerCase() == text.toLowerCase(),
                )) {
                  return 'Material sudah ada.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: price,
              keyboardType: TextInputType.number,
              inputFormatters: const [MoneyInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Harga jual per m³',
                prefixText: 'Rp ',
                helperText: 'Opsional • contoh 350.000',
              ),
              validator: (value) {
                try {
                  parseMoney(value ?? '', optional: true);
                  return null;
                } on FormatException catch (e) {
                  return e.message;
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Harga jual mengisi kalkulator otomatis. Harga modal per rit diisi '
              'manual di kalkulator.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      FilledButton(
        onPressed: () {
          if (!form.currentState!.validate()) return;
          Navigator.pop(
            context,
            MaterialItem(
              id: widget.item?.id ?? -1,
              name:
                  '${name.text.trim().characters.first.toUpperCase()}${name.text.trim().characters.skip(1).join()}',
              price: price.text.trim().isEmpty ? null : parseMoney(price.text),
              stone: stone,
            ),
          );
        },
        child: Text(widget.item == null ? 'Tambah' : 'Simpan'),
      ),
    ],
  );
}
