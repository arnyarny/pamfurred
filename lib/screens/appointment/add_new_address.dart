import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/dropdown_decoration.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';

class AddNewAddressScreen extends ConsumerStatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends ConsumerState<AddNewAddressScreen> {
  // Define controllers for each field
  final Map<String, TextEditingController> controllers = {
    'floorUnitRoom': TextEditingController(),
    'street': TextEditingController(),
    'city': TextEditingController(),
    'barangay': TextEditingController(),
  };

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
  void dispose() {
    // Dispose the controllers when the screen is disposed
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarWithTitle(context, 'Add New Address'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: screenPadding(context),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: "Municipality ",
                        style: TextStyle(
                            color: Colors.black, fontSize: regularText),
                        children: [
                          TextSpan(
                              text: "*", style: TextStyle(color: primaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: tertiarySizedBox),
                CustomDropdown<String>.search(
                  decoration: getDropdownDecoration(),
                  hintText: 'Select Municipality',
                  initialItem: predefinedProvince.municipalities
                          .map((m) => m.name)
                          .contains(ref.watch(addedCityProvider))
                      ? ref.watch(addedCityProvider)
                      : null,
                  items: predefinedProvince.municipalities
                      .map((m) => m.name)
                      .toList(),
                  onChanged: (String? name) {
                    setState(() {
                      municipality =
                          predefinedProvince.municipalities.firstWhere(
                        (m) => m.name == name,
                      );
                      barangay = null;
                      controllers['city']?.text = name ?? '';
                    });
                  },
                ),
                const SizedBox(height: tertiarySizedBox),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: "Barangay ",
                        style: TextStyle(
                            color: Colors.black, fontSize: regularText),
                        children: [
                          TextSpan(
                              text: "*", style: TextStyle(color: primaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: tertiarySizedBox),
                CustomDropdown<String>.search(
                  decoration: getDropdownDecoration(),
                  hintText: 'Select Barangay',
                  items: municipality?.barangays ?? [],
                  initialItem: municipality?.barangays
                              .contains(ref.watch(addedBarangayProvider)) ==
                          true
                      ? ref.watch(addedBarangayProvider)
                      : null,
                  onChanged: (String? value) {
                    setState(() {
                      barangay = value;
                      controllers['barangay']?.text = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: tertiarySizedBox),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "Floor/Unit/Room",
                        controllerKey: "floorUnitRoom",
                        controllers: controllers,
                        isRequired: false,
                        defaultValue:
                            ref.read(addedFloorUnitRoomProvider) ?? '',
                      ),
                    ),
                    const SizedBox(width: primarySizedBox),
                    Expanded(
                      child: CustomTextField(
                        label: "Street name",
                        controllerKey: "street",
                        controllers: controllers,
                        defaultValue: ref.read(addedStreetProvider) ?? '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: quaternarySizedBox),
                customPaddedTextButton(
                  text: 'Add address',
                  onPressed: () {
                    // Update individual providers
                    ref.read(addedFloorUnitRoomProvider.notifier).state =
                        controllers['floorUnitRoom']?.text ?? '';
                    ref.read(addedStreetProvider.notifier).state =
                        controllers['street']?.text ?? '';
                    ref.read(addedBarangayProvider.notifier).state =
                        controllers['barangay']?.text ?? '';
                    ref.read(addedCityProvider.notifier).state =
                        controllers['city']?.text ?? '';

                    // Combine the address into a single string
                    final String address = [
                      controllers['floorUnitRoom']?.text,
                      controllers['street']?.text,
                      controllers['barangay']?.text,
                      controllers['city']?.text,
                    ]
                        .where(
                            (element) => element != null && element.isNotEmpty)
                        .join(', ');

                    // Update the full address provider
                    ref.read(addedAppointmentAddressProvider.notifier).state =
                        address;

                    print('Address: $address');

                    // Navigate back with the address as the result
                    Navigator.pop(context, address);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
