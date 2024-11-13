import 'package:flutter/material.dart';
import 'globals.dart';

Widget customPaddedTextButton({
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
            primaryColor,
          )),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: regularText,
              fontWeight: FontWeight.normal),
        ),
      ));
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
            primaryColor,
          )),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: smallText,
              fontWeight: FontWeight.normal),
        ),
      ));
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
