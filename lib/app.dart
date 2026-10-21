import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'data/material_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});
  final MaterialRepository? repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Material Tracker',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00412E))
          .copyWith(
            primary: const Color(0xFF00412E),
            onPrimary: Colors.white,
            primaryContainer: const Color(0xFF96BF8A),
            onPrimaryContainer: const Color(0xFF00412E),
            secondary: const Color(0xFF00412E),
            secondaryContainer: const Color(0xFF96BF8A),
            onSecondaryContainer: const Color(0xFF00412E),
            surface: Colors.white,
            onSurface: const Color(0xFF00412E),
            outlineVariant: const Color(0xFFE8EAE5),
          ),
      scaffoldBackgroundColor: const Color(0xFFE8EAE5),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x6600412E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF00412E),
        elevation: 4,
        scrolledUnderElevation: 6,
        shadowColor: Color(0x6600412E),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFF96BF8A),
        elevation: 8,
        shadowColor: Color(0x6600412E),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 4,
          shadowColor: const Color(0x6600412E),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 12,
        shadowColor: Color(0x6600412E),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
      useMaterial3: true,
    ),
    home: HomePage(repository: repository),
  );
}
