// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pamfurred/backend_logic_files/fetch_locations.dart';
import 'package:pamfurred/backend_logic_files/location_functions.dart';

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
      // Ensure address is not null before setting the controller text
      _controller.text =
          '${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['province'] ?? ''}';
        });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the addressProvider to update the text field if it changes
    final addressAsyncValue = ref.watch(addressProvider);
    addressAsyncValue.whenData((address) {
      // Only update the controller text if it has changed
      if (_controller.text !=
          '${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['province'] ?? ''}') {
        _controller.text =
            '${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['province'] ?? ''}';
      }
        });

    return Scaffold(
      appBar: AppBar(title: const Text('Location Search')),
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
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Selected Location'),
                content: Text(
                  'Address: ${suggestion['address']}, ${suggestion['city']}, ${suggestion['country']}\n'
                  'Latitude: ${suggestion['latitude']}\n'
                  'Longitude: ${suggestion['longitude']}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
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
        ),
      ),
    );
  }
}
