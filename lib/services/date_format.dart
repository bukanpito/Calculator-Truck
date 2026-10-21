const monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const shortMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// `21 Oktober 2026` or `21 Oktober` when [withYear] is false.
String formattedDate(DateTime date, {bool withYear = true}) =>
    '${date.day} ${monthNames[date.month - 1]}${withYear ? ' ${date.year}' : ''}';

/// `21 Okt` from a stored `YYYY-MM-DD` date.
String shortDate(String isoDate) {
  final parts = isoDate.split('-');
  final month = parts.length == 3 ? int.tryParse(parts[1]) : null;
  final day = parts.length == 3 ? int.tryParse(parts[2]) : null;
  if (month == null || day == null || month < 1 || month > 12) return isoDate;
  return '$day ${shortMonthNames[month - 1]}';
}

/// `10:30` from a stored ISO timestamp.
String clockText(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';
