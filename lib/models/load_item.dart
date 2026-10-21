import '../services/calculation.dart';

String localDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class LoadItem {
  const LoadItem({
    required this.id,
    required this.material,
    required this.createdAt,
    required this.date,
    required this.value,
  });
  final int id;
  final String material, createdAt, date;
  final Calculation value;
}
