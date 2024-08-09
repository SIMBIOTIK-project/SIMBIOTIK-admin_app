import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:simbiotik_admin/app.dart';
import 'package:simbiotik_admin/core/configs/app_config.dart';
import 'package:simbiotik_admin/core/configs/flavor_type.dart';

Future main() async {
  final devAppConfig = AppConfig(
    appName: 'SIMBIOTIK Pro',
    flavorType: FlavorType.prod,
  );
  await dotenv.load(fileName: ".env");
  Widget app = await initializeApp(devAppConfig);
  runApp(app);
}
