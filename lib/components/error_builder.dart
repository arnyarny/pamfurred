import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final TextAlign textAlign;
  final TextStyle? style;

  const ErrorMessage({
    super.key,
    this.message = "⚠️ An unexpected error occurred.\nPlease try again later.",
    this.textAlign = TextAlign.center,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: textAlign,
      style: style ??
          const TextStyle(
            fontSize: regularText,
            color: darkGreyColor,
            fontWeight: regularWeight,
          ),
    );
  }
}
