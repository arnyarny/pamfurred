import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/search_results_provider.dart';

class PinLocationNew extends ConsumerStatefulWidget {
  final bool searchResult; // Indicates if it's a search result input

  const PinLocationNew({super.key, required this.searchResult});

  @override
  ConsumerState<PinLocationNew> createState() => _PinLocationNewState();
}

class _PinLocationNewState extends ConsumerState<PinLocationNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OpenStreetMapSearchAndPick(
      buttonTextStyle: const TextStyle(fontSize: regularText),
      locationPinText: '',
      locationPinIconColor: primaryColor,
      buttonColor: primaryColor,
      buttonText: 'Set Current Location',
      onPicked: (pickedData) {
        if (widget.searchResult) {
          setState(() {
            ref.read(inputLatProvider.notifier).state =
                pickedData.latLong.latitude;
            ref.read(inputLongProvider.notifier).state =
                pickedData.latLong.longitude;
          });
          // Pass latitude, longitude, and addressName if it's a search result
          Navigator.pop(context, {
            'latitude': pickedData.latLong.latitude,
            'longitude': pickedData.latLong.longitude,
            'addressName': pickedData.addressName,
          });
        } else {
          // Pass only the addressName back to the previous screen
          Navigator.pop(context, pickedData.addressName);
        }
      },
    ));
  }
}
