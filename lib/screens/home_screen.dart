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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simbiotik_admin/core/blocs/deposit/deposit.dart';
import 'package:simbiotik_admin/core/blocs/user/user_bloc.dart';
import 'package:simbiotik_admin/core/blocs/waste_type/waste_type_bloc.dart';
import 'package:simbiotik_admin/core/blocs/withdrawal/withdrawal.dart';
import 'package:simbiotik_admin/data/data.dart';
import 'package:simbiotik_admin/screens/menus/manus.dart';
import 'package:simbiotik_admin/utils/utils.dart';

class Homescreen extends StatelessWidget {
  final String token;
  const Homescreen({
    required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WasteTypeBloc(WasteTypeRepository())
            ..add(WasteTypeEvent.fetchAll(token: token)),
        ),
        BlocProvider(
          create: (context) => DepositBloc(DepositRepository()),
        ),
        BlocProvider(
          create: (context) => WithdrawalBloc(WithdrawalRepository()),
        ),
        BlocProvider(
          create: (context) => UserBloc(UserRepository()),
        ),
      ],
      child: HomeScreenContent(
        token: token,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  final String token;
  const HomeScreenContent({
    required this.token,
    super.key,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  int _currentIndex = 0;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      DashboardScreen(token: widget.token),
      CustomerScreen(token: widget.token),
      HistoriesScreen(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Row(
            children: [
              Text(
                'SIMBIO',
                style: TextStyle(
                  color: AppColors.hijauSimbiotik,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              Text(
                'TIK',
                style: TextStyle(
                  color: AppColors.biruSimbiotik,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              Gap(8.0),
              Text(
                'Pro',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.menu),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {
                    _showAlertDialog(context);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.logout),
                      Gap(4.0),
                      Text('Keluar'),
                    ],
                  ),
                ),
              ],
            )
          ]),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onBarTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Nasabah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transaksi',
          ),
        ],
      ),
    );
  }

  void onBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      GoRouter.of(context).pushReplacement('/');
    }
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah anda yakin akan keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _logout(context);
              },
              child: const Text('Ya, Keluar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
          ],
        );
      },
    );
  }
}
