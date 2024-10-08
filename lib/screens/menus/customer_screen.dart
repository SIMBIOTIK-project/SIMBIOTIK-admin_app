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
import 'package:simbiotik_admin/core/blocs/user/user_bloc.dart';
import 'package:simbiotik_admin/core/routers/routers.dart';
import 'package:simbiotik_admin/models/models.dart';

class CustomerScreen extends StatefulWidget {
  final String token;
  const CustomerScreen({
    required this.token,
    super.key,
  });

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<UserModel> allUser = [];
  final TextEditingController _keyword = TextEditingController();

  @override
  initState() {
    super.initState();
    context.read<UserBloc>().add(
          UserEvent.fetchAll(
            token: widget.token,
            status: 'nasabah',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Nasabah',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    bool? result = await GoRouter.of(context).pushNamed(
                      AppRouterConstants.registerScreen,
                      extra: widget.token,
                    );

                    if (result == true) {
                      _handleRefreshData('');
                    }
                  },
                  child: const Row(
                    children: [
                      Text('Tambah'),
                      Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Gap(8.0),
            Row(
              children: [
                Expanded(
                  child: Container(
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
                      controller: _keyword,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Cari Nasabah',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            _handleRefreshData('');
                          });
                        }
                      },
                    ),
                  ),
                ),
                const Gap(4.0),
                InkWell(
                  onTap: () {
                    _handleRefreshData(_keyword.text);
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      border: Border.all(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Center(
                        child: Text(
                          'Cari',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: BlocConsumer<UserBloc, UserState>(
                listener: (context, state) {
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
                              _handleRefreshData(
                                '',
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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state.status.isLoaded && state.allData != null) {
                    allUser = state.allData!;
                    return SingleChildScrollView(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _buildListCustomer(context, allUser[index]);
                        },
                        separatorBuilder: (context, index) {
                          return const Gap(16.0);
                        },
                        itemCount: allUser.length,
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildListCustomer(BuildContext context, UserModel user) {
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
            Text(
              user.idUser ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Gap(8),
            _buildRowText(
              context,
              'Nama',
              user.name ?? '-',
            ),
            const Gap(8.0),
            _buildRowText(
              context,
              'Nomor Telepon',
              user.phoneNumber ?? '-',
            ),
            const Gap(8.0),
            _buildRowText(
              context,
              'Alamat',
              user.address ?? '-',
            )
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
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  _handleRefreshData(String? keyword) {
    context.read<UserBloc>().add(UserEvent.fetchAll(
          token: widget.token,
          status: 'nasabah',
          name: keyword,
        ));
  }
}
