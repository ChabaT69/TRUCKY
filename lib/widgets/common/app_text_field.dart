import 'package:flutter/material.dart';
import 'package:trucky/config/colors.dart';

class MytextField extends StatelessWidget {
  final TextInputType textInputTypeee;
  final bool ispassword;
  final String hindtexttt;
  final TextEditingController? controller;
  final Color? BackgroundColor;

  const MytextField({
    Key? key,
    required this.textInputTypeee,
    required this.ispassword,
    required this.hindtexttt,
    this.controller,
    this.BackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BackgroundColor ?? Colors.transparent,
      child: TextField(
        controller: controller,
        keyboardType: textInputTypeee,
        obscureText: ispassword,
        decoration: InputDecoration(
          hintText: hindtexttt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: BTN500, width: 1.0),
          ),
        ),
      ),
    );
  }
}
