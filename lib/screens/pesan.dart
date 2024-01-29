import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:money_formatter/money_formatter.dart';
import 'package:venturo_test_mobile/models/menu.dart';
import 'package:venturo_test_mobile/models/voucher.dart';
import 'package:venturo_test_mobile/screens/widgets/widgets.dart';

class PesanScreen extends StatefulWidget {
  const PesanScreen({super.key});

  @override
  State<PesanScreen> createState() => _PesanScreenState();
}

class _PesanScreenState extends State<PesanScreen> {
  List dataVoucher = [];
  List<Map<String, dynamic>> dataOrder = [];
  late Future<List<MenuItem>> futureMenuItems;
  late Future<Voucher> futureVoucher;
  Map<int, int> itemCounts = {};
  int totalPesan = 0;
  int totalHarga = 0;
  int totalVoucher = 0;
  bool isVoucher = false;
  bool isSuccess = false;
  bool orderPlaced = false;
  final ctrlVoucher = TextEditingController();

  MoneyFormatter fmf_totalPesan = MoneyFormatter(
      amount: 0,
      settings: MoneyFormatterSettings(
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 0,
      ));

  MoneyFormatter fmf_totalHarga = MoneyFormatter(
      amount: 0,
      settings: MoneyFormatterSettings(
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 0,
      ));

  void incrementCount(int itemId) {
    if (!itemCounts.containsKey(itemId)) {
      itemCounts[itemId] = 1;
    } else {
      itemCounts[itemId] = itemCounts[itemId]! + 1;
    }
  }

  void decrementCount(int itemId) {
    if (itemCounts.containsKey(itemId) && itemCounts[itemId]! > 0) {
      itemCounts[itemId] = itemCounts[itemId]! - 1;
    }
  }

  void removeItem(List<Map<String, dynamic>> items, int id) {
    for (int i = 0; i < items.length; i++) {
      if (items[i]['id'] == id) {
        items.removeAt(i);
        break;
      }
    }
  }

