import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/backend_logic_files/location_functions.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_floating_action_button.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/add_new_address.dart';
import 'package:pamfurred/screens/appointment/choose_date_and_time.dart';
import 'package:pamfurred/screens/appointment/serviceprovider_profile.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/pin_location.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SelectAppointmentAddressScreen extends ConsumerStatefulWidget {
  const SelectAppointmentAddressScreen({super.key});

  @override
  SelectAppointmentAddressScreenState createState() =>
      SelectAppointmentAddressScreenState();
}

class SelectAppointmentAddressScreenState
    extends ConsumerState<SelectAppointmentAddressScreen> {
  @override
  Widget build(BuildContext context) {
    final addressAsyncValue = ref.watch(userAddressProvider);
    final addedAddress = ref.watch(addedAppointmentAddressProvider);
    final selectedOption = ref.watch(selectedAddressOptionProvider);
    final pinLocationAddress = ref.watch(pinnedLocationProvider);

    return Scaffold(
      appBar: customAppBarWithTitleAndWidget(context, 'Select Address', [
        customSmallPaddedTextButton(
          text: 'Cancel',
          backgroundColor: Colors.red,
          onPressed: () {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.warning,
                animType: QuickAlertAnimType.slideInUp,
                confirmBtnColor: Colors.red,
                showCancelBtn: true,
                onConfirmBtnTap: () {
                  Navigator.push(
                      context,
                      crossFadeRoute(const MainScreen(
                        initialPage: 0,
                      )));

                  // Clear the cart when this button is pressed
                  ref.read(cartNotifierProvider.notifier).clearCart();
                  ref.read(willBookProvider.notifier).state = false;
                  // If willBook is false, reset the providers
                  resetProviders(ref);
                },
                title: 'Cancel appointment?',
                text:
                    'This will delete all your appointment preferences including all the services and packages currently in your cart.');
          },
        )
      ]),
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: customFloatingActionButton(
        context,
        buttonText: 'Next',
        isEnabled: selectedOption.isNotEmpty,
        onPressed: () {
          Navigator.push(
            context,
            rightToLeftRoute(const ChooseDateAndTimeScreen()),
          );
        },
      ),
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
                          ref
                              .read(selectedAddressOptionProvider.notifier)
                              .state = "Home Address";
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
                    isSelected: ref
                            .read(selectedAddressOptionProvider.notifier)
                            .state ==
                        "Pin Location",
                    onTap: () {
                      setState(() {
                        ref.read(selectedAddressOptionProvider.notifier).state =
                            "Pin Location";
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PinLocationNew(
                                  searchResult: false,
                                )),
                      ).then((result) {
                        if (result != null && result is String) {
                          setState(() {
                            ref.read(pinnedLocationProvider.notifier).state =
                                result;
                            ref
                                .read(appointmentAddressProvider.notifier)
                                .state = result;
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
                    isSelected: ref
                            .read(selectedAddressOptionProvider.notifier)
                            .state ==
                        "Add New Address",
                    onTap: () {
                      setState(() {
                        ref.read(selectedAddressOptionProvider.notifier).state =
                            "Add New Address";
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
