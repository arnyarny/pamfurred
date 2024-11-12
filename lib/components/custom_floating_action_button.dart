import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

Widget customFloatingActionButton(BuildContext context,
    {required String buttonText, required VoidCallback onPressed, required ValueKey<bool> key}) {
  const double elevatedButtonHeight = 50;
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(secondaryBorderRadius),
      border: Border.all(width: 0.5, color: primaryColor),
      color: primaryColor,
      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(0.2), // Shadow color with transparency
          spreadRadius: 2,
          blurRadius: 8, // How blurry the shadow will appear
          offset: const Offset(2, 4), // Shadow position (x, y)
        ),
      ],
    ),
    height: elevatedButtonHeight,
    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: TextButton(
      onPressed: onPressed,
      child: Center(
        child: Text(
          buttonText,
          style: const TextStyle(
              color: Colors.white,
              fontSize: regularText,
              fontWeight: regularWeight),
        ),
      ),
    ),
  );
}
