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
import 'package:go_router/go_router.dart';
import 'package:simbiotik_admin/core/routers/routers.dart';
import 'package:simbiotik_admin/screens/register/register_screen.dart';
import 'package:simbiotik_admin/screens/screens.dart';

class AppRouterConfig {
  final GoRouter _router;

  AppRouterConfig()
      : _router = GoRouter(
          routes: [
            GoRoute(
                name: '/',
                path: '/',
                builder: (context, state) {
                  return const LoginScreen();
                }),
            GoRoute(
              name: AppRouterConstants.homeScreen,
              path: AppRouterConstants.homeScreen,
              builder: (context, state) {
                String token = state.extra as String;
                return Homescreen(
                  token: token,
                );
              },
            ),
            GoRoute(
                name: AppRouterConstants.registerScreen,
                path: AppRouterConstants.registerScreen,
                builder: (context, state) {
                  String token = state.extra as String;
                  return RegisterScreen(
                    token: token,
                  );
                })
          ],
          errorBuilder: (context, state) {
            return const Scaffold(
              body: Center(
                child: Text('Halaman tidak ditemukan!'),
              ),
            );
          },
        );
  GoRouter get router => _router;
}
