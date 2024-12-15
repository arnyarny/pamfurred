import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

Widget customFloatingActionButton(
  BuildContext context, {
  required String buttonText,
  required VoidCallback onPressed,
  Key? key,
  EdgeInsets? margin, // Optional margin parameter
  bool isEnabled = true, // New isEnabled parameter with default value
}) {
  const double elevatedButtonHeight = 50;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(secondaryBorderRadius),
      border: Border.all(
          width: 0.5,
          color: isEnabled ? primaryColor : Colors.grey), // Adjust border color
      color: isEnabled
          ? primaryColor
          : lighterGreyColor, // Adjust background color
      boxShadow: isEnabled
          ? [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.2), // Shadow color with transparency
                spreadRadius: 2,
                blurRadius: 8, // How blurry the shadow will appear
                offset: const Offset(2, 4), // Shadow position (x, y)
              ),
            ]
          : null, // No shadow for disabled state
    ),
    height: elevatedButtonHeight,
    margin: margin ??
        const EdgeInsets.symmetric(
            horizontal: 30, vertical: 10), // Use the optional margin
    child: TextButton(
      onPressed:
          isEnabled ? onPressed : null, // Disable button if isEnabled is false
      child: Center(
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: regularText,
            fontWeight: regularWeight,
            // Add opacity for disabled text
            color: isEnabled ? Colors.white : disabledButtonTextColor,
          ),
        ),
      ),
    ),
  );
}
