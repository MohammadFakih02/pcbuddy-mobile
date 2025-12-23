import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  // 1. Add these two variables
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const MyTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.obscureText = false,
    this.controller, // Add to constructor
    this.validator,  // Add to constructor
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField( // <--- CHANGED from TextField to TextFormField
        controller: widget.controller, // Pass the controller
        validator: widget.validator,   // Pass the validator logic
        obscureText: _isObscured,
        style: theme.textTheme.bodyLarge,
        
        // This makes the error text red and readable
        autovalidateMode: AutovalidateMode.onUserInteraction, 
        
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder( // Style when there is an error
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium,
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}