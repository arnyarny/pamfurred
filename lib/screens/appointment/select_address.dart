import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pamfurred/backend_logic_files/fetch_locations.dart';
import 'package:pamfurred/backend_logic_files/location_functions.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/add_new_address.dart';
import 'package:pamfurred/screens/appointment/choose_date_and_time.dart';
import 'package:pamfurred/screens/pin_location.dart';

class SelectAppointmentAddressScreen extends ConsumerStatefulWidget {
  const SelectAppointmentAddressScreen({super.key});

  @override
  SelectAppointmentAddressScreenState createState() =>
      SelectAppointmentAddressScreenState();
}

class SelectAppointmentAddressScreenState
    extends ConsumerState<SelectAppointmentAddressScreen> {
  String selectedOption = ""; // Tracks the selected option
  String displayAddress = ""; // Address to display below the options
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final addressAsyncValue = ref.watch(userAddressProvider);

    final hasDetectedAddress = ref.watch(hasDetectedAddressProvider);

    final street = ref.watch(streetProvider);
    final city = ref.watch(cityProvider);
    final province = ref.watch(provinceProvider);

    String formattedAddress = '';

    addressAsyncValue.whenData((address) {
      if (hasDetectedAddress) {
        formattedAddress = '$street, $city, $province';
      }
    });

    // Ensure the text in the controller is updated if it changes
    if (_controller.text != formattedAddress) {
      _controller.text = formattedAddress;
    }

    return Scaffold(
      appBar: customAppBarWithTitleAndWidget(context, 'Select Address', [
        customSmallPaddedTextButton(
          text: 'Next',
          onPressed: () {
            Navigator.push(
                context, rightToLeftRoute(const ChooseDateAndTimeScreen()));
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
            // List of cards for each option
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Home Address Card
                  Card(
                    color: lightGreyColor,
                    child: ListTile(
                      title: const Text(
                        "Home Address",
                        style: TextStyle(
                            fontSize: regularText, color: Colors.black),
                      ),
                      subtitle: addressAsyncValue.when(
                        data: (address) {
                          formattedAddress =
                              '${address['floor_unit_room'] ?? ''}, ${address['street'] ?? ''}, ${address['barangay'] ?? ''}, ${address['city'] ?? ''}';
                          return Text(
                            formattedAddress.isNotEmpty
                                ? formattedAddress
                                : "Fetching home address...",
                            style: const TextStyle(fontSize: smallText),
                          );
                        },
                        loading: () => const Text("Fetching home address..."),
                        error: (error, stack) =>
                            const Text('Error loading address'),
                      ),
                      trailing: selectedOption == "Home Address"
                          ? const Icon(Icons.check, color: primaryColor)
                          : null,
                      onTap: () {
                        // When Home Address is selected
                        addressAsyncValue.whenData((address) {
                          setState(() {
                            selectedOption = "Home Address";

                            print(
                                'Home Address: ${address['floor_unit_room'] ?? ''}, ${address['street'] ?? ''}, ${address['barangay'] ?? ''}, ${address['city'] ?? ''}');
                          });

                          // Update the provider with the selected address
                          ref.read(appointmentAddressProvider.notifier).state =
                              formattedAddress;
                        });
                      },
                    ),
                  ),
                  // Pin or Type Location Card
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Card(
                      color: lightGreyColor,
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("Pin or Type Location",
                                style: TextStyle(
                                    fontSize: regularText,
                                    color: Colors.black)),
                            trailing: selectedOption == "Pin or Type Location"
                                ? const Icon(Icons.check, color: primaryColor)
                                : null,
                            onTap: () {
                              setState(() {
                                selectedOption = "Pin or Type Location";
                                displayAddress = _controller.text;

                                // Update the provider with the selected address
                                ref
                                    .read(appointmentAddressProvider.notifier)
                                    .state = displayAddress;
                              });
                            },
                          ),
                          if (selectedOption == "Pin or Type Location")
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TypeAheadField<Map<String, String>>(
                                controller: _controller,
                                focusNode: _focusNode,
                                debounceDuration:
                                    const Duration(milliseconds: 300),
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
                                    title: Text(
                                        suggestion['displayName'] ?? 'Unknown'),
                                  );
                                },
                                onSelected: (suggestion) {
                                  _controller.text = suggestion['displayName']!;

                                  ref
                                      .read(appointmentAddressProvider.notifier)
                                      .state = _controller.text;
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
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                builder: (context, controller, focusNode) {
                                  return TextField(
                                    controller: _controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Address',
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.my_location,
                                            color: primaryColor),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            slideUpRoute(const PinAddress()),
                                          ).then((result) {
                                            if (result != null) {
                                              setState(() {
                                                _controller.text = result;
                                                displayAddress = result;

                                                // Update the provider with the selected address
                                                ref
                                                    .read(
                                                        appointmentAddressProvider
                                                            .notifier)
                                                    .state = displayAddress;
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    style:
                                        const TextStyle(fontSize: regularText),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Add New Address Card
                  Card(
                    color: lightGreyColor,
                    child: ListTile(
                      title: const Text("Add New Address",
                          style: TextStyle(
                              fontSize: regularText, color: Colors.black)),
                      subtitle: Text(
                        ref.watch(addedAppointmentAddressProvider) ??
                            'No address selected',
                        style: const TextStyle(fontSize: smallText),
                      ), // Use the provider's value
                      trailing: selectedOption == "Add New Address"
                          ? const Icon(Icons.check, color: primaryColor)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedOption = "Add New Address";
                        });
                        Navigator.push(
                          context,
                          slideUpRoute(const AddNewAddressScreen()),
                        ).then((result) {
                          if (result != null || result != '') {
                            setState(() {
                              displayAddress = ref.watch(
                                  addedAppointmentAddressProvider); // Update the provider state
                              // Update the provider with the selected address
                              ref
                                  .read(appointmentAddressProvider.notifier)
                                  .state = displayAddress;
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Display selected address below the cards
            // const Text(
            //   "Selected Address:",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // Text(
            //   displayAddress.isNotEmpty
            //       ? displayAddress
            //       : "No address selected",
            //   style: const TextStyle(fontSize: 14),
            // ),
          ],
        ),
      ),
    );
  }
}
