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
import 'package:pamfurred/providers/user_details.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAddress extends ConsumerStatefulWidget {
  const EditAddress({super.key});

  @override
  EditAddressState createState() => EditAddressState();
}

class EditAddressState extends ConsumerState<EditAddress> {
  bool _showError = false;
  bool isLoading = false;

  late Map<String, TextEditingController> controllers;

  final Region predefinedRegion = philippineRegions.firstWhere(
    (region) => region.regionName == 'REGION X',
  );
  final Province predefinedProvince = philippineRegions
      .firstWhere((region) => region.regionName == 'REGION X')
      .provinces
      .firstWhere((province) => province.name == 'MISAMIS ORIENTAL');

  Municipality? municipality;
  String? barangay;

  @override
  void initState() {
    super.initState();
    controllers = {
      'floorUnitRoom': TextEditingController(),
      'street': TextEditingController(),
      'barangay': TextEditingController(),
      'city': TextEditingController(),
    };
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  bool _validateFields() {
    final street = controllers['street']?.text.trim() ?? '';
    final barangay = controllers['barangay']?.text.trim() ?? '';
    final city = controllers['city']?.text.trim() ?? '';
    return street.isNotEmpty && barangay.isNotEmpty && city.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: customAppBarWithTitle(context, 'Change address'),
          backgroundColor: Colors.white,
          body: Padding(
            padding: primaryPadding,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader("Home Address Details"),
                  const SizedBox(height: secondarySizedBox),
                  formDescription(
                      context, "Please provide your new home address."),
                  const SizedBox(height: tertiarySizedBox),
                  RichText(
                    text: const TextSpan(
                      text: "Municipality ",
                      style:
                          TextStyle(color: Colors.black, fontSize: regularText),
                      children: [
                        TextSpan(
                            text: "*", style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: secondarySizedBox),
                  CustomDropdown<String>.search(
                    decoration: getDropdownDecoration(),
                    hintText: 'Select Municipality', // Label as a hint
                    // initialItem:
                    //     ref.watch(userMunicipalityProvider).toUpperCase(),
                    items: predefinedProvince.municipalities
                        .map((m) => m.name)
                        .toList(),
                    onChanged: (String? name) {
                      setState(() {
                        municipality =
                            predefinedProvince.municipalities.firstWhere(
                          (m) => m.name == name,
                        );
                        barangay =
                            null; // Reset barangay when municipality changes
                        controllers['city']?.text =
                            name ?? ''; // Update controller
                      });
                    },
                  ),
                  const SizedBox(height: secondarySizedBox),
                  RichText(
                    text: const TextSpan(
                      text: "Barangay ",
                      style:
                          TextStyle(color: Colors.black, fontSize: regularText),
                      children: [
                        TextSpan(
                            text: "*", style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: secondarySizedBox),
                  CustomDropdown<String>.search(
                    decoration: getDropdownDecoration(),
                    hintText: 'Select Barangay', // Label as a hint
                    // initialItem: ref.watch(userBarangayProvider).toUpperCase(),
                    items: municipality?.barangays ?? [],
                    onChanged: (String? value) {
                      setState(() {
                        barangay = value;
                        controllers['barangay']?.text =
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
                          controllers: controllers,
                          isRequired: false,
                          // defaultValue: ref.watch(userFloorUnitRoomProvider),
                        ),
                      ),
                      const SizedBox(width: primarySizedBox),
                      Expanded(
                        child: CustomTextField(
                          label: "Street name",
                          controllerKey: "street",
                          controllers: controllers,
                          // defaultValue: ref.watch(userStreetProvider),
                        ),
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
                    text: "Submit",
                    onPressed: () async {
                      if (_validateFields()) {
                        setState(() {
                          _showError = false;
                          isLoading = true;
                          ref.read(userFloorUnitRoomProvider.notifier).state =
                              controllers['floorUnitRoom']!.text.trim();
                          ref.read(userStreetProvider.notifier).state =
                              controllers['street']!.text.trim();
                          ref.read(userBarangayProvider.notifier).state =
                              controllers['barangay']!.text.trim();
                          ref.read(userMunicipalityProvider.notifier).state =
                              controllers['city']!.text.trim();
                        });
                        final userDetails = await Supabase.instance.client
                            .from('user')
                            .select()
                            .eq(
                                'user_id',
                                ref.watch(
                                    userIdProvider)) // Query based on the current user's ID
                            .single();

                        final String addressId = userDetails['address_id'];

                        await Supabase.instance.client
                            .from(
                                'address') // Assuming you have an address table
                            .update({
                          'floor_unit_room':
                              controllers['floorUnitRoom']!.text.trim(),
                          'street': controllers['street']!.text.trim(),
                          'barangay': controllers['barangay']!.text.trim(),
                          'city': controllers['city']!.text.trim(),
                        }).eq('address_id', addressId);

                        isLoading = false;

                        Navigator.push(
                            context,
                            rightToLeftRoute(const MainScreen(
                              initialPage: 3,
                            )));
                      } else {
                        setState(() {
                          _showError = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black54, // Semi-transparent background
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
