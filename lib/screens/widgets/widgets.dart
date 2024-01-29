// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:venturo_test_mobile/models/menu.dart';

Widget buildMenuItemCard(
    MenuItem item, VoidCallback onAdd, VoidCallback onReduce, int counter) {
  MoneyFormatter fmf = MoneyFormatter(
      amount: item.harga.toDouble(),
      settings: MoneyFormatterSettings(
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 0,
      ));

  //TextEditingController notesController = TextEditingController();

  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 3,
          offset: const Offset(0, 3),
        ),
      ],
      color: Colors.grey.shade100,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            width: 70,
            height: 70,
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: Image.network(
                item.gambar,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nama,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp ${fmf.output.nonSymbol.toString()}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 154, 173),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Image.asset('assets/images/Vector_note.png'),
                  const Text(
                    'Tambahkan Catatan',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Material(
                  child: InkWell(
                    onTap: onReduce,
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: Image.asset('assets/images/Vector_min.png'),
                    ),
                  ),
                ),
              ),
              Text(
                counter.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Material(
                  child: InkWell(
                    onTap: onAdd,
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: Image.asset('assets/images/Vector_plus.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
