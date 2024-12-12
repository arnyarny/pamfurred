import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/backend_logic_files/store_location.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/screens/pin_location.dart';
import 'package:pamfurred/screens/search_results/input_price.dart';
import 'package:pamfurred/screens/search_results/methods/check_selected_category.dart';
import 'package:pamfurred/screens/search_results/search_results_list.dart';
import 'package:pamfurred/screens/search_results/search_screen.dart';
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

  // Controllers for price range (not input)
  final TextEditingController minRangeController = TextEditingController();
  final TextEditingController maxRangeController = TextEditingController();

  // Controllers for INPUTted price range
  final TextEditingController inputMinPriceController = TextEditingController();
  final TextEditingController inputMaxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the TextField with provider values
    final minValue = ref.read(minPriceProvider);
    final maxValue = ref.read(maxPriceProvider);
    minRangeController.text = minValue.toString();
    maxRangeController.text = maxValue.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedIndex = ref.watch(selectedCategoryIndexProvider);

      final refreshedProvider = ref.refresh(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refreshed provider: $refreshedProvider');
    });
  }

  @override
  Widget build(BuildContext context) {
    // final supabase = Supabase.instance.client;

    // final selectedIndex = ref.watch(selectedCategoryIndexProvider);

    // // Listen to realtime changes in db
    // supabase.from('service').stream(primaryKey: ['service_id']).listen(
    //     (List<Map<String, dynamic>> data) {
    //   ref.invalidate(combinedSearchResultsProvider(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   final refreshCombined = ref.refresh(combinedSearchResultsProvider(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   print('Refresh provider: $refreshCombined');

    //   ref.invalidate(searchResultsServiceProviderServices(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   final refreshServices = ref.refresh(searchResultsServiceProviderServices(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   print('Refresh provider: $refreshServices');
    // });

    // supabase.from('package').stream(primaryKey: ['package_id']).listen(
    //     (List<Map<String, dynamic>> data) {
    //   ref.invalidate(combinedSearchResultsProvider(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   final refreshCombined = ref.refresh(combinedSearchResultsProvider(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   print('Refresh provider: $refreshCombined');

    //   ref.invalidate(searchResultsServiceProviderPackages(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   final refreshPackages = ref.refresh(searchResultsServiceProviderPackages(
    //       checkSelectedServiceCategory(selectedIndex)));
    //   print('Refresh provider: $refreshPackages');
    // });

    return Scaffold(
      key: scaffoldKey, // Pass the key here
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Navigate to a new screen with an actual TextField
                  Navigator.push(context, crossFadeRoute(SearchScreen()));
                },
                child: Container(
                  width: 350, // Adjust width as needed
                  decoration: BoxDecoration(
                    color:
                        Colors.grey[200], // Background color of the container
                    borderRadius: BorderRadius.circular(secondaryBorderRadius),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ref.watch(searchedServicePackageProvider) == ''
                              ? 'Search service or package...'
                              : ref.watch(searchedServicePackageProvider),
                          style: TextStyle(
                            color: greyColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (ref
                              .read(searchedServicePackageProvider.notifier)
                              .state !=
                          '') ...[
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(searchedServicePackageProvider.notifier)
                                .state = '';
                          },
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          CupertinoIcons.search,
                          color: Colors.black,
                          size: 25,
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
              ref.read(searchedServicePackageProvider.notifier).state = '';
            },
          ),
        ),
      ),
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
                            ref.read(isInputLocationProvider.notifier).state =
                                false;
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
                            ref.read(isInputLocationProvider.notifier).state =
                                false;
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
                            ref.read(isInputLocationProvider.notifier).state =
                                false;
                            ref.read(isInputPriceProvider.notifier).state =
                                false;
                            ref.read(sortResultsProvider.notifier).state =
                                'Price';
                          });
                        },
                      ),
                      const Text(
                        'Price range',
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
                        value: 'Nearby pinned location',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            ref.read(sortResultsProvider.notifier).state =
                                'Nearest';
                            ref.read(isInputLocationProvider.notifier).state =
                                true;

                            ref.read(inputLatProvider.notifier).state =
                                ref.watch(locationProvider).latitude;

                            ref.read(inputLongProvider.notifier).state =
                                ref.watch(locationProvider).longitude;
                          });
                        },
                      ),
                      const Text(
                        'Nearby pinned location',
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
                        value: 'Inputted price range',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            // Set input location provider to false to avoid chang  ing the distance calculation
                            ref.read(isInputLocationProvider.notifier).state =
                                false;

                            // Set input price provider to true to watch changes during price range inputting
                            ref.read(isInputPriceProvider.notifier).state =
                                true;
                            ref.read(sortResultsProvider.notifier).state =
                                'Price';
                          });
                        },
                      ),
                      const Text(
                        'Inputted price range',
                        style: TextStyle(fontSize: regularText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: tertiarySizedBox),
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
                    max: 1000,
                    divisions: 100,
                    labels: RangeLabels(
                      currentRangeValues.start.round().toStringAsFixed(0),
                      currentRangeValues.end.round().toStringAsFixed(0),
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
            if (selectedFilter == 'Nearby pinned location') ...[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pinned location',
                        style: TextStyle(
                            fontSize: titleFont, fontWeight: boldWeight),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              slideUpRoute(
                                  const PinLocationNew(searchResult: true)),
                            ).then((result) {
                              if (result != null) {
                                if (result is Map &&
                                    result.containsKey('latitude') &&
                                    result.containsKey('longitude')) {
                                  // Set the selected full address in the provider
                                  ref
                                      .read(inputFullAddressProvider.notifier)
                                      .state = result['addressName'].toString();
                                  // Set the selected location in the providers

                                  ref.read(inputLatProvider.notifier).state =
                                      result['latitude'];

                                  ref.read(inputLongProvider.notifier).state =
                                      result['longitude'];

                                  print(
                                      'Selected location: ${result['latitude']}, ${result['longitude']}');
                                  print(result['addressName'].toString());
                                } else {
                                  print('Address: $result');
                                }
                              }
                            });
                          },
                          icon: Icon(Icons.edit))
                    ],
                  ),
                  const SizedBox(
                    height: primarySizedBox,
                  ),
                  ref.watch(inputFullAddressProvider) == ''
                      ? Text('No address pinned.')
                      : Text(ref.watch(inputFullAddressProvider).toString()),
                ],
              )
            ],
            if (selectedFilter == 'Inputted price range') ...[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price (₱)',
                        style: TextStyle(
                            fontSize: titleFont, fontWeight: boldWeight),
                      ),
                      IconButton(
                          onPressed: () {
                            // Navigate to the price range input screen
                            Navigator.push(
                                context,
                                slideUpRoute(
                                  PriceRangeInputScreen(
                                    inputMinPriceController:
                                        inputMinPriceController,
                                    inputMaxPriceController:
                                        inputMaxPriceController,
                                  ),
                                )).then(
                              (result) {
                                if (result != null) {
                                  if (result is Map &&
                                      result.containsKey('inputMinPrice') &&
                                      result.containsKey('inputMaxPrice')) {
                                    setState(() {
                                      // Set input price provider to true to watch changes during price range inputting
                                      ref
                                          .read(isInputPriceProvider.notifier)
                                          .state = true;
                                      // Set the selected location in the providers
                                      ref
                                          .read(inputMinPriceProvider.notifier)
                                          .state = result['inputMinPrice'];
                                      ref
                                          .read(inputMaxPriceProvider.notifier)
                                          .state = result['inputMaxPrice'];
                                    });
                                    print(
                                        'Inputted prices: ${result['inputMinPrice']} and ${result['inputMaxPrice']}');
                                    print(result['inputMinPrice'].toString());
                                  } else {
                                    print('Prices: $result');
                                  }
                                }
                              },
                            );
                          },
                          icon: Icon(Icons.edit))
                    ],
                  ),
                  const SizedBox(
                    height: primarySizedBox,
                  ),
                  Row(
                    children: [
                      Text(
                        ref.watch(inputMinPriceProvider).toString(),
                        style: TextStyle(fontSize: regularText),
                      ),
                      const Text(' - '),
                      Text(
                        ref.watch(inputMaxPriceProvider).toString(),
                        style: TextStyle(fontSize: regularText),
                      ),
                    ],
                  ),
                ],
              )
            ],
            const SizedBox(height: tertiarySizedBox),
            TextButton(
              onPressed: () {
                // Add action here
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
