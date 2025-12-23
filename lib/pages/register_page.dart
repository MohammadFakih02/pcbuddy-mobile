import 'package:flutter/material.dart';
import '../widgets/my_button.dart';
import '../widgets/text_field.dart';

// 1. Change to StatefulWidget (Required for Controllers)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 2. Controllers to retrieve text
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // 3. Global Key (The "Remote Control" for the form)
  final _formKey = GlobalKey<FormState>();

  void _register() {
    // 4. Trigger Validation
    if (_formKey.currentState!.validate()) {
      // If valid, proceed!
    }
  }

  @override
  void dispose() {
    // Clean up controllers when page closes to save memory
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form( // <--- Wrap Column in a FORM
              key: _formKey, // Connect the key
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 100, color: colorScheme.primary),
                  const SizedBox(height: 30),
                  Text(
                    'Create an account', // Changed text to fit context
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 25),

                  MyTextField(
                    hintText: 'Username',
                    icon: Icons.person,
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  MyTextField(
                    hintText: 'Email',
                    icon: Icons.email,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
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
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
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
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  MyButton(
                    text: "Register",
                    onTap: _register,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
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