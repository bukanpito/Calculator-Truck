import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_truck/main.dart';

void main() {
  testWidgets('Tambah dan hapus material terhubung ke kalkulator', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.widgetWithText(NavigationDestination, 'Material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah material'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Pasir demo');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();
    expect(find.text('Pasir demo'), findsOneWidget);
    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();
    expect(find.text('Ongkos kirim'), findsNothing);
    expect(find.text('Diskon'), findsNothing);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pasir demo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi contoh 24,17 × 370.000'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL MODAL'), findsOneWidget);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Material'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus Pasir demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculator'));
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
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Isi contoh 24,17 × 370.000'));
    await tester.pumpAndSettle();
    expect(find.text('Rp8.942.900'), findsNWidgets(2));
    await tester.tap(find.widgetWithText(NavigationDestination, 'Material'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar material'), findsOneWidget);
    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();
    expect(find.text('Rp8.942.900'), findsNWidgets(2));
    await tester.enterText(find.byKey(const ValueKey('input_0')), '2,5');
    await tester.pump();
    expect(find.text('Rp8.942.900'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
