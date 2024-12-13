import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/title_text.dart';

getAppointmentTitle(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      customTitleText(context, title),
      const SizedBox(width: primarySizedBox),
    ],
  );
}

getAppointmentDetail(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      customRegularWeightTitleText(context, title),
      const SizedBox(width: primarySizedBox),
    ],
  );
}

Widget buildCartItem({required dynamic name, required String price}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      getPrice(price),
    ],
  );
}

getPrice(String s) {
  return Text(
    '₱$s',
    style: const TextStyle(fontWeight: FontWeight.bold),
  );
}

getAppointmentTotalTitle(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      customTitleTextWithPrimaryColor(context, title),
      const SizedBox(width: primarySizedBox),
    ],
  );
}
