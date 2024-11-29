import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/backend_logic_files/location_functions.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/add_new_address.dart';
import 'package:pamfurred/screens/appointment/choose_date_and_time.dart';
import 'package:pamfurred/screens/pin_location_new.dart';

class SelectAppointmentAddressScreen extends ConsumerStatefulWidget {
  const SelectAppointmentAddressScreen({super.key});

  @override
  SelectAppointmentAddressScreenState createState() =>
      SelectAppointmentAddressScreenState();
}

class SelectAppointmentAddressScreenState
    extends ConsumerState<SelectAppointmentAddressScreen> {
  String selectedOption = ""; // Tracks the selected option
  String pinLocationAddress = ""; // Stores the Pin Location address

  @override
  Widget build(BuildContext context) {
    final addressAsyncValue = ref.watch(userAddressProvider);
    final addedAddress = ref.watch(addedAppointmentAddressProvider);

    return Scaffold(
      appBar: customAppBarWithTitleAndWidget(context, 'Select Address', [
        customSmallPaddedTextButton(
          text: 'Next',
          onPressed: () {
            Navigator.push(
              context,
              rightToLeftRoute(const ChooseDateAndTimeScreen()),
            );
          },
          isEnabled: ref.watch(appointmentAddressProvider) != '' ||
              ref.watch(appointmentAddressProvider).isNotEmpty,
        )
      ]),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Home Address Card
                  _buildAddressCard(
                    context: context,
                    title: "Home Address",
                    description: addressAsyncValue.when(
                      data: (address) {
                        final formattedAddress =
                            '${address['floor_unit_room'] ?? ''}, ${address['street'] ?? ''}, ${address['barangay'] ?? ''}, ${address['city'] ?? ''}';
                        return formattedAddress.isNotEmpty
                            ? formattedAddress
                            : "Fetching home address...";
                      },
                      loading: () => "Fetching home address...",
                      error: (error, stack) => "Error loading address",
                    ),
                    isSelected: selectedOption == "Home Address",
                    onTap: () {
                      addressAsyncValue.whenData((address) {
                        final formattedAddress =
                            '${address['floor_unit_room'] ?? ''}, ${address['street'] ?? ''}, ${address['barangay'] ?? ''}, ${address['city'] ?? ''}';
                        setState(() {
                          selectedOption = "Home Address";
                        });
                        ref.read(appointmentAddressProvider.notifier).state =
                            formattedAddress;
                      });
                    },
                  ),
                  const SizedBox(height: tertiarySizedBox),
                  // Pin Location Card
                  _buildAddressCard(
                    context: context,
                    title: "Pin Location",
                    description: pinLocationAddress.isNotEmpty
                        ? pinLocationAddress
                        : 'No address selected',
                    isSelected: selectedOption == "Pin Location",
                    onTap: () {
                      setState(() {
                        selectedOption = "Pin Location";
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PinLocationNew()),
                      ).then((result) {
                        if (result != null && result is String) {
                          setState(() {
                            pinLocationAddress = result;
                            ref
                                .read(appointmentAddressProvider.notifier)
                                .state = pinLocationAddress;
                          });
                        }
                      });
                    },
                  ),
                  const SizedBox(height: tertiarySizedBox),
                  // Add New Address Card
                  _buildAddressCard(
                    context: context,
                    title: "Add New Address",
                    description: addedAddress.isNotEmpty
                        ? addedAddress
                        : 'No address selected',
                    isSelected: selectedOption == "Add New Address",
                    onTap: () {
                      setState(() {
                        selectedOption = "Add New Address";
                      });
                      Navigator.push(
                        context,
                        slideUpRoute(const AddNewAddressScreen()),
                      ).then((result) {
                        if (result != null && result is String) {
                          ref
                              .read(addedAppointmentAddressProvider.notifier)
                              .state = result;
                          ref.read(appointmentAddressProvider.notifier).state =
                              result;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required BuildContext context,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : greyColor,
            ),
            const SizedBox(width: tertiarySizedBox),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: regularText,
                        fontWeight: boldWeight,
                        color: Colors.black),
                  ),
                  const SizedBox(height: primarySizedBox),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: smallText,
                      color: greyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
