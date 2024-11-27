import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

Widget emptyListWidget(IconData icon, String title, String subtitle) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 48.0,
        color: secondaryGreyColor,
      ),
      const SizedBox(height: secondarySizedBox),
      Text(
        title,
        style: const TextStyle(
          fontSize: titleFont,
          fontWeight: FontWeight.bold,
          color: secondaryGreyColor,
        ),
      ),
      Text(
        subtitle,
        style: const TextStyle(
          fontSize: regularText,
          color: secondaryGreyColor,
        ),
      ),
    ],
  );
}
