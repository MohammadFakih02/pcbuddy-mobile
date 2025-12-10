import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    // We access the current theme to use the colors defined in AppTheme
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        style: theme.textTheme.bodyLarge, // Ensures text is White when typing
        decoration: InputDecoration(
          // 1. Force fully rounded corners (Pill shape)
          // We override the default 8px radius from the theme here
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none, // Clean look, just the fill color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            // Use the Blue color from your theme when clicked
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          
          // 2. Colors come from the Theme now (Navy/Grey)
          filled: true,
          fillColor: theme.colorScheme.surface, 
          
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium, // Uses the Grey text color
          
          prefixIcon: icon != null 
              ? Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)) 
              : null,
        ),
      ),
    );
  }
}