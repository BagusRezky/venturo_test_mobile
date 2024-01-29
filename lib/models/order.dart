class OrderItem {
  final String nominalDiskon;
  final String nominalPesanan;
  final List<Item> items;

  OrderItem(
      {required this.nominalDiskon,
      required this.nominalPesanan,
      required this.items});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<Item> itemsList = list.map((i) => Item.fromJson(i)).toList();

    return OrderItem(
      nominalDiskon: json['nominal_diskon'],
      nominalPesanan: json['nominal_pesanan'],
      items: itemsList,
    );
  }
}

class Item {
  final int id;
  final int harga;
  final String catatan;

  Item({required this.id, required this.harga, required this.catatan});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      harga: json['harga'],
      catatan: json['catatan'],
    );
  }
}
