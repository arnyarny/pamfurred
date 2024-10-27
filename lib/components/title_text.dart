import 'package:flutter/material.dart';
import 'globals.dart';

Text customTitleText(BuildContext context, String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: titleFont, fontWeight: mediumWeight),
    overflow: TextOverflow.ellipsis,
  );
}

Text customRegularWeightTitleText(BuildContext context, String text) {
  return Text(
    text,
    style: const TextStyle(
        fontSize: regularText, fontWeight: regularWeight, color: Colors.black),
  );
}

Text customBoldWeightRegularText(BuildContext context, String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: regularText, fontWeight: boldWeight),
  );
}

// custom title text with primary color and medium font weight
Text customTitleTextWithPrimaryColor(BuildContext context, String text) {
  return Text(text,
      style: const TextStyle(
          fontSize: titleFont, fontWeight: mediumWeight, color: primaryColor));
}

Text customSearchResultsTitleText(BuildContext context, String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: titleFont, fontWeight: mediumWeight),
    overflow: TextOverflow.ellipsis,
    maxLines: 1, // Limit to 1 line
  );
}
