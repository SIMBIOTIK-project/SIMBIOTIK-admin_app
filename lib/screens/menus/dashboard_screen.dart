// Copyright 2024 SIMBIOTIK Developer
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:simbiotik_admin/gen/assets.gen.dart';
import 'package:simbiotik_admin/models/waste_types/waste_types.dart';
import 'package:simbiotik_admin/utils/utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isSwitchedMode = false;
  final TextEditingController _idNasabah = TextEditingController();

  List<WasteTypesModel> items = [
    WasteTypesModel(
        id: 2,
        type: 'botol',
        price: '1000',
        createdAt: DateTime.parse('2024-08-13T11:33:38.000000Z'),
        updatedAt: DateTime.parse('2024-08-13T11:33:38.000000Z')),
    WasteTypesModel(
        id: 1,
        type: 'plastik',
        price: '2000',
        createdAt: DateTime.parse('2024-08-13T10:35:26.000000Z'),
        updatedAt: DateTime.parse('2024-08-13T12:48:55.000000Z')),
  ];

  WasteTypesModel? selectedItem;
  String? selectedPrice;
  String? weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isSwitchedMode == false ? 'Manual' : 'Bluetooth',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(8.0),
                  FlutterSwitch(
                    width: 50,
                    height: 25,
                    value: isSwitchedMode,
                    onToggle: (value) {
                      setState(() {
                        isSwitchedMode = value;
                      });
                    },
                  )
                ],
              ),
              const Text(
                'Mulai Timbang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8.0),
              _buildScales(context),
              const Gap(8.0),
              const Divider(),
              const Gap(8.0),
              _buildDraft(context),
            ],
          ),
        ),
      ),
    );
  }

  _buildScales(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ID Nasabah',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black12,
                ),
                borderRadius: BorderRadius.circular(
                  8.0,
                ),
              ),
              height: 40,
              padding: const EdgeInsets.fromLTRB(
                8,
                4,
                8,
                4,
              ),
              child: TextField(
                controller: _idNasabah,
                decoration: const InputDecoration(
                  hintText: 'Masukkan ID nasabah',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                ),
              ),
            ),
            const Gap(8.0),
            const Text(
              'Berat (Kg)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black12,
                ),
                borderRadius: BorderRadius.circular(
                  8.0,
                ),
              ),
              height: 40,
              padding: const EdgeInsets.fromLTRB(
                8,
                4,
                8,
                4,
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9]*[.,]?[0-9]*$')),
                ],
                decoration: InputDecoration(
                  enabled: isSwitchedMode ? false : true,
                  hintText: 'Masukkan berat sampah ',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    setState(() {
                      weight = value.replaceAll(',', '.');
                    });
                  });
                },
              ),
            ),
            const Gap(8.0),
            const Text(
              'Jenis Sampah',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8.0),
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black12,
                ),
                borderRadius: BorderRadius.circular(
                  8.0,
                ),
              ),
              child: DropdownButton<WasteTypesModel>(
                borderRadius: BorderRadius.circular(
                  8.0,
                ),
                underline: const SizedBox.shrink(),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                isExpanded: true,
                hint: const Text(
                  'Pilih jenis sampah',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                value: selectedItem,
                items: items.map<DropdownMenuItem<WasteTypesModel>>((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.type!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedItem = value;
                    selectedPrice = value?.price;
                  });
                },
              ),
            ),
            const Gap(16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  (selectedPrice != null && weight != null)
                      ? formatCurrency(
                          parseOrZero(weight) * parseOrZero(selectedPrice))
                      : formatCurrency(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hijauSimbiotik,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                onPressed: (_idNasabah.text.isNotEmpty &&
                        weight != null &&
                        selectedItem != null &&
                        weight != '')
                    ? () {}
                    : null,
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildDraft(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Draft',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          '*Draft disimpan sementara dalam memori telepon, upload data jika jaringan internet sudah tersedia',
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.file14592169.image(
                height: 100,
                width: 100,
              ),
              const Gap(8.0),
              const Text('Tidak draft yang tersimpan')
            ],
          ),
        ),
      ],
    );
  }
}
