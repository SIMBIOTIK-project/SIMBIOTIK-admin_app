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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logger/web.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<DepositRequestModel> _depositList = [];
  List<WithdrawalsRequestModel> _withdrawalList = [];

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

  int? selectedIndexDeposit;
  int? selectedIndexWithdrawal;

  // Bluetooth setup
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  bool isConnected = false;
  late String receivedData;
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _idNasabah = TextEditingController();
    _idNasabahWithdrawal = TextEditingController();
    _weight = TextEditingController();
    _price = TextEditingController();
    _note = TextEditingController();
    _checkPermissions();
    _loadListDeposit();
    _loadListWithdrawal();
  }

  /// Check permission bluetooh and location
  Future<void> _checkPermissions() async {
    if (await Permission.bluetooth.isDenied ||
        await Permission.bluetoothScan.isDenied ||
        await Permission.bluetoothConnect.isDenied ||
        await Permission.location.isDenied) {
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
    }

    if (await Permission.bluetoothConnect.isGranted) {
      _discoverDevices();
    }
  }

  /// Check discover devices
  Future<void> _discoverDevices() async {
    List<BluetoothDevice> devices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    setState(() {
      _devices = devices;
    });
  }

  /// Connect to bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        isConnected = true;
        _selectedDevice = device;
      });

      _connection!.input!.listen((data) {
        setState(() {
          receivedData = String.fromCharCodes(data).trim();
          if (receivedData.isNotEmpty) {
            _weight.text = receivedData;
          }
        });
      });
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  /// Disconnect bluetooth device
  Future<void> _disconnectFromDevice() async {
    if (_connection != null) {
      await _connection!.close();
      setState(() {
        _connection = null;
        isConnected = false;
        _selectedDevice = null;
        receivedData = '';
      });
      Logger().i('Disconnected');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _disconnectFromDevice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: MultiBlocListener(
      listeners: [
        /// Listener for Deposit
        BlocListener<DepositBloc, DepositState>(
          listener: (context, state) async {
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
              if (selectedIndexDeposit != null) {
                await _deleteDepositAtIndex(selectedIndexDeposit!);
              }
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

        /// Listener for Withdrawal
        BlocListener<WithdrawalBloc, WithdrawalState>(
          listener: (context, state) async {
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
              if (selectedIndexWithdrawal != null) {
                await _deleteWithdrawalAtIndex(selectedIndexWithdrawal!);
              }
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
                          isConnected
                              ? _disconnectFromDevice()
                              : _discoverDevices();
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
            const Gap(8.0),
            if (isSwitchedMode == true)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: DropdownButton<BluetoothDevice>(
                  underline: const SizedBox.shrink(),
                  value: _selectedDevice,
                  hint: const Text('Pilih Perangkat Bluetooth'),
                  isExpanded: true,
                  items: _devices.map((BluetoothDevice device) {
                    return DropdownMenuItem<BluetoothDevice>(
                      value: device,
                      child: Text(device.name ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (BluetoothDevice? newValue) {
                    if (newValue != null) {
                      _connectToDevice(newValue);
                    }
                  },
                ),
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

  /// Build Deposit form screen
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
                Logger().d(state.error);
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${e.type}'),
                                Text('Rp.${e.price}'),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedItem = value;
                            selectedPrice = value?.price.toString();
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
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Setor'),
                              content: Text(
                                  'Apakah anda yakin akan melakukan setoran untuk nasabah ${_idNasabah.text}?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible:
                                          false, // Mencegah dialog tertutup saat menunggu
                                      builder: (BuildContext context) {
                                        return const Dialog(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(width: 20),
                                                Text("Memeriksa koneksi..."),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    bool isConnected =
                                        await InternetConnectionChecker.instance
                                            .hasConnection;

                                    _buildPop();

                                    if (isConnected) {
                                      Logger().i('Terhubung ke internet');
                                      _handleSendData();
                                    } else {
                                      _handleSaveDepositToLocal();
                                      Logger().i('Tidak terhubung ke internet');
                                    }
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

  /// Send data to database for deposit
  _handleSendData() {
    double total = double.parse(_weight.text) * double.parse(selectedPrice!);
    int totalPrice = total.toInt();
    context.read<DepositBloc>().add(
          DepositEvent.postDeposit(
            request: DepositRequestModel(
              idUser: _idNasabah.text.toUpperCase(),
              idWasteType: selectedItem!.id!.toString(),
              weight: _weight.text,
              price: totalPrice.toString(),
            ),
            token: widget.token,
          ),
        );
  }

  /// Save data to local deposit
  _handleSaveDepositToLocal() async {
    int total = int.parse(_weight.text) * int.parse(selectedPrice!);
    DepositRequestModel newDeposit = DepositRequestModel(
      idUser: _idNasabah.text.toUpperCase(),
      idWasteType: selectedItem!.id!.toString(),
      weight: _weight.text,
      price: total.toString(),
    );

    setState(() {
      _depositList.add(newDeposit);
    });

    await saveListDeposit(_depositList);
    Logger().i('Berhasil simpan $_depositList');
    setState(() {
      _idNasabah.text = '';
      selectedItem = null;
      _weight.text = '';
    });
    _buildPop();
  }

  /// Save to list deposit
  Future<void> saveListDeposit(List<DepositRequestModel> listDeposit) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        listDeposit.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('listDeposit', jsonList);
  }

  /// Get list deposit
  Future<List<DepositRequestModel>> getListDeposit() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('listDeposit') ?? [];
    return jsonList
        .map((item) => DepositRequestModel.fromJson(jsonDecode(item)))
        .toList();
  }

  /// Load list deposit from local
  Future<void> _loadListDeposit() async {
    List<DepositRequestModel> list = await getListDeposit();
    setState(() {
      _depositList = list;
    });
  }

  /// Delete deposit based on index
  Future<void> _deleteDepositAtIndex(int index) async {
    List<DepositRequestModel> list = await getListDeposit();
    list.removeAt(index);
    await saveListDeposit(list);
    setState(() {
      _depositList = list;
    });
    Logger().i('Data berhasil dihapus');
  }

  /// Build list card ui for local deposit
  _buildListLocalDeposit(
      BuildContext context, DepositRequestModel deposit, int index) {
    return Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jumlah Setoran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatCurrency(double.parse(deposit.price!)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const Gap(8),
            _buildRowText(
              context,
              'ID Nasabah',
              '${deposit.idUser}',
            ),
            const Gap(8),
            _buildRowText(
              context,
              'Berat',
              '${deposit.weight} kg',
            ),
            const Gap(8),
            _buildRowText(
              context,
              'Jenis Sampah',
              '${deposit.idWasteType}',
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Hapus Setoran'),
                            content: const Text(
                                'Apakah anda yakin akan menghapus setoran?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  _deleteDepositAtIndex(index);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ya, Hapus'),
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
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Gap(8.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Setoran'),
                            content: const Text(
                                'Apakah anda yakin akan melakukan upload setoran?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        false, // Mencegah dialog tertutup saat menunggu
                                    builder: (BuildContext context) {
                                      return const Dialog(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 20),
                                              Text("Memeriksa koneksi..."),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  bool isConnected =
                                      await InternetConnectionChecker.instance
                                          .hasConnection;

                                  _buildPop();

                                  if (isConnected) {
                                    selectedIndexDeposit = index;
                                    _buildUploadFromLocalDeposit(deposit);
                                    Logger().i('Terhubung ke internet');
                                  } else {
                                    _buildNotConnected();
                                    _buildPop();
                                    Logger().i('Tidak terhubung ke internet');
                                  }
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
                    },
                    child: const Text(
                      'Setor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Upload data from local deposit to database
  _buildUploadFromLocalDeposit(DepositRequestModel data) {
    context.read<DepositBloc>().add(
          DepositEvent.postDeposit(
            request: DepositRequestModel(
              idUser: data.idUser,
              idWasteType: data.idWasteType,
              weight: data.weight,
              price: data.price,
            ),
            token: widget.token,
          ),
        );
  }

  /// Build form ui for withdrawal
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
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible:
                                          false, // Mencegah dialog tertutup saat menunggu
                                      builder: (BuildContext context) {
                                        return const Dialog(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(width: 20),
                                                Text("Memeriksa koneksi..."),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    bool isConnected =
                                        await InternetConnectionChecker.instance
                                            .hasConnection;

                                    _buildPop();

                                    if (isConnected) {
                                      Logger().i('Terhubung ke internet');
                                      _handleSendDataWithdrawal();
                                    } else {
                                      _handleSaveWithdrawalToLocal();
                                      Logger().i('Tidak terhubung ke internet');
                                    }
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

  /// Send data to database withdrawal
  _handleSendDataWithdrawal() {
    context.read<WithdrawalBloc>().add(
          WithdrawalEvent.postWithdrawal(
            request: WithdrawalsRequestModel(
              idUser: _idNasabahWithdrawal.text.toUpperCase(),
              price: _price.text,
              status: _note.text,
            ),
            token: widget.token,
          ),
        );
  }

  /// Save data withdrawal to local
  _handleSaveWithdrawalToLocal() async {
    WithdrawalsRequestModel newWithdrawal = WithdrawalsRequestModel(
      idUser: _idNasabahWithdrawal.text.toUpperCase(),
      price: _price.text,
      status: _note.text,
    );

    setState(() {
      _withdrawalList.add(newWithdrawal);
    });

    await saveListWithdrawal(_withdrawalList);
    Logger().i('Berhasil simpan $_withdrawalList');
    setState(() {
      _idNasabahWithdrawal.text = '';
      _price.text = '';
      _note.text = '';
    });
    _buildPop();
  }

  /// Upload data from local withdrawal to database
  _buildUploadFromLocalWithdrawal(WithdrawalsRequestModel data) {
    context.read<WithdrawalBloc>().add(
          WithdrawalEvent.postWithdrawal(
            request: WithdrawalsRequestModel(
              idUser: data.idUser,
              price: data.price,
              status: data.status,
            ),
            token: widget.token,
          ),
        );
  }

  /// Save list withdrawal
  Future<void> saveListWithdrawal(
      List<WithdrawalsRequestModel> listWithdrawal) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        listWithdrawal.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('listWithdrawal', jsonList);
  }

  /// Get list withdrawal
  Future<List<WithdrawalsRequestModel>> getListWithdrawal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('listWithdrawal') ?? [];
    return jsonList
        .map((item) => WithdrawalsRequestModel.fromJson(jsonDecode(item)))
        .toList();
  }

  /// Load list withdrawal
  Future<void> _loadListWithdrawal() async {
    List<WithdrawalsRequestModel> list = await getListWithdrawal();
    setState(() {
      _withdrawalList = list;
    });
  }

  /// Delete list withdrawal by index
  Future<void> _deleteWithdrawalAtIndex(int index) async {
    List<WithdrawalsRequestModel> list = await getListWithdrawal();
    list.removeAt(index);
    await saveListWithdrawal(list);
    setState(() {
      _withdrawalList = list;
    });
    Logger().i('Data berhasil dihapus');
  }

  /// Buat list local withdrawal
  _buildListLocalWithdrawal(
      BuildContext context, WithdrawalsRequestModel withdrawal, int index) {
    return Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jumlah Penarikan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatCurrency(double.parse(withdrawal.price!)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const Gap(8),
            _buildRowText(
              context,
              'ID Nasabah',
              '${withdrawal.idUser}',
            ),
            const Gap(8),
            _buildRowText(
              context,
              'Status',
              '${withdrawal.status}',
            ),
            const Gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Hapus Penarikan'),
                            content: const Text(
                                'Apakah anda yakin akan menghapus penarikan?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  _deleteWithdrawalAtIndex(index);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ya, Hapus'),
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
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Gap(8.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Penarikan'),
                            content: const Text(
                                'Apakah anda yakin akan melakukan upload penarikan?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        false, // Mencegah dialog tertutup saat menunggu
                                    builder: (BuildContext context) {
                                      return const Dialog(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(width: 20),
                                              Text("Memeriksa koneksi..."),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  bool isConnected =
                                      await InternetConnectionChecker.instance
                                          .hasConnection;

                                  _buildPop();

                                  if (isConnected) {
                                    selectedIndexWithdrawal = index;
                                    _buildUploadFromLocalWithdrawal(withdrawal);
                                    Logger().i('Terhubung ke internet');
                                  } else {
                                    _buildNotConnected();
                                    _buildPop();
                                    Logger().i('Tidak terhubung ke internet');
                                  }
                                },
                                child: const Text('Ya, Tarik'),
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
                    },
                    child: const Text(
                      'Tarik',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Build draft list
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
        const Gap(16.0),
        _selectedTabBarIndex == 0
            ? _depositList.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildListLocalDeposit(
                        context,
                        _depositList[index],
                        index,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Gap(12.0);
                    },
                    itemCount: _depositList.length,
                  )
                : _buildEmptyDraft()
            : _withdrawalList.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildListLocalWithdrawal(
                        context,
                        _withdrawalList[index],
                        index,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Gap(12.0);
                    },
                    itemCount: _withdrawalList.length,
                  )
                : _buildEmptyDraft(),
      ],
    );
  }

  /// Build draft is empty
  _buildEmptyDraft() {
    return SizedBox(
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
    );
  }

  /// Build row text
  _buildRowText(
    BuildContext context,
    String title,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build pop
  _buildPop() {
    Navigator.of(context).pop();
  }

  /// Build not connected
  _buildNotConnected() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada koneksi internet!')));
  }
}
