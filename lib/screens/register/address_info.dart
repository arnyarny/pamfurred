import 'package:flutter/material.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/screens/register/credentials.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';

class AddressDetailsScreen extends StatefulWidget {
  final Map<String, TextEditingController> controllers;

  const AddressDetailsScreen({super.key, required this.controllers});

  @override
  AddressDetailsScreenState createState() => AddressDetailsScreenState();
}

class AddressDetailsScreenState extends State<AddressDetailsScreen> {
  bool _showError = false;

  bool _validateFields() {
    final floorUnitRoom =
        widget.controllers['floorUnitRoom']?.text.trim() ?? '';
    final street = widget.controllers['street']?.text.trim() ?? '';
    final barangay = widget.controllers['barangay']?.text.trim() ?? '';
    final city = widget.controllers['city']?.text.trim() ?? '';
    return floorUnitRoom.isNotEmpty &&
        street.isNotEmpty &&
        barangay.isNotEmpty &&
        city.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader("Address Details"),
            const SizedBox(height: secondaryBorderRadius),
            formDescription(context,
                "Please enter your address so that we can show you nearby service providers and services based on your location."),
            const SizedBox(height: tertiarySizedBox),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                      "Floor/Unit/Room", "floorUnitRoom", widget.controllers),
                ),
                const SizedBox(width: primarySizedBox),
                Expanded(
                  child: buildTextField(
                      "Street name", "street", widget.controllers),
                ),
              ],
            ),
            const SizedBox(height: secondarySizedBox),
            buildTextField("Barangay", "barangay", widget.controllers),
            const SizedBox(width: primarySizedBox),
            buildTextField("City", "city", widget.controllers),
            if (_showError) ...[
              const SizedBox(height: 8.0),
              const Text(
                "Please fill out all required fields.",
                style: TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: tertiarySizedBox),
            CustomWideButton(
              text: "Next",
              onPressed: () {
                if (_validateFields()) {
                  setState(() {
                    _showError = false;
                  });
                  Navigator.push(
                      context,
                      rightToLeftRoute(CredentialsScreen(controllers: {
                        'username': TextEditingController(),
                        'email': TextEditingController(),
                        'password': TextEditingController(),
                      })));
                } else {
                  setState(() {
                    _showError = true;
                  });
                }
              },
            ),
            const SizedBox(height: quaternarySizedBox),
            hasAnAccount(context)
          ],
        ),
      ),
    );
  }
}
