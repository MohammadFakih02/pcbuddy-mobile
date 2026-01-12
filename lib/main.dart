import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import 'package:pcbuddy/routes/app_routes.dart';
import 'package:pcbuddy/theme/app_theme.dart';
import 'package:pcbuddy/pages/main_layout.dart';
import 'package:pcbuddy/pages/login_page.dart';
import 'package:pcbuddy/widgets/sync_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PCBuddy',
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(), 
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isSyncing) {
          return SyncScreen(progress: auth.syncProgress);
        }
        if (auth.isAuthenticated) {
          return const MainLayout();
        }

        return const LoginPage();
      },
    );
  }
}