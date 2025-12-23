import 'package:flutter/material.dart';
import 'package:pcbuddy/routes/app_routes.dart';
import '../widgets/my_button.dart';
import '../widgets/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void _signIn() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.lock,
                  size: 100,
                  color: colorScheme.primary,
                ),

                const SizedBox(height: 50),

                Text(
                  'Welcome back, you\'ve been missed!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),

                const SizedBox(height: 25),

                const MyTextField(
                  hintText: 'Email',
                  icon: Icons.email,
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                const MyTextField(
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                MyButton(
                  text: "Sign In",
                  isLoading: _isLoading, 
                  onTap: _signIn,
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text(
                        'Register now',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}