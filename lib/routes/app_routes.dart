import 'package:flutter/material.dart';
import 'package:pcbuddy/widgets/main_layout.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) => const MainLayout(),
    };
  }
}