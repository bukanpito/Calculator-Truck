import 'package:flutter/material.dart';

import 'calculator_page.dart';
import 'dashboard_page.dart';
import 'loads_page.dart';
import 'materials_page.dart';
import '../models/material_item.dart';
import '../data/material_repository.dart';
import '../data/load_repository.dart';
import '../models/load_item.dart';
import '../services/calculation.dart';
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
  DateTime selectedDate = DateTime.now();
  bool dashboardReset = false;

  Future<void> refreshLoads() async {
    final repo = LoadRepository(repository!.db);
    final today = await repo.forDate(localDate(DateTime.now()));
    final resetId = await repo.resetId(localDate(DateTime.now()));
    final selected = await repo.forDate(localDate(selectedDate));
    if (mounted) {
      setState(() {
        dashboardReset = resetId != null;
        todayLoads = today.where((row) => row.id > (resetId ?? 0)).toList();
        selectedLoads = selected;
      });
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Material Tracker')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
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
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
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
                          await LoadRepository(repository!.db).delete(item.id);
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
                          onSave: (name, value) async {
                            final messenger = ScaffoldMessenger.of(context);
                            await LoadRepository(repository!.db)
                                .update(item, name, value);
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
                      date: selectedDate,
                      onDate: (date) async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final rows = await LoadRepository(repository!.db)
                              .forDate(localDate(date));
                          if (mounted) {
                            setState(() {
                              selectedDate = date;
                              selectedLoads = rows;
                            });
                          }
                        } catch (_) {
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gagal membaca transaksi. Coba kembali.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    MaterialsPage(
                      materials: materials,
                      onSave: (item) => mutate(() => repository!.save(item)),
                      onDelete: (item) =>
                          mutate(() => repository!.delete(item.id)),
                    ),
                  ],
                ),
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
