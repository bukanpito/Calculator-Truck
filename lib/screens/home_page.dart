import 'package:flutter/material.dart';

import 'calculator_page.dart';
import 'dashboard_page.dart';
import 'loads_page.dart';
import 'materials_page.dart';
import 'splash_screen.dart';
import '../models/material_item.dart';
import '../data/material_repository.dart';
import '../data/load_repository.dart';
import '../models/load_item.dart';
import '../services/calculation.dart';
import '../widgets/smooth_navigation_bar.dart';
import '../widgets/load_editor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.repository});
  final MaterialRepository? repository;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  List<MaterialItem> materials = [];
  MaterialRepository? repository;
  bool loading = true;
  bool busy = false;
  String? error;
  List<LoadItem> todayLoads = [], selectedLoads = [];
  DateTime rangeStart = _today();
  DateTime rangeEnd = _today();
  bool dashboardReset = false;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> refreshLoads() async {
    final repo = LoadRepository(repository!.db);
    final today = await repo.forDate(localDate(DateTime.now()));
    final resetId = await repo.resetId(localDate(DateTime.now()));
    final selected = await repo.forRange(rangeStart, rangeEnd);
    if (mounted) {
      setState(() {
        dashboardReset = resetId != null;
        todayLoads = today.where((row) => row.id > (resetId ?? 0)).toList();
        selectedLoads = selected;
      });
    }
  }

  Future<void> changeRange(DateTime start, DateTime end) async {
    final messenger = ScaffoldMessenger.of(context);
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day);
    setState(() {
      rangeStart = from;
      rangeEnd = to.isBefore(from) ? from : to;
    });
    try {
      final rows = await LoadRepository(repository!.db)
          .forRange(rangeStart, rangeEnd);
      if (mounted) setState(() => selectedLoads = rows);
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Gagal membaca transaksi. Coba kembali.'),
          ),
        );
      }
    }
  }

  Future<void> saveLoad(String material, Calculation value) async {
    await LoadRepository(repository!.db).save(material, value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Muatan berhasil disimpan.')),
      );
    }
    try {
      await refreshLoads();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Muatan tersimpan, tetapi tampilan belum diperbarui. Buka ulang aplikasi.',
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      repository ??= widget.repository ?? await MaterialRepository.open();
      final values = await repository!.load();
      await refreshLoads();
      if (mounted) {
        setState(() {
          materials = values;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Database tidak dapat dibuka. Coba kembali.';
        });
      }
    }
  }

  Future<void> mutate(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
      final values = await repository!.load();
      if (mounted) setState(() => materials = values);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Perubahan gagal. Coba kembali; pastikan nama material tidak duplikat.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = !loading && error == null;
    return Scaffold(
      appBar: ready ? AppBar(title: const Text('Material Tracker')) : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: loading
            ? const SplashScreen(key: ValueKey('splash'))
            : error != null
            ? Center(
                key: const ValueKey('error'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error!),
                    TextButton(
                      onPressed: initialize,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            : AbsorbPointer(
                key: const ValueKey('pages'),
                absorbing: busy,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: IndexedStack(
                      index: page,
                      children: [
                        DashboardPage(
                          reset: dashboardReset,
                          onReset: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Reset ringkasan?'),
                                content: const Text(
                                  'Ringkasan dimulai dari nol. Semua transaksi tetap tersimpan di Spreadsheet. Muatan baru akan masuk ringkasan sejak reset.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Reset ringkasan'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            try {
                              await LoadRepository(repository!.db)
                                  .resetDashboard(localDate(DateTime.now()));
                              await refreshLoads();
                            } catch (_) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Reset gagal. Coba kembali.'),
                                  ),
                                );
                              }
                            }
                          },
                          loads: todayLoads,
                          onCalculate: () => setState(() => page = 1),
                        ),
                        CalculatorPage(
                          materials: List.of(materials),
                          onSave: saveLoad,
                        ),
                        LoadsPage(
                          onDelete: (item) async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await LoadRepository(repository!.db)
                                  .delete(item.id);
                              await refreshLoads();
                            } catch (_) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tidak dapat menghapus atau memperbarui daftar. Coba muat ulang.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          onEdit: (item) => showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => LoadEditor(
                              item: item,
                              onSave: (name, value, stamp) async {
                                final messenger = ScaffoldMessenger.of(context);
                                await LoadRepository(
                                  repository!.db,
                                ).update(item, name, value, createdAt: stamp);
                                try {
                                  await refreshLoads();
                                } catch (_) {
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Perubahan tersimpan. Buka ulang untuk memperbarui tampilan.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          loads: selectedLoads,
                          start: rangeStart,
                          end: rangeEnd,
                          onRange: changeRange,
                        ),
                        MaterialsPage(
                          materials: materials,
                          onSave: (item) =>
                              mutate(() => repository!.save(item)),
                          onDelete: (item) =>
                              mutate(() => repository!.delete(item.id)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: ready
          ? SmoothNavigationBar(
              index: page,
              onChanged: (value) => setState(() => page = value),
              items: const [
                SmoothNavItem(
                  id: 'dashboard',
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                SmoothNavItem(
                  id: 'calculator',
                  icon: Icons.calculate_outlined,
                  selectedIcon: Icons.calculate,
                  label: 'Calculator',
                ),
                SmoothNavItem(
                  id: 'spreadsheet',
                  icon: Icons.table_chart_outlined,
                  selectedIcon: Icons.table_chart,
                  label: 'Spreadsheet',
                ),
                SmoothNavItem(
                  id: 'material',
                  icon: Icons.landscape_outlined,
                  selectedIcon: Icons.landscape,
                  label: 'Material',
                ),
              ],
            )
          : null,
    );
  }
}
