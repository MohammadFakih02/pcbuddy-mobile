import 'package:flutter/material.dart';
import '../widgets/text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme data for cleaner code below
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Background color is handled automatically by the Theme now
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // 1. Logo
                Icon(
                  Icons.lock,
                  size: 100,
                  color: colorScheme.primary, // Uses your App Blue
                ),

                const SizedBox(height: 50),

                // 2. Welcome Text
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color, // Uses Grey
                  ),
                ),

                const SizedBox(height: 25),

                // 3. Email
                const MyTextField(
                  hintText: 'Email',
                  icon: Icons.email,
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // 4. Password
                const MyTextField(
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // 5. Forgot Password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        // Uses the Grey text style from theme
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 6. Sign In Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic
                      },
                      // We REMOVED the style block here. 
                      // It now grabs the Blue Pill style from AppTheme automatically.
                      child: const Text("Sign In"),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // 7. Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Register now',
                      style: TextStyle(
                        color: colorScheme.secondary, // Uses Light Blue/Cyan
                        fontWeight: FontWeight.bold,
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