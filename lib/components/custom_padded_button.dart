import 'package:flutter/material.dart';
import 'globals.dart';

Widget customPaddedTextButton({
  required dynamic text, // Accepts both String and Widget
  required dynamic
      onPressed, // Accepts both VoidCallback and Future<void> Function()
}) {
  return TextButton(
    onPressed: () async {
      if (onPressed is Future<void> Function()) {
        await onPressed(); // Handle Future<void> callbacks
      } else if (onPressed is VoidCallback) {
        onPressed(); // Handle synchronous callbacks
      }
    },
    style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(secondaryBorderRadius),
        ),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(
        primaryColor,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: text is String
          ? Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: regularText,
                fontWeight: FontWeight.normal,
              ),
            )
          : text, // Render the widget directly if `text` is a Widget
    ),
  );
}

Widget customPaddedTextButtonWIthSecondaryColor({
  required String text,
  required VoidCallback onPressed,
}) {
  return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(secondaryBorderRadius),
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
            secondaryColor,
          )),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          text,
          style: const TextStyle(
              color: lighterGreyColor,
              fontSize: regularText,
              fontWeight: FontWeight.normal),
        ),
      ));
}

Widget customSmallPaddedTextButton({
  required String text,
  required VoidCallback onPressed,
  bool isEnabled = true, // Add this optional parameter
}) {
  return TextButton(
    onPressed: isEnabled ? onPressed : null, // Disable if isEnabled is false
    style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(secondaryBorderRadius),
        ),
      ),
      backgroundColor: WidgetStateProperty.all<Color>(
        isEnabled ? primaryColor : disabledButtonTextColor,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, // Optionally change text color when disabled
          fontSize: smallText,
          fontWeight: FontWeight.normal,
        ),
      ),
    ),
  );
}

Widget customPaddedOutlinedTextButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return TextButton(
    onPressed: onPressed,
    style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(secondaryBorderRadius),
          side: const BorderSide(color: primaryColor),
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.all(10.0),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: regularText,
        color: primaryColor,
      ),
    ),
  );
}
