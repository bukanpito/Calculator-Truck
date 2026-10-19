import 'package:flutter/material.dart';

import 'calculator_page.dart';
import 'preview_pages.dart';
import 'materials_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  final materials = List<String>.of(demoMaterials);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('MaterialTrack'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(38),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: const Text(
            'Mode demo • data tidak disimpan',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: IndexedStack(
          index: page,
          children: [
            DashboardPage(onCalculate: () => setState(() => page = 1)),
            CalculatorPage(materials: List.of(materials)),
            const SpreadsheetPage(),
            MaterialsPage(
              materials: materials,
              onAdd: (name) => setState(() => materials.add(name)),
              onDelete: (name) => setState(() => materials.remove(name)),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: page,
      onDestinationSelected: (value) => setState(() => page = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          label: 'Calculator',
        ),
        NavigationDestination(
          icon: Icon(Icons.table_chart_outlined),
          label: 'Spreadsheet',
        ),
        NavigationDestination(
          icon: Icon(Icons.landscape_outlined),
          label: 'Material',
        ),
      ],
    ),
  );
}
