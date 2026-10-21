import 'package:sqflite/sqflite.dart';

import 'dart:convert';

import '../models/load_item.dart';
import '../services/calculation.dart';

class LoadRepository {
  LoadRepository(this.db);
  final Database db;

  static Future<void> addDeletionFlag(Database db) => db.execute(
    'ALTER TABLE loads ADD COLUMN deleted INTEGER NOT NULL DEFAULT 0 CHECK(deleted IN (0, 1))',
  );

  Future<void> delete(int id) async {
    final count = await db.update(
      'loads',
      {'deleted': 1},
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
    );
    if (count != 1) throw StateError('Transaksi tidak ditemukan.');
  }

  static Future<void> createSettings(Database db) => db.execute('''
    CREATE TABLE dashboard_resets (
      local_date TEXT PRIMARY KEY,
      last_load_id INTEGER NOT NULL
    )
  ''');

  Future<int?> resetId(String date) async {
    final rows = await db.query(
      'dashboard_resets',
      where: 'local_date = ?',
      whereArgs: [date],
    );
    return rows.isEmpty ? null : rows.single['last_load_id'] as int;
  }

  Future<void> resetDashboard(String date) => db.transaction((txn) async {
    final rows = await txn.rawQuery(
      'SELECT COALESCE(MAX(id), 0) AS last_id FROM loads',
    );
    await txn.insert('dashboard_resets', {
      'local_date': date,
      'last_load_id': rows.single['last_id'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  });

  static Future<void> createAudit(Database db) => db.execute('''
    CREATE TABLE load_changes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      load_id INTEGER NOT NULL REFERENCES loads(id),
      changed_at TEXT NOT NULL,
      previous_data TEXT NOT NULL
    )
  ''');

  Future<void> update(
    LoadItem original,
    String material,
    Calculation value, {
    DateTime? createdAt,
  }) async {
    if (material.trim().isEmpty ||
        material.trim().length > 80 ||
        value.shipping != 0 ||
        value.discount != 0 ||
        value.destination.length > 200) {
      throw const FormatException('Data transaksi tidak valid.');
    }
    final stamp = createdAt ?? DateTime.parse(original.createdAt);
    await db.transaction((txn) async {
      final previous = await txn.query(
        'loads',
        where: 'id = ?',
        whereArgs: [original.id],
      );
      if (previous.length != 1 || previous.single['deleted'] == 1) {
        throw StateError('Transaksi tidak ditemukan.');
      }
      await txn.insert('load_changes', {
        'load_id': original.id,
        'changed_at': DateTime.now().toIso8601String(),
        'previous_data': jsonEncode(previous.single),
      });
      await txn.update(
        'loads',
        {
          'material': material.trim(),
          'volume': value.volume,
          'price': value.price,
          'extra': value.extra,
          'sale_price': value.salePrice,
          'rit_cost': value.ritCost,
          'destination': value.destination,
          'created_at': stamp.toIso8601String(),
          'local_date': localDate(stamp),
        },
        where: 'id = ?',
        whereArgs: [original.id],
      );
    });
  }

  static Future<void> create(Database db) async {
    await db.execute('''CREATE TABLE loads (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      material TEXT NOT NULL CHECK(length(trim(material)) BETWEEN 1 AND 80),
      created_at TEXT NOT NULL, local_date TEXT NOT NULL,
      volume INTEGER NOT NULL CHECK(volume > 0 AND volume <= 1000000000000),
      price INTEGER NOT NULL CHECK(price BETWEEN 0 AND 1000000000),
      extra INTEGER NOT NULL CHECK(extra BETWEEN 0 AND 1000000000),
      sale_price INTEGER CHECK(sale_price IS NULL OR sale_price BETWEEN 0 AND 1000000000)
    )''');
    await db.execute('CREATE INDEX loads_date ON loads(local_date, id)');
  }

  Future<int> save(String material, Calculation value) async {
    if (material.trim().isEmpty ||
        material.length > 80 ||
        value.shipping != 0 ||
        value.discount != 0 ||
        value.destination.length > 200) {
      throw const FormatException('Data muatan tidak valid.');
    }
    final now = DateTime.now();
    return db.insert('loads', {
      'material': material,
      'created_at': now.toIso8601String(),
      'local_date': localDate(now),
      'volume': value.volume,
      'price': value.price,
      'extra': value.extra,
      'sale_price': value.salePrice,
      'rit_cost': value.ritCost,
      'destination': value.destination,
    });
  }

  Future<List<LoadItem>> forDate(String date) async => [
    for (final row in await db.query(
      'loads',
      where: 'local_date = ? AND deleted = 0',
      whereArgs: [date],
      orderBy: 'id DESC',
    ))
      _fromRow(row),
  ];

  /// Transactions from [start] to [end] (inclusive), newest day first.
  Future<List<LoadItem>> forRange(DateTime start, DateTime end) async => [
    for (final row in await db.query(
      'loads',
      where: 'local_date BETWEEN ? AND ? AND deleted = 0',
      whereArgs: [localDate(start), localDate(end)],
      orderBy: 'local_date DESC, id DESC',
    ))
      _fromRow(row),
  ];

  static LoadItem _fromRow(Map<String, Object?> row) => LoadItem(
    id: row['id'] as int,
    material: row['material'] as String,
    createdAt: row['created_at'] as String,
    date: row['local_date'] as String,
    value: Calculation(
      volume: row['volume'] as int,
      price: row['price'] as int,
      extra: row['extra'] as int,
      salePrice: row['sale_price'] as int?,
      ritCost: row['rit_cost'] as int?,
      destination: row['destination'] as String,
    ),
  );
}
