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
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simbiotik_admin/core/blocs/blocs.dart';
import 'package:simbiotik_admin/core/routers/routers.dart';
import 'package:simbiotik_admin/data/data.dart';
import 'package:simbiotik_admin/gen/assets.gen.dart';
import 'package:simbiotik_admin/models/models.dart';
import 'package:simbiotik_admin/utils/utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreenContent();
  }
}

class LoginScreenContent extends StatefulWidget {
  const LoginScreenContent({super.key});

  @override
  State<LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<LoginScreenContent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool? _rememberMe = false;
  bool _obsecurePassword = true;

  String? getToken;

  _savedToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    getToken = token;
    if (getToken != null && getToken?.isNotEmpty == true) {
      _buildAutoLogin();
    }
    Logger().d(token);
  }

  _buildAutoLogin() {
    GoRouter.of(context).pushReplacement(
      AppRouterConstants.homeScreen,
      extra: getToken,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(AuthRepository()),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Assets.images.simbiotik2.image(
                  width: 40,
                  height: 40,
                ),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Row(
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
                const Text(
                  'SIMBIOTIK Pro adalah aplikasi mobile yang dirancang khusus untuk admin, memudahkan Anda dalam mengelola setoran, menambahkan nasabah baru, serta menambah jenis sampah.',
                  style: TextStyle(
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const Gap(20),
                const Text(
                  'Masuk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan Email',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                    ),
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
                  height: 40.0,
                  padding: const EdgeInsets.fromLTRB(
                    8,
                    4,
                    8,
                    4,
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        hintText: 'Masukkan Password',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              _obsecurePassword = !_obsecurePassword;
                            });
                          },
                          child: Icon(
                            _obsecurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                        )),
                    obscureText: _obsecurePassword,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Ingat Saya',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    Checkbox(
                      activeColor: Colors.lightBlue,
                      value: _rememberMe,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _rememberMe = newValue ?? false;
                        });
                      },
                    ),
                  ],
                ),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    Logger().d(state.error);
                    if (state.status.isLoaded) {
                      if (state.data?.status == StatusUser.admin.value) {
                        if (_rememberMe == true) {
                          if (state.token != null) {
                            _savedToken(state.token!);
                            GoRouter.of(context).pushReplacement(
                              AppRouterConstants.homeScreen,
                              extra: state.token,
                            );
                          }
                        } else {
                          GoRouter.of(context).pushReplacement(
                            AppRouterConstants.homeScreen,
                            extra: state.token,
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Silahkan masuk menggunakan akun admin!'),
                          ),
                        );
                      }
                    } else if (state.status.isError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Gagal masuk, silahkan periksa kembali email atau password!'),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.hijauSimbiotik,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            )),
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                AuthEvent.login(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
