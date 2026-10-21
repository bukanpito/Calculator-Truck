import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calculator_truck/data/material_repository.dart';
import 'package:calculator_truck/data/load_repository.dart';
import 'package:calculator_truck/models/load_item.dart';
import 'package:calculator_truck/models/material_item.dart';
import 'package:calculator_truck/services/calculation.dart';

void main() {
  test('Migrasi v1, persistensi muatan, snapshot dan filter tanggal', () async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp('loads_test_');
    final file = '${directory.path}/test.db';
    final old = await databaseFactoryFfi.openDatabase(
      file,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE materials (id INTEGER PRIMARY KEY, name TEXT, price INTEGER, stone INTEGER)',
          );
          await db.insert('materials', {
            'id': 1,
            'name': 'Pasir lama',
            'price': 370000,
            'stone': 0,
          });
        },
      ),
    );
    await old.close();
    var repo = await MaterialRepository.open(
      factory: databaseFactoryFfi,
      file: file,
    );
    try {
      expect((await repo.load()).single.name, 'Pasir lama');
      await LoadRepository(repo.db).save(
        'Pasir lama',
        Calculation(
          volume: parseVolume('24,17'),
          price: 370000,
          salePrice: 400000,
        ),
      );
      await repo.save(
        const MaterialItem(id: 1, name: 'Pasir baru', price: 500000),
      );
      await repo.delete(1);
      await repo.db.close();
      repo = await MaterialRepository.open(
        factory: databaseFactoryFfi,
        file: file,
      );
      final rows = await LoadRepository(repo.db)
          .forDate(localDate(DateTime.now()));
      expect(rows.single.material, 'Pasir lama');
      expect(rows.single.value.total, 8942900);
      await LoadRepository(repo.db).resetDashboard(localDate(DateTime.now()));
      expect(
        await LoadRepository(repo.db).resetId(localDate(DateTime.now())),
        rows.single.id,
      );
      expect(
        (await LoadRepository(repo.db).forDate(localDate(DateTime.now())))
            .length,
        1,
      );
      expect(rows.single.value.profit, 725100);
      await LoadRepository(repo.db).update(
        rows.single,
        'Pasir revisi',
        Calculation(volume: parseVolume('2'), price: 100000, extra: 5000),
      );
      final edited = (await LoadRepository(
        repo.db,
      ).forDate(localDate(DateTime.now()))).single;
      expect(edited.value.total, 205000);
      expect(edited.createdAt, rows.single.createdAt);
      expect((await repo.db.query('load_changes')).length, 1);
      await LoadRepository(repo.db).delete(edited.id);
      expect(
        await LoadRepository(repo.db).forDate(localDate(DateTime.now())),
        isEmpty,
      );
      expect(await repo.load(), isEmpty);
      expect(await LoadRepository(repo.db).forDate('2000-01-01'), isEmpty);
    } finally {
      await repo.db.close();
      await directory.delete(recursive: true);
    }
  });
}
