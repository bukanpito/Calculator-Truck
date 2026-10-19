import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({
    super.key,
    required this.materials,
    required this.onAdd,
    required this.onDelete,
  });
  final List<String> materials;
  final ValueChanged<String> onAdd, onDelete;

  Future<void> add(BuildContext context) async {
    var input = '';
    final form = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah material'),
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            maxLength: 80,
            onChanged: (value) => input = value,
            decoration: const InputDecoration(labelText: 'Nama material'),
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'Nama wajib diisi.';
              if (materials.any(
                (item) => item.toLowerCase() == name.toLowerCase(),
              )) {
                return 'Material sudah ada.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, input.trim());
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (name != null) onAdd(name);
  }

  Future<void> remove(BuildContext context, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus material?'),
        content: Text('$name akan dihapus dari daftar dan pilihan kalkulator.'),
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
    );
    if (confirmed == true) onDelete(name);
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Daftar material', style: Theme.of(context).textTheme.headlineSmall),
      const Text('Daftar terhubung ke kalkulator • sementara selama demo'),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: () => add(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah material'),
      ),
      if (materials.isEmpty)
        const SectionCard(
          child: Text(
            'Belum ada material. Tambahkan material untuk menghitung.',
          ),
        ),
      for (final name in materials)
        SectionCard(
          child: ListTile(
            leading: const Icon(Icons.landscape_outlined),
            title: Text(name),
            subtitle: const Text('Satuan m³'),
            trailing: IconButton(
              tooltip: 'Hapus $name',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => remove(context, name),
            ),
          ),
        ),
    ],
  );
}
