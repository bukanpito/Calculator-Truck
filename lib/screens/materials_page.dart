import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../models/material_item.dart';
import '../services/calculation.dart';
import '../widgets/material_editor.dart';
import '../widgets/material_thumbnail.dart';

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({
    super.key,
    required this.materials,
    required this.onSave,
    required this.onDelete,
  });
  final List<MaterialItem> materials;
  final Future<void> Function(MaterialItem) onSave, onDelete;

  Future<void> edit(BuildContext context, [MaterialItem? item]) async {
    final value = await showDialog<MaterialItem>(
      context: context,
      builder: (_) => MaterialEditor(item: item, materials: materials),
    );
    if (value != null) await onSave(value);
  }

  Future<bool> confirm(BuildContext context, MaterialItem item) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus material?'),
          content: Text(
            '${item.name} akan dihapus dari daftar dan pilihan kalkulator.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
    children: [
      Text(
        'Daftar material',
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text('Ketuk untuk edit harga. Geser ke kiri untuk hapus.'),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => edit(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah material'),
      ),
      const SizedBox(height: 24),
      if (materials.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada material. Tambahkan material untuk menghitung.',
          ),
        ),
      for (final item in materials)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey('material_${item.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              if (await confirm(context, item)) await onDelete(item);
              return false;
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline),
            ),
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Semantics(
                customSemanticsActions: {
                  const CustomSemanticsAction(
                    label: 'Hapus material',
                  ): () async {
                    if (await confirm(context, item)) onDelete(item);
                  },
                },
                child: InkWell(
                  onTap: () => edit(context, item),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        MaterialThumbnail(stone: item.stone),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.price == null
                                    ? 'Harga jual belum diatur'
                                    : '${rupiah(item.price!)} / m³',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Harga jual • tersimpan lokal',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
