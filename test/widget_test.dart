import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_truck/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:calculator_truck/data/material_repository.dart';

void main() {
  late MaterialRepository repository;
  setUpAll(sqfliteFfiInit);
  setUp(() async {
    repository = await MaterialRepository.open(
      factory: databaseFactoryFfi,
      file: inMemoryDatabasePath,
    );
  });
  tearDown(() => repository.db.close());
  testWidgets('Tambah dan hapus material terhubung ke kalkulator', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav_material')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah material'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama material'),
      'pasir demo',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Harga jual per m³'),
      '123.000',
    );
    await tester.tap(find.text('Tambah'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(find.text('Pasir demo'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav_calculator')));
    await tester.pumpAndSettle();
    expect(find.text('Ongkos kirim'), findsNothing);
    expect(find.text('Diskon'), findsNothing);
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pasir demo').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('input_2')))
          .controller!
          .text,
      '123.000',
    );
    await tester.tap(find.text('Isi contoh rit Rp8.200.000 / 26,46 m³'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL MODAL'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav_material')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pasir demo'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama material'),
      'Pasir edit',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Harga jual per m³'),
      '200.000',
    );
    await tester.tap(find.text('Simpan'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav_calculator')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('input_2')))
          .controller!
          .text,
      '200.000',
    );
    await tester.tap(find.byKey(const ValueKey('nav_material')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.ancestor(
        of: find.text('Pasir edit'),
        matching: find.byType(Dismissible),
      ),
      const Offset(-700, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav_calculator')));
    await tester.pumpAndSettle();
    expect(find.text('Pasir demo'), findsNothing);
    expect(find.text('TOTAL MODAL'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kalkulator demo menghitung contoh dan mempertahankan input', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav_calculator')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi contoh rit Rp8.200.000 / 26,46 m³'));
    await tester.pumpAndSettle();
    expect(find.text('Rp8.200.000'), findsNWidgets(2));
    expect(find.text('Rp9.261.000'), findsOneWidget);
    expect(find.text('Rp1.061.000'), findsOneWidget);
    expect(find.text('Rp309.902'), findsOneWidget);
    await tester.tap(find.text('Simpan Muatan'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(find.text('Muatan tersimpan'), findsOneWidget);
    expect(
      (await tester.runAsync(() => repository.db.query('loads')))!.length,
      1,
    );
    await tester.tap(find.byKey(const ValueKey('nav_material')));
    await tester.pumpAndSettle();
    expect(find.text('Daftar material'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('nav_calculator')));
    await tester.pumpAndSettle();
    expect(find.text('Rp8.200.000'), findsNWidgets(2));
    await tester.enterText(find.byKey(const ValueKey('input_0')), '2,5');
    await tester.pump();
    expect(find.text('Rp8.200.000'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
