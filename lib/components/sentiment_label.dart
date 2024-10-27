import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

Widget sentimentLabelTextWidget(String text) {
  Color borderColor;

  if (text == 'positive') {
    borderColor = Colors.green;
  } else if (text == 'negative') {
    borderColor = Colors.red;
  } else if (text == 'neutral') {
    borderColor = darkGreyColor;
  } else {
    borderColor = Colors.transparent;
  }

  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: borderColor, width: .75), // Outline border
      borderRadius: BorderRadius.circular(
          primaryBorderRadius), // Optional: for rounded corners
    ),
    padding: const EdgeInsets.symmetric(
        horizontal: 8.0, vertical: 4.0), // Padding around the text
    child: Text(
      text,
      style: TextStyle(
        fontSize: smallText,
        color: borderColor != Colors.transparent
            ? borderColor
            : Colors.black, // Use the same color for the text
      ),
    ),
  );
}
