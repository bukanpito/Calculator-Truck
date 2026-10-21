class MaterialItem {
  const MaterialItem({
    required this.id,
    required this.name,
    this.price,
    this.stone = false,
  });
  final int id;
  final String name;
  final int? price;
  final bool stone;
}
