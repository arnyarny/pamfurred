import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/screens/search_results/search_results_list.dart';
// import 'package:pamfurred/screens/pin_location.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      SearchResultsScreenState();
}

class SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedFilter = 'None';

  final TextEditingController minRangeController = TextEditingController();
  final TextEditingController maxRangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the TextField with provider values
    final minValue = ref.read(minPriceProvider);
    final maxValue = ref.read(maxPriceProvider);
    minRangeController.text = minValue.toString();
    maxRangeController.text = maxValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // Pass the key here
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      endDrawer: buildDrawer(
          context), // Ensure this method is used to build the drawer
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  scaffoldKey.currentState?.openEndDrawer(); // Open the drawer
                },
                icon: const Icon(Icons.settings, color: Colors.black),
                label: const Text(
                  'Preferences',
                  style: TextStyle(color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(secondaryBorderRadius),
                  ),
                ),
              ),
              const SizedBox(width: tertiarySizedBox),
            ],
          ),
          const SizedBox(height: primarySizedBox),
          const ResultsListWidget(),
        ],
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    // final hasDetectedAddress = ref.read(hasDetectedAddressProvider);
    // final street = ref.watch(streetProvider);
    // final city = ref.watch(cityProvider);
    // final province = ref.watch(provinceProvider);

    final minValue = ref.watch(minPriceProvider);
    final maxValue = ref.watch(maxPriceProvider);
    var currentRangeValues =
        RangeValues(minValue.toDouble(), maxValue.toDouble());
    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(secondarySizedBox),
        margin: const EdgeInsets.only(top: quaternarySizedBox),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: const EdgeInsets.all(tertiarySizedBox),
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Preference',
                  style: TextStyle(fontSize: titleFont, fontWeight: boldWeight),
                ),
              ],
            ),
            const SizedBox(height: primarySizedBox),
            Column(
              children: [
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'None',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            ref.read(sortResultsProvider.notifier).state =
                                'None';
                          });
                        },
                      ),
                      const Text(
                        'None',
                        style: TextStyle(fontSize: regularText),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Nearest',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            ref.read(sortResultsProvider.notifier).state =
                                'Nearest';
                          });
                        },
                      ),
                      const Text(
                        'Nearest',
                        style: TextStyle(fontSize: regularText),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Price',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            ref.read(sortResultsProvider.notifier).state =
                                'Price';
                          });
                        },
                      ),
                      const Text(
                        'Price (₱)',
                        style: TextStyle(fontSize: regularText),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: tertiarySizedBox),

            // Conditional rendering based on the selected filter
            // if (selectedFilter == 'Location') ...[
            //   const Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Location',
            //         style:
            //             TextStyle(fontSize: titleFont, fontWeight: boldWeight),
            //       ),
            //     ],
            //   ),
            //   const SizedBox(height: secondarySizedBox),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         decoration: InputDecoration(
            //           hintText: hasDetectedAddress
            //               ? '$street, $city, $province'
            //               : 'Enter location',
            //           suffixIcon: IconButton(
            //             icon: const Icon(Icons.my_location,
            //                 color: primaryColor),
            //             onPressed: () {
            //               Navigator.push(
            //                   context, slideUpRoute(const PinAddress()));
            //             },
            //           ),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(8.0),
            //           ),
            //         ),
            //         style: const TextStyle(fontSize: regularText),
            //       ),
            //     ),
            //   ],
            // ),
            // ]
            if (selectedFilter == 'Price') ...[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price (₱)',
                        style: TextStyle(
                            fontSize: titleFont, fontWeight: boldWeight),
                      ),
                      Row(
                        children: [
                          Text((minRangeController.text)),
                          const Text(' - '),
                          Text((maxRangeController.text)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: tertiarySizedBox),
                  RangeSlider(
                    activeColor: secondaryColor,
                    values: currentRangeValues,
                    max: 5000,
                    divisions: 500,
                    labels: RangeLabels(
                      currentRangeValues.start.round().toString(),
                      currentRangeValues.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        currentRangeValues = values;
                        // Update the TextField's text to reflect the new values
                        minRangeController.text = values.start.toStringAsFixed(
                            0); // Convert to string without decimals
                        maxRangeController.text = values.end.toStringAsFixed(
                            0); // Convert to string without decimals

                        // Update providers with the final values
                        ref.read(minPriceProvider.notifier).state =
                            values.start;
                        ref.read(maxPriceProvider.notifier).state = values.end;
                      });
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: secondarySizedBox),
            TextButton(
              onPressed: () {
                // Add your action here
                Navigator.pop(context); // Close the drawer
              },
              style: TextButton.styleFrom(
                backgroundColor: primaryColor, // You can customize the color
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Done',
                  style: TextStyle(fontSize: regularText, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