  void cancelOrder() {
    const orderId = 'your_order_id';
    const url = 'https://tes-mobile.landa.id/api/order/cancel/$orderId';
    http.post(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          orderPlaced = false;
          totalPesan = 0;
          totalHarga = 0;
          totalVoucher = 0;
          dataOrder.clear();
          itemCounts.clear();
          fmf_totalPesan = MoneyFormatter(amount: 0);
          fmf_totalHarga = MoneyFormatter(amount: 0);
          print('Order berhasil dibatalkan');
        });
      } else {
        print('Gagal membatalkan pesanan. Status code: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error: $error');
    });
  }

  Future<List<MenuItem>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://tes-mobile.landa.id/api/menus'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body)['datas'];
      print(jsonResponse);
      return jsonResponse.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Voucher> fetchVoucher(String code) async {
    final response = await http
        .get(Uri.parse('https://tes-mobile.landa.id/api/vouchers?kode=$code'));
    if (response.statusCode == 200) {
      return Voucher.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> insertData(List<Map<String, dynamic>> dataOrder,
      int nominalDiskon, int nominalPesanan) async {
    var url = Uri.parse('https://tes-mobile.landa.id/api/order');
    var order = {
      "nominal_diskon": nominalDiskon,
      "nominal_pesanan": nominalPesanan,
      "items": dataOrder
    };
    print(order);
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(order),
    );

    if (response.statusCode == 200) {
      print('Data successfully posted');
      setState(() {
        isSuccess = true;
      });
    } else {
      print('Error : ${response.statusCode}');
    }
  }

  List<MenuItem> parseMenuItems(String responseBody) {
    final parsed =
        jsonDecode(responseBody)['datas'].cast<Map<String, dynamic>>();
    return parsed.map<MenuItem>((json) => MenuItem.fromJson(json)).toList();
  }

  @override
  void initState() {
    futureMenuItems = fetchData();
    print(futureMenuItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<MenuItem>>(
          future: futureMenuItems,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 8, left: 25, right: 25, bottom: 8),
                    child: buildMenuItemCard(snapshot.data![index], () {
                      setState(() {
                        incrementCount(snapshot.data![index].id);
                        dataOrder.add({
                          'id': snapshot.data![index].id,
                          'harga': snapshot.data![index].harga,
                          'catatan': '',
                        });
                        totalPesan = dataOrder.fold<int>(
                            0, (sum, item) => sum + (item['harga'] as int));

                        fmf_totalPesan =
                            MoneyFormatter(amount: totalPesan.toDouble());
                        if (totalPesan < totalVoucher) {
                          totalHarga = 0;
                        } else {
                          totalHarga = totalPesan - totalVoucher;
                        }
                        fmf_totalHarga =
                            MoneyFormatter(amount: totalHarga.toDouble());
                      });

                      print(dataOrder);
                    }, () {
                      setState(() {
                        decrementCount(snapshot.data![index].id);
                        removeItem(dataOrder, snapshot.data![index].id);
                        totalPesan = dataOrder.fold<int>(
                            0, (sum, item) => sum + (item['harga'] as int));
                        fmf_totalPesan =
                            MoneyFormatter(amount: totalPesan.toDouble());

                        if (totalPesan < totalVoucher) {
                          totalHarga = 0;
                        } else {
                          totalHarga = totalPesan - totalVoucher;
                        }

                        fmf_totalHarga =
                            MoneyFormatter(amount: totalHarga.toDouble());
                      });

                      print(dataOrder);
                    }, itemCounts[snapshot.data![index].id] ?? 0),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
        bottomNavigationBar: !isVoucher
            ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Total Pesanan (${dataOrder.length} Menu) : ',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                'Rp ${fmf_totalPesan.output.nonSymbol.toString()}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 0, 154, 173),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Divider(),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.asset(
                                    'assets/images/Vector_voucher.png'),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text('Voucher',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const Spacer(),
                              TextButton(
                                  child: totalVoucher == 0
                                      ? Text(
                                          'Input Voucher >',
                                          style: TextStyle(
                                              color: Colors.grey.shade600),
                                        )
                                      : Text(
                                          '- $totalVoucher',
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      isVoucher = true;
                                    });
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom:
                        0, // This positions the Container at the bottom of the Stack
                    child: Container(
                      width: MediaQuery.of(context)
                          .size
                          .width, // This provides a specific width to the Positioned widget
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset('assets/images/Vector_cart.png'),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Total Pembayaran'),
                              Text(
                                'Rp ${fmf_totalHarga.output.nonSymbol.toString()}',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 154, 173),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 154, 173),
                              shadowColor: Colors.black,
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              if (!isSuccess) {
                                insertData(dataOrder, totalPesan, totalHarga);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      content: Container(
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.warning_amber_outlined,
                                              color: Color.fromARGB(
                                                  255, 0, 154, 173),
                                              size: 75,
                                            ),
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: Text(
                                                'Apakah Anda yakin ingin membatalkan pesanan?',
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    side: const BorderSide(
                                                      color: Color.fromARGB(
                                                          255,
                                                          0,
                                                          154,
                                                          173), // Warna garis samping
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Batal',
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 0, 154, 173)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8),
                                                child: TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    cancelOrder();
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 0, 154, 173),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Yakin',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: !isSuccess
                                ? const Text(
                                    'Pesan Sekarang',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                : const Text(
                                    'Batalkan',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: 210,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 3, // Shadow spread radius
                      blurRadius: 3, // Shadow blur radius
                      offset: const Offset(0, 1), // Shadow position
                    ),
                  ],
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Image.asset(
                                  'assets/images/Vector_voucher.png'),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('Punya kode voucher?',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Text('Masukkan kode voucher disini'),
                        TextFormField(
                          controller: ctrlVoucher,
                          decoration: InputDecoration(
                            labelText: 'Enter Voucher',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVoucher = false;
                                });
                                ctrlVoucher.clear(); // Clear the text
                              },
                              icon: const Icon(Icons.clear),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 154, 173),
                                shadowColor: Colors
                                    .black, // This is the button's shadow color
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () {
                                fetchVoucher(ctrlVoucher.text).then((voucher) {
                                  setState(() {
                                    totalVoucher = voucher.datas.nominal;
                                    isVoucher = false;
                                    totalHarga = totalPesan - totalVoucher;
                                    if (totalHarga < 0) {
                                      totalHarga = 0;
                                    }
                                    fmf_totalHarga = MoneyFormatter(
                                        amount: totalHarga.toDouble());
                                    print(totalVoucher);
                                    print(totalHarga);
                                    print(totalPesan);
                                  });
                                });
                              },
                              child: const Text(
                                'Validasi Voucher',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        )
                      ]),
                ),
              ));
  }
}
