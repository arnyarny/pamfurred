// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pamfurred/backend_logic_files/fetch_locations.dart';
import 'package:pamfurred/backend_logic_files/location_functions.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
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
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the current value of the addressProvider
    final addressAsyncValue = ref.read(addressProvider);

    addressAsyncValue.whenData((address) {
      _controller.text =
          '${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['province'] ?? ''}';

      ref.read(appointmentAddressProvider.notifier).state = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the addressProvider to update the text field if it changes
    final addressAsyncValue = ref.watch(addressProvider);
    final hasDetectedAddress = ref.watch(hasDetectedAddressProvider);

    final street = ref.watch(streetProvider);
    final city = ref.watch(cityProvider);
    final province = ref.watch(provinceProvider);

    // Get formatted address for initial text
    String formattedAddress = '';
    addressAsyncValue.whenData((address) {
      formattedAddress =
          '${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['province'] ?? ''}';

      ref.read(appointmentAddressProvider.notifier).state = formattedAddress;
    });

    addressAsyncValue.whenData((address) {
      if (hasDetectedAddress) {
        formattedAddress = '$street, $city, $province';
      }

      ref.read(appointmentAddressProvider.notifier).state = formattedAddress;
    });

    // Ensure the text in the controller is updated if it changes
    if (_controller.text != formattedAddress) {
      _controller.text = formattedAddress;
    }

    return Scaffold(
      appBar: customAppBarWithTitleAndWidget(context, 'Select address', [
        customSmallPaddedTextButton(
            text: 'Next',
            onPressed: () {
              Navigator.push(
                  context, rightToLeftRoute(const ChooseDateAndTimeScreen()));
            })
      ]),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                labelText: 'Address',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: primaryColor),
                  onPressed: () {
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
    );
  }
}
