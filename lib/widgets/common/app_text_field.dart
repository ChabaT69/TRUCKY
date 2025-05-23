import 'package:flutter/material.dart';
import '../../config/colors.dart';

class MytextField extends StatefulWidget {
  final TextInputType textInputTypeee;
  final bool ispassword;
  final String hindtexttt;
  final TextEditingController controller;
  final Color BackgroundColor;
  final String? Function(String?)? validator;

  const MytextField({
    Key? key,
    required this.textInputTypeee,
    required this.ispassword,
    required this.hindtexttt,
    required this.controller,
    this.BackgroundColor = Colors.white,
    this.validator,
  }) : super(key: key);

  @override
  _MytextFieldState createState() => _MytextFieldState();
}

class _MytextFieldState extends State<MytextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputTypeee,
      obscureText: widget.ispassword && _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.BackgroundColor,
        hintText: widget.hindtexttt,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: BTN300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: BTN500, width: 2),
        ),
        suffixIcon:
            widget.ispassword
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
      ),
      style: TextStyle(fontSize: 16),
    );
  }
}
