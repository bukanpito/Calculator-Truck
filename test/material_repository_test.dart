import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calculator_truck/data/material_repository.dart';
import 'package:calculator_truck/models/material_item.dart';

void main() {
  test('Material tetap tersimpan, daftar kosong tidak diisi ulang', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp(
      'materialtrack_test_',
    );
    final file = '${directory.path}/materials.db';
    var repo = await MaterialRepository.open(
      factory: databaseFactoryFfi,
      file: file,
    );
    try {
      expect((await repo.load()).length, 5);
      await repo.save(
        const MaterialItem(
          id: -1,
          name: 'pasir uji',
          price: 370000,
          stone: true,
        ),
      );
      final item = (await repo.load()).last;
      await repo.save(
        MaterialItem(
          id: item.id,
          name: 'Pasir edit',
          price: 400000,
          stone: false,
        ),
      );
      await repo.db.close();
      repo = await MaterialRepository.open(
        factory: databaseFactoryFfi,
        file: file,
      );
      final restored = (await repo.load()).last;
      expect(restored.name, 'Pasir edit');
      expect(restored.price, 400000);
      expect(restored.stone, false);
      for (final item in await repo.load()) {
        await repo.delete(item.id);
      }
      await repo.db.close();
      repo = await MaterialRepository.open(
        factory: databaseFactoryFfi,
        file: file,
      );
      expect(await repo.load(), isEmpty);
    } finally {
      await repo.db.close();
      await directory.delete(recursive: true);
    }
  });
}
