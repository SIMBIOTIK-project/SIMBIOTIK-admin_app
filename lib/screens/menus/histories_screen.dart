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
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:logger/web.dart';
import 'package:simbiotik_admin/core/blocs/deposit/deposit.dart';
import 'package:simbiotik_admin/core/blocs/deposit/deposit_bloc.dart';
import 'package:simbiotik_admin/core/blocs/withdrawal/withdrawal_bloc.dart';
import 'package:simbiotik_admin/models/models.dart';
import 'package:simbiotik_admin/utils/utils.dart';

class HistoriesScreen extends StatefulWidget {
  final String token;
  const HistoriesScreen({
    required this.token,
    super.key,
  });

  @override
  State<HistoriesScreen> createState() => _HistoriesScreenState();
}

class _HistoriesScreenState extends State<HistoriesScreen>
    with SingleTickerProviderStateMixin {
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

  List<DepositModel> allDeposit = [];
  List<WithdrawalModel> allWithdrawal = [];

  @override
  void initState() {
    super.initState();
    _handleRefreshDataDeposit(context);
    _handleRefreshDataWithdrawal(context);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Gap(8.0),
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
            const Gap(16.0),
            _selectedTabBarIndex == 0
                ? _buildDepositList(context)
                : _buildWithdrawalList(context),
          ],
        ),
      ),
    );
  }

  _buildDepositList(BuildContext context) {
    return BlocConsumer<DepositBloc, DepositState>(
      listener: (context, state) {
        Logger().d(state.error);
        if (state.status.isError) {
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Data tidak ditemukan!'),
                const Gap(8.0),
                InkWell(
                  onTap: () {
                    _handleRefreshDataDeposit(
                      context,
                    );
                  },
                  child: const Text(
                    'Ulangi',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status.isLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.status.isLoaded && state.allData != null) {
          allDeposit = state.allData!;
          return Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return _buildListHistoryDeposit(context, allDeposit[index]);
              },
              separatorBuilder: (context, index) {
                return const Gap(16.0);
              },
              itemCount: allDeposit.length,
            ),
          );
        }
        return Container();
      },
    );
  }

  _buildWithdrawalList(BuildContext context) {
    return BlocConsumer<WithdrawalBloc, WithdrawalState>(
      listener: (context, state) {
        Logger().d(state.error);
        if (state.status.isLoading) {
          const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state.status.isError) {
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Data tidak ditemukan!'),
                const Gap(8.0),
                InkWell(
                  onTap: () {
                    _handleRefreshDataWithdrawal(
                      context,
                    );
                  },
                  child: const Text(
                    'Ulangi',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.allData != null) {
          allWithdrawal = state.allData!;
          return Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return _buildListHistoryWithdrawal(
                    context, allWithdrawal[index]);
              },
              separatorBuilder: (context, index) {
                return const Gap(16.0);
              },
              itemCount: allWithdrawal.length,
            ),
          );
        }
        return Container();
      },
    );
  }

  _buildListHistoryDeposit(BuildContext context, DepositModel deposit) {
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
                  formatCurrency(double.parse(deposit.price!.toString())),
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
              'Berat',
              '${deposit.weight} kg',
            ),
            const Gap(8),
            _buildRowText(
              context,
              'Jenis Sampah',
              '${deposit.wasteType?.type}',
            ),
            const Gap(8),
            _buildRowText(
              context,
              'Tanggal Setoran',
              formattedDate(deposit.createdAt.toString()),
            ),
          ],
        ),
      ),
    );
  }

  _buildListHistoryWithdrawal(
      BuildContext context, WithdrawalModel withdarawal) {
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
                  formatCurrency(double.parse(withdarawal.price!.toString())),
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
              'Status',
              '${withdarawal.status}',
            ),
            const Gap(8),
            _buildRowText(
              context,
              'Tanggal Setoran',
              formattedDate(withdarawal.createdAt.toString()),
            ),
          ],
        ),
      ),
    );
  }

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

  _handleRefreshDataDeposit(BuildContext context) {
    context.read<DepositBloc>().add(
          DepositEvent.fetchAll(token: widget.token),
        );
  }

  _handleRefreshDataWithdrawal(BuildContext context) {
    context.read<WithdrawalBloc>().add(
          WithdrawalEvent.fetchAll(token: widget.token),
        );
  }
}
