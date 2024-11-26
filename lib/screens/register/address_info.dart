import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/dropdown_decoration.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/register.dart';
import 'package:pamfurred/screens/register/credentials.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;

  const AddressDetailsScreen({super.key, required this.controllers});

  @override
  AddressDetailsScreenState createState() => AddressDetailsScreenState();
}

class AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> {
  bool _showError = false;

  final Region predefinedRegion = philippineRegions.firstWhere(
    (region) => region.regionName == 'REGION X',
  );
  final Province predefinedProvince = philippineRegions
      .firstWhere((region) => region.regionName == 'REGION X')
      .provinces
      .firstWhere((province) => province.name == 'MISAMIS ORIENTAL');

  Municipality? municipality;
  String? barangay;

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
            const SizedBox(height: secondarySizedBox),
            formDescription(context,
                "Please enter your address so that we can show you nearby service providers and services based on your location."),
            const SizedBox(height: tertiarySizedBox),
            RichText(
              text: const TextSpan(
                text: "Municipality ",
                style: TextStyle(color: Colors.black, fontSize: regularText),
                children: [
                  TextSpan(text: "*", style: TextStyle(color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: secondarySizedBox),
            CustomDropdown<String>.search(
              decoration: getDropdownDecoration(),
              hintText: 'Select Municipality', // Label as a hint
              items:
                  predefinedProvince.municipalities.map((m) => m.name).toList(),
              onChanged: (String? name) {
                setState(() {
                  municipality = predefinedProvince.municipalities.firstWhere(
                    (m) => m.name == name,
                  );
                  barangay = null; // Reset barangay when municipality changes
                  widget.controllers['city']?.text =
                      name ?? ''; // Update controller
                });
              },
            ),
            const SizedBox(height: secondarySizedBox),
            RichText(
              text: const TextSpan(
                text: "Barangay ",
                style: TextStyle(color: Colors.black, fontSize: regularText),
                children: [
                  TextSpan(text: "*", style: TextStyle(color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: secondarySizedBox),
            CustomDropdown<String>.search(
              decoration: getDropdownDecoration(),
              hintText: 'Select Barangay', // Label as a hint
              items: municipality?.barangays ?? [],
              onChanged: (String? value) {
                setState(() {
                  barangay = value;
                  widget.controllers['barangay']?.text =
                      value ?? ''; // Update controller
                });
              },
            ),
            const SizedBox(height: secondarySizedBox),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                      label: "Floor/Unit/Room",
                      controllerKey: "floorUnitRoom",
                      controllers: widget.controllers),
                ),
                const SizedBox(width: primarySizedBox),
                Expanded(
                  child: CustomTextField(
                      label: "Street name",
                      controllerKey: "street",
                      controllers: widget.controllers),
                ),
              ],
            ),
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
                    ref.read(floorUnitRoomProvider.notifier).state =
                        widget.controllers['floorUnitRoom']!.text.trim();
                    ref.read(streetProvider.notifier).state =
                        widget.controllers['street']!.text.trim();
                    ref.read(barangayProvider.notifier).state =
                        widget.controllers['barangay']!.text.trim();
                    ref.read(cityProvider.notifier).state =
                        widget.controllers['city']!.text.trim();
                  });
                  Navigator.push(
                      context,
                      rightToLeftRoute(CredentialsScreen(controllers: {
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
