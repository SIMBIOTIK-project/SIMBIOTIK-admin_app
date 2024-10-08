import 'package:flutter/material.dart';
import 'package:simbiotik_admin/core/configs/app_config.dart';

import 'core/routers/app_router_configs.dart';

Future<Widget> initializeApp(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  return MyApp(
    config: config,
  );
}

class MyApp extends StatelessWidget {
  final AppConfig config;
  final AppRouterConfig _appRouter = AppRouterConfig();
  MyApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: config.appName,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            surfaceTintColor: Colors.white,
          )),
      routerDelegate: _appRouter.router.routerDelegate,
      routeInformationParser: _appRouter.router.routeInformationParser,
      routeInformationProvider: _appRouter.router.routeInformationProvider,
    );
  }
}
