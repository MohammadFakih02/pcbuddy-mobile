import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SyncScreen extends StatelessWidget {
  final double progress;

  const SyncScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 250,
                child: Lottie.asset(
                  'assets/animations/robot.json',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "Updating Parts Database...",
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "Grabbing the latest CPUs, GPUs, and prices just for you.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Progress Bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                color: theme.colorScheme.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),

              const SizedBox(height: 16),

              Text(
                "$percentage%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
