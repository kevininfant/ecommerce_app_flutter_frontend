import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Enter your ${widget.hintText}';
        return null;
      },
    );
  }
}
