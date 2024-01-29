class Voucher {
  final int statusCode;
  final Data datas;

  Voucher({required this.statusCode, required this.datas});

  factory Voucher.fromJson(Map<String, dynamic> json) {
    var data = Data.fromJson(json['datas'] as Map<String, dynamic>);
    return Voucher(
      statusCode: json['status_code'],
      datas: data,
    );
  }
}

class Data {
  final int id;
  final String kode;
  final int nominal;
  final String createdAt;
  final String updatedAt;

  Data(
      {required this.id,
      required this.kode,
      required this.nominal,
      required this.createdAt,
      required this.updatedAt});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      kode: json['kode'],
      nominal: json['nominal'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
