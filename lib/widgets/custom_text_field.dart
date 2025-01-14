import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final InputDecoration? decoration;
  final TextStyle? style;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.decoration,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
      style: style,
    );
  }
}
