class MenuItem {
  final int id;
  final String nama;
  final int harga;
  final String tipe;
  final String gambar;

  MenuItem(
      {required this.id,
      required this.nama,
      required this.harga,
      required this.tipe,
      required this.gambar});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      tipe: json['tipe'],
      gambar: json['gambar'],
    );
  }
}
