import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final String controllerKey;
  final Map<String, TextEditingController> controllers;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controllerKey,
    required this.controllers,
  });

  @override
  PasswordTextFieldState createState() => PasswordTextFieldState();
}

class PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "${widget.label} ",
            style: const TextStyle(color: Colors.black, fontSize: regularText),
            children: const [
              TextSpan(text: "*", style: TextStyle(color: primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: secondarySizedBox),
        TextFormField(
          controller: widget.controllers[widget.controllerKey],
          obscureText: _obscurePassword,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(secondaryBorderRadius),
            ),
            hintText: "Enter your password",
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "${widget.label} is required";
            }
            return null;
          },
        ),
      ],
    );
  }
}
