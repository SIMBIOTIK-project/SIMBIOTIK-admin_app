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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:simbiotik_admin/core/blocs/deposit/deposit.dart';
import 'package:simbiotik_admin/core/blocs/waste_type/waste_type_bloc.dart';
import 'package:simbiotik_admin/core/blocs/withdrawal/withdrawal.dart';
import 'package:simbiotik_admin/core/blocs/withdrawal/withdrawal_bloc.dart';
import 'package:simbiotik_admin/gen/assets.gen.dart';
import 'package:simbiotik_admin/models/models.dart';
import 'package:simbiotik_admin/utils/utils.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  const DashboardScreen({
    required this.token,
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool isSwitchedMode = false;
  late TextEditingController _idNasabah;
  late TextEditingController _idNasabahWithdrawal;
  late TextEditingController _weight;
  late TextEditingController _price;
  late TextEditingController _note;

  List<WasteTypesModel> items = [];

  WasteTypesModel? selectedItem;
  String? selectedPrice;

  late TabController _tabController;

  int _selectedTabBarIndex = 0;
  final _selectedColor = Colors.teal;
  final _tabs = [
    const Tab(
      text: 'Setoran',
    ),
    const Tab(
      text: 'Penarikan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _idNasabah = TextEditingController();
    _idNasabahWithdrawal = TextEditingController();
    _weight = TextEditingController();
    _price = TextEditingController();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultiBlocListener(
      listeners: [
        BlocListener<DepositBloc, DepositState>(
          listener: (context, state) {
            if (state.status.isLoading) {
              showDialog(
                context: context,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state.status.isLoaded) {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil ditambahkan')),
              );
              setState(() {
                _idNasabah.text = '';
                selectedItem = null;
                _weight.text = '';
              });
            } else if (state.status.isError) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            }
          },
        ),
        BlocListener<WithdrawalBloc, WithdrawalState>(
          listener: (context, state) {
            if (state.status.isLoading) {
              showDialog(
                context: context,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state.status.isLoaded) {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Penarikan berhasil')),
              );
              setState(() {
                _idNasabahWithdrawal.text = '';
                _price.text = '';
                _note.text = '';
              });
            } else if (state.status.isError) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            }
          },
        )
      ],
      child: Padding(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Beranda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                Row(
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
                          if (isSwitchedMode == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Fitur masih dalam pengembangan!'),
                              ),
                            );
                          }
                        });
                      },
                    )
                  ],
                )
              ],
            ),
            const Gap(20.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: kToolbarHeight - 20.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        onTap: (index) {
                          setState(() {
                            _selectedTabBarIndex = index;
                          });
                        },
                        tabs: _tabs,
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: _selectedColor),
                        labelColor: Colors.white,
                        indicatorPadding: EdgeInsets.zero,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                    const Gap(8.0),
                    _selectedTabBarIndex == 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Masukkan Penarikan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(8.0),
                              _buildWithdrawal(context),
                              const Gap(8.0),
                              const Divider(),
                              const Gap(8.0),
                            ],
                          ),
                    _buildDraft(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
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
                controller: _weight,
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
                    _weight.text = value.replaceAll(',', '.');
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
            BlocBuilder<WasteTypeBloc, WasteTypeState>(
              builder: (context, state) {
                if (state.status.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (state.error != null && state.allData == null) {
                    return const Text('Data tidak ditemukan');
                  } else {
                    items = state.allData ?? [];
                    return Container(
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
                        items:
                            items.map<DropdownMenuItem<WasteTypesModel>>((e) {
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
                    );
                  }
                }
              },
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
                  (selectedPrice != null && _weight.text.isNotEmpty)
                      ? formatCurrency(parseOrZero(_weight.text) *
                          parseOrZero(selectedPrice))
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
                        _weight.text != '' &&
                        selectedItem != null)
                    ? () {
                        int total =
                            int.parse(_weight.text) * int.parse(selectedPrice!);

                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Setor'),
                              content: Text(
                                  'Apakah anda yakin akan melakukan setoran untuk nasabah ${_idNasabah.text}?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    context.read<DepositBloc>().add(
                                          DepositEvent.postDeposit(
                                            request: DepositRequestModel(
                                              idUser:
                                                  _idNasabah.text.toUpperCase(),
                                              idWasteType:
                                                  selectedItem!.id!.toString(),
                                              weight: _weight.text,
                                              price: total.toString(),
                                            ),
                                            token: widget.token,
                                          ),
                                        );
                                  },
                                  child: const Text('Ya, Setor'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('Tidak'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    : null,
                child: const Text(
                  'Setor',
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

  _buildWithdrawal(BuildContext context) {
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
                controller: _idNasabahWithdrawal,
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
              'Jumlah Penarikan (Rp)',
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
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9]*[.,]?[0-9]*$')),
                ],
                decoration: const InputDecoration(
                  hintText: 'Masukkan jumlah penarikan (100000)',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _price.text = value.replaceAll(RegExp(r'[.,]'), '');
                  });
                },
              ),
            ),
            const Gap(8.0),
            const Text(
              'Keterangan',
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
                controller: _note,
                decoration: const InputDecoration(
                  hintText: 'Masukkan keterangan',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _note.text = value;
                  });
                },
              ),
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
                onPressed: (_idNasabahWithdrawal.text.isNotEmpty &&
                        _price.text.isNotEmpty &&
                        _note.text.isNotEmpty)
                    ? () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Tarik Dana'),
                              content: Text(
                                  'Apakah anda yakin akan melakukan penarikan untuk nasabah ${_idNasabahWithdrawal.text}?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    context.read<WithdrawalBloc>().add(
                                          WithdrawalEvent.postWithdrawal(
                                            request: WithdrawalsRequestModel(
                                              idUser: _idNasabahWithdrawal.text
                                                  .toUpperCase(),
                                              price: _price.text,
                                              status: _note.text,
                                            ),
                                            token: widget.token,
                                          ),
                                        );
                                  },
                                  child: const Text('Ya, Tarik Dana'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('Tidak'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    : null,
                child: const Text(
                  'Tarik Dana',
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
