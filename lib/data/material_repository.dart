import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import '../models/material_item.dart';
import 'load_repository.dart';

class MaterialRepository {
  MaterialRepository(this.db);
  final Database db;
  static Future<void> addRitColumns(Database db) async {
    await db.execute(
      'ALTER TABLE loads ADD COLUMN rit_cost INTEGER CHECK(rit_cost IS NULL OR rit_cost BETWEEN 0 AND 1000000000)',
    );
    await db.execute(
      "ALTER TABLE loads ADD COLUMN destination TEXT NOT NULL DEFAULT '' CHECK(length(destination) <= 200)",
    );
  }

  static Future<void> upgradeRit(Database db) async {
    await db.execute(
      'ALTER TABLE materials ADD COLUMN sale_price INTEGER CHECK(sale_price IS NULL OR sale_price BETWEEN 0 AND 1000000000)',
    );
    await addRitColumns(db);
  }

  static Future<String> _folder(DatabaseFactory driver) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final dir = await getApplicationSupportDirectory();
      await dir.create(recursive: true);
      return dir.path;
    }
    return driver.getDatabasesPath();
  }

  static Future<MaterialRepository> open({
    DatabaseFactory? factory,
    String? file,
  }) async {
    final driver = factory ?? databaseFactory;
    final location = file ?? join(await _folder(driver), 'materialtrack.db');
    final db = await driver.openDatabase(
      location,
      options: OpenDatabaseOptions(
        version: 6,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) await LoadRepository.create(db);
          if (oldVersion < 3) await LoadRepository.createAudit(db);
          if (oldVersion < 4) await LoadRepository.createSettings(db);
          if (oldVersion < 5) await LoadRepository.addDeletionFlag(db);
          if (oldVersion < 6) await upgradeRit(db);
        },
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE materials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL COLLATE NOCASE UNIQUE
              CHECK(length(trim(name)) BETWEEN 1 AND 80),
            sale_price INTEGER CHECK(sale_price IS NULL OR sale_price BETWEEN 0 AND 1000000000),
            stone INTEGER NOT NULL CHECK(stone IN (0, 1))
          )
        ''');
          for (final name in [
            'Pasir pasang',
            'Pasir cor',
            'Batu split',
            'Sirtu',
            'Tanah urug',
          ]) {
            await db.insert('materials', {
              'name': name,
              'stone': name == 'Batu split' || name == 'Sirtu' ? 1 : 0,
            });
          }
          await LoadRepository.create(db);
          await LoadRepository.createAudit(db);
          await LoadRepository.createSettings(db);
          await LoadRepository.addDeletionFlag(db);
          await addRitColumns(db);
        },
      ),
    );
    return MaterialRepository(db);
  }

  Future<List<MaterialItem>> load() async => [
    for (final row in await db.query('materials', orderBy: 'id ASC'))
      MaterialItem(
        id: row['id'] as int,
        name: row['name'] as String,
        price: row['sale_price'] as int?,
        stone: row['stone'] == 1,
      ),
  ];

  Future<void> save(MaterialItem item) async {
    final name = item.name.trim();
    if (name.isEmpty ||
        name.length > 80 ||
        (item.price != null && (item.price! < 0 || item.price! > 1000000000))) {
      throw const FormatException('Data material tidak valid.');
    }
    final normalized =
        '${name.characters.first.toUpperCase()}${name.characters.skip(1).join()}';
    final values = {
      'name': normalized,
      'sale_price': item.price,
      'stone': item.stone ? 1 : 0,
    };
    if (item.id < 0) {
      await db.insert('materials', values);
    } else {
      final count = await db.update(
        'materials',
        values,
        where: 'id = ?',
        whereArgs: [item.id],
      );
      if (count != 1) throw StateError('Material tidak ditemukan.');
    }
  }

  Future<void> delete(int id) async {
    final count = await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count != 1) throw StateError('Material tidak ditemukan.');
  }
}
