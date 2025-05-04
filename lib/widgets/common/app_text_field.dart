import 'package:flutter/material.dart';

class MytextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType textInputTypeee;
  final bool ispassword;
  final String hindtexttt;
  final Color? BackgroundColor;
  final String? Function(String?)? validator;

  const MytextField({
    Key? key,
    required this.controller,
    required this.textInputTypeee,
    required this.ispassword,
    required this.hindtexttt,
    this.BackgroundColor,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputTypeee,
      obscureText: ispassword,
      decoration: InputDecoration(
        hintText: hindtexttt,
        filled: true,
        fillColor: BackgroundColor ?? Colors.transparent,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator,
    );
  }
}
