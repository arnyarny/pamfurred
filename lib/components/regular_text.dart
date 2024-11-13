import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

Widget regularTextWidget(String text) {
  return Flexible(
    child: Text(
      maxLines: 2,
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: regularText,
        fontWeight: regularWeight,
      ),
    ),
  );
}

Widget regularBoldTextWidget(String text) {
  return Flexible(
    child: Text(
      maxLines: 2,
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: regularText,
        fontWeight: mediumWeight,
      ),
    ),
  );
}


Widget regularGreyTextWidget(String text) {
  return Flexible(
    child: Text(
      maxLines: 2,
      text,
      style: const TextStyle(
        color: darkGreyColor,
        fontSize: regularText,
        fontWeight: regularWeight,
      ),
    ),
  );
}

Widget regularPrimaryColoredTextWidget(String text) {
  return Flexible(
    child: Text(
      maxLines: 2,
      text,
      style: const TextStyle(
        color: primaryColor,
        fontSize: regularText,
        fontWeight: regularWeight,
      ),
    ),
  );
}

Widget regularPrimaryColoredBoldTextWidget(String text) {
  return Flexible(
    child: Text(
      maxLines: 2,
      text,
      style: const TextStyle(
        color: primaryColor,
        fontSize: regularText,
        fontWeight: boldWeight,
      ),
    ),
  );
}
