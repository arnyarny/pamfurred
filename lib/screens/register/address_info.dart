import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pamfurred/backend_logic_files/fetch_locations.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/pin_location.dart';
// import 'package:pamfurred/screens/register/address_test.dart';
import 'package:pamfurred/screens/register/credentials.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;

  const AddressDetailsScreen({super.key, required this.controllers});

  @override
  AddressDetailsScreenState createState() => AddressDetailsScreenState();
}

class AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> {
  bool _showError = false;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
            Padding(
              padding: const EdgeInsets.only(bottom: secondarySizedBox),
              child: TypeAheadField<Map<String, String>>(
                controller: _controller,
                focusNode: _focusNode,
                debounceDuration: const Duration(milliseconds: 300),
                hideOnEmpty: true,
                hideOnLoading: false,
                hideOnError: false,
                suggestionsCallback: (pattern) async {
                  if (pattern.isNotEmpty) {
                    return await fetchLocations(pattern);
                  } else {
                    return [];
                  }
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['displayName'] ?? 'Unknown'),
                  );
                },
                onSelected: (suggestion) {
                  _controller.text = suggestion['displayName']!;
                  ref.read(appointmentAddressProvider.notifier).state =
                      _controller.text;
                },
                errorBuilder: (context, error) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Error fetching suggestions.'),
                ),
                loadingBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
                emptyBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No results found.'),
                ),
                animationDuration: const Duration(milliseconds: 300),
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: _controller,
                    focusNode: focusNode,
                    autofocus: false,
                    decoration: InputDecoration(
                      labelText: 'Type or pin address',
                      suffixIcon: IconButton(
                        icon:
                            const Icon(Icons.my_location, color: primaryColor),
                        onPressed: () {
                          // Navigator.push(context,
                          //     slideUpRoute(const TestPhilippineDropdown()));
                          Navigator.push(
                            context,
                            slideUpRoute(const PinAddress()),
                          );
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: const TextStyle(fontSize: regularText),
                  );
                },
              ),
            ),
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
            const SizedBox(height: secondarySizedBox),
            CustomTextField(
                label: "Barangay",
                controllerKey: "barangay",
                controllers: widget.controllers),
            const SizedBox(width: primarySizedBox),
            CustomTextField(
                label: "City",
                controllerKey: "city",
                controllers: widget.controllers),
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
