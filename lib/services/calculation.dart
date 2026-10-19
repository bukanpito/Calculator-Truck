// ponytail: volume maksimum 1 juta m³, harga maksimum 1 miliar Rupiah;
// gunakan BigInt end-to-end bila batas bisnis perlu diperluas.
const volumeScale = 1000000;

int parseVolume(String text) {
  final value = text.trim().replaceAll('.', ',');
  if (!RegExp(r'^\d+(,\d{1,6})?$').hasMatch(value)) {
    throw const FormatException('Isi volume valid, maksimal 6 desimal.');
  }
  final parts = value.split(',');
  final units =
      BigInt.parse(parts[0]) * BigInt.from(volumeScale) +
      BigInt.parse(parts.length == 2 ? parts[1].padRight(6, '0') : '0');
  if (units <= BigInt.zero || units > BigInt.from(1000000 * volumeScale)) {
    throw const FormatException('Volume harus > 0 dan maksimal 1.000.000 m³.');
  }
  return units.toInt();
}

int parseMoney(String text, {bool optional = false}) {
  final value = text.trim();
  if (optional && value.isEmpty) return 0;
  if (!RegExp(r'^(\d+|\d{1,3}(\.\d{3})+)$').hasMatch(value)) {
    throw const FormatException(
      'Isi Rupiah bulat, contoh 370000 atau 370.000.',
    );
  }
  final amount = BigInt.parse(value.replaceAll('.', ''));
  if (amount > BigInt.from(1000000000)) {
    throw const FormatException('Maksimal Rp1.000.000.000 per input.');
  }
  return amount.toInt();
}

String rupiah(int value) =>
    'Rp${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

String volumeText(int units) {
  final fraction = (units % volumeScale)
      .toString()
      .padLeft(6, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return '${units ~/ volumeScale}${fraction.isEmpty ? '' : ',$fraction'}';
}

class Calculation {
  Calculation({
    required this.volume,
    required this.price,
    this.extra = 0,
    this.shipping = 0,
    this.discount = 0,
    this.salePrice,
  }) {
    if (volume <= 0 ||
        volume > 1000000 * volumeScale ||
        [
          price,
          extra,
          shipping,
          discount,
          ?salePrice,
        ].any((n) => n < 0 || n > 1000000000)) {
      throw const FormatException('Nilai perhitungan di luar batas.');
    }
    if (discount > subtotal + extra + shipping) {
      throw const FormatException('Diskon tidak boleh melebihi total biaya.');
    }
  }
  final int volume, price, extra, shipping, discount;
  final int? salePrice;

  int multiply(int price) =>
      ((BigInt.from(volume) * BigInt.from(price) +
                  BigInt.from(volumeScale ~/ 2)) ~/
              BigInt.from(volumeScale))
          .toInt();
  int get subtotal => multiply(price);
  int get total => subtotal + extra + shipping - discount;
  int? get sales => salePrice == null ? null : multiply(salePrice!);
  int? get profit => sales == null ? null : sales! - total;
}
