import 'package:flutter/material.dart';

import '../features/detection/presentation/pages/camera_page.dart';
import '../features/detection/presentation/pages/home_page.dart';
import '../features/detection/presentation/pages/settings_page.dart';

class Routes {
  Routes._();

  static const String home = '/';
  static const String camera = '/camera';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case camera:
        page = const CameraPage();
      case Routes.settings:
        page = const SettingsPage();
      case home:
      default:
        page = const HomePage();
    }
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
