import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
    };
  }
}