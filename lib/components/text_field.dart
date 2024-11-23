import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/globals.dart';

Widget buildTextField(
  String label,
  String controllerKey,
  Map<String, TextEditingController> controllers, {
  bool isEmail = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(color: Colors.black, fontSize: regularText),
          children: const [
            TextSpan(text: "*", style: TextStyle(color: primaryColor)),
          ],
        ),
      ),
      const SizedBox(height: secondarySizedBox),
      TextFormField(
        controller: controllers[controllerKey],
        obscureText: false, // No password visibility handling
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        textCapitalization:
            isEmail ? TextCapitalization.none : TextCapitalization.sentences,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(secondaryBorderRadius),
          ),
          hintText: isEmail ? "Enter your email" : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "Enter a valid email address";
          }
          return null;
        },
        inputFormatters: isEmail
            ? [] // No input formatters for email
            : [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final newText = capitalizeFirstLetter(
                      newValue.text); // Capitalize first letter
                  return newValue.copyWith(text: newText);
                }),
              ],
      ),
    ],
  );
}
