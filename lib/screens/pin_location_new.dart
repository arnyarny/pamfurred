import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:pamfurred/components/globals.dart';

class PinLocationNew extends StatefulWidget {
  const PinLocationNew({super.key});

  @override
  State<PinLocationNew> createState() => _PinLocationNewState();
}

class _PinLocationNewState extends State<PinLocationNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OpenStreetMapSearchAndPick(
      buttonTextStyle: const TextStyle(fontSize: regularText),
      locationPinText: '',
      locationPinIconColor: primaryColor,
      buttonColor: primaryColor,
      buttonText: 'Set Current Location',
      onPicked: (pickedData) {
        // Pass only the addressName back to the previous screen
        Navigator.pop(context, pickedData.addressName);
      },
    ));
  }
}
