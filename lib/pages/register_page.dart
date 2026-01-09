import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pcbuddy/providers/auth_provider.dart';
import '../widgets/my_button.dart';
import '../widgets/text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception: ", "")),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 100, color: colorScheme.primary),
                  const SizedBox(height: 30),
                  Text(
                    'Create an account',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 25),

                  MyTextField(
                    hintText: 'Username',
                    icon: Icons.person,
                    controller: _usernameController,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please enter a username' : null,
                  ),

                  const SizedBox(height: 25),

                  MyTextField(
                    hintText: 'Email',
                    icon: Icons.email,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter an email';
                      if (!value.contains('@') || !value.contains('.')) return 'Invalid email';
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  MyTextField(
                    hintText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a password';
                      if (value.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  MyTextField(
                    hintText: 'Confirm Password',
                    icon: Icons.lock,
                    obscureText: true,
                    controller: _confirmController,
                    validator: (value) {
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  MyButton(
                    text: "Register",
                    isLoading: isLoading,
                    onTap: _register,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Login now',
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}