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
import 'package:gap/gap.dart';
import 'package:simbiotik_admin/screens/menus/manus.dart';
import 'package:simbiotik_admin/utils/utils.dart';

class Homescreen extends StatelessWidget {
  final String? token;
  const Homescreen({
    this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeScreenContent(
      token: token,
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  final String? token;
  const HomeScreenContent({
    this.token,
    super.key,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const DashboardScreen(),
    const CustomerScreen(),
    const HistoriesScreen(),
  ];

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
              'Access',
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 24,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(
              right: 16.0,
            ),
            child: Icon(
              Icons.menu,
            ),
          )
        ],
      ),
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
}
