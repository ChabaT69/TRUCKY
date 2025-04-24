import 'package:flutter/material.dart';

class MytextField extends StatelessWidget {
  final bool ispassword;
  final TextInputType textInputTypeee;
  final String hindtexttt;

  MytextField({
    Key? key,
    required this.textInputTypeee,
    required this.ispassword,
    required this.hindtexttt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: textInputTypeee,
      obscureText: ispassword,
      decoration: InputDecoration(
        hintText: hindtexttt,
        // to delete borders,
        enabledBorder: OutlineInputBorder(
          borderSide: Divider.createBorderSide(context),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        //fillColor: colors.red,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
    );
  }
}
