import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/screens/pin_location.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      SearchResultsScreenState();
}

class SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedFilter = 'All';

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
    return SafeArea(
      child: Scaffold(
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
                    scaffoldKey.currentState
                        ?.openEndDrawer(); // Open the drawer
                  },
                  icon: const Icon(Icons.settings, color: Colors.black),
                  label: const Text(
                    'Preferences',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(secondaryBorderRadius),
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
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    final hasDetectedAddress = ref.read(hasDetectedAddressProvider);
    final street = ref.watch(streetProvider);
    final city = ref.watch(cityProvider);
    final province = ref.watch(provinceProvider);

    final minValue = ref.watch(minPriceProvider);
    final maxValue = ref.watch(maxPriceProvider);
    var currentRangeValues = RangeValues(minValue, maxValue);
    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(secondarySizedBox),
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
                        value: 'All',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            ref.read(sortResultsProvider.notifier).state =
                                'All';
                          });
                        },
                      ),
                      const Text(
                        'All',
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
                        value: 'Location',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            ref.read(sortResultsProvider.notifier).state =
                                'Location';
                          });
                        },
                      ),
                      const Text(
                        'Location',
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
            if (selectedFilter == 'Location') ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style:
                        TextStyle(fontSize: titleFont, fontWeight: boldWeight),
                  ),
                ],
              ),
              const SizedBox(height: secondarySizedBox),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: hasDetectedAddress
                            ? '$street, $city, $province'
                            : 'Enter location',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location,
                              color: primaryColor),
                          onPressed: () {
                            Navigator.push(
                                context, slideUpRoute(const PinAddress()));
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      style: const TextStyle(fontSize: regularText),
                    ),
                  ),
                ],
              ),
            ] else if (selectedFilter == 'Price') ...[
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price (₱)',
                        style: TextStyle(
                            fontSize: titleFont, fontWeight: boldWeight),
                      ),
                    ],
                  ),
                  const SizedBox(height: tertiarySizedBox),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 45,
                        width: 70,
                        child: TextField(
                          controller: minRangeController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'min',
                          ),
                          textAlign: TextAlign.center, // Center the text
                          onChanged: (text) {
                            setState(() {
                              // Parse the text from the TextField controller
                              final minValue =
                                  double.tryParse(minRangeController.text);

                              // Update providers with the final value
                              ref.read(minPriceProvider.notifier).state =
                                  minValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: secondarySizedBox),
                      const Text('to'),
                      const SizedBox(width: secondarySizedBox),
                      SizedBox(
                        height: 45,
                        width: 70,
                        child: TextField(
                          controller: maxRangeController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'max',
                          ),
                          textAlign: TextAlign.center, // Center the text
                          onChanged: (text) {
                            setState(() {
                              // Parse the text from the TextField controller
                              final maxValue =
                                  double.tryParse(maxRangeController.text);

                              // Update providers with the final value
                              ref.read(maxPriceProvider.notifier).state =
                                  maxValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    activeColor: secondaryColor,
                    values: currentRangeValues,
                    max: 1000,
                    divisions: 100,
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
            const SizedBox(height: quaternarySizedBox),
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

class ResultsListWidget extends ConsumerWidget {
  const ResultsListWidget({super.key});

  String checkSelectedServiceCategory(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return "veterinary service";
      case 1:
        return "pet grooming";
      case 2:
        return "pet boarding";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedCategoryIndexProvider);

    // Get the current value of the selected results sorter
    final checkResultsSorter = ref.watch(sortResultsProvider);

    final providerDataAsync = checkResultsSorter == 'All'
        ? ref.watch(searchResultsServiceProviders(
            checkSelectedServiceCategory(selectedIndex)))
        : checkResultsSorter == 'Location'
            ? ref.watch(sortSearchResultsByLocation(
                checkSelectedServiceCategory(selectedIndex)))
            : checkResultsSorter == 'Price'
                ? ref.watch(sortSearchResultsByPrice(
                    checkSelectedServiceCategory(selectedIndex)))
                : ref.watch(searchResultsServiceProviders(
                    checkSelectedServiceCategory(selectedIndex)));

    return Expanded(
      child: providerDataAsync.when(
        data: (providers) => ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            var provider = providers[index];

            return SizedBox(
              height: 150,
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 3,
                    shadowColor: lighterGreyColor,
                    color: Colors.white,
                    child: Row(
                      children: [
                        FutureBuilder(
                          future: precacheImage(
                              NetworkImage(provider['service_image'] ?? ''),
                              context),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Image.network(
                                provider['service_image'] ?? '',
                                width: 120,
                                height: 138,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                      height: 138,
                                      width: 120,
                                      child: Icon(Icons.error));
                                },
                              );
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 120,
                                  height: 138,
                                  color: Colors.grey[300],
                                ),
                              );
                            }
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(
                                secondarySizedBox), // Ensure secondarySizedBox is defined
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: customTitleText(
                                        context,
                                        provider['name'] ??
                                            'No name', // Default name if null
                                      ),
                                    ),
                                    ratingWidget(provider['rating'].toString()),
                                  ],
                                ),
                                const SizedBox(
                                    height:
                                        primarySizedBox), // Ensure primarySizedBox is defined
                                Text(
                                  provider['service_name'] ??
                                      'No service', // Default service if null
                                  style: const TextStyle(
                                    fontSize:
                                        regularText, // Ensure regularText is defined
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: primarySizedBox),
                                Row(
                                  children: [
                                    const Text(
                                      "₱",
                                      style: TextStyle(
                                        fontSize:
                                            smallText, // Ensure smallText is defined
                                        color:
                                            primaryColor, // Ensure primaryColor is defined
                                      ),
                                    ),
                                    const SizedBox(width: primarySizedBox),
                                    customTitleTextWithPrimaryColor(
                                      context,
                                      "${provider['price'] ?? 'N/A'}", // Default price if null
                                    ),
                                  ],
                                ),
                                const SizedBox(height: primarySizedBox),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    sentimentLabelTextWidget(
                                      provider[
                                          'sentiment_label'], // Default sentiment if null
                                    ),
                                    Row(
                                      children: [
                                        const Icon(CupertinoIcons.location,
                                            size: 19),
                                        Text(
                                          calculateDistance(
                                              provider['latitude'],
                                              provider['longitude']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: primarySizedBox),
                ],
              ),
            );
          },
        ),
        loading: () => ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 150,
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                  width: 120,
                                  height: 138,
                                  color: Colors.grey[300]),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(secondarySizedBox),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                          width: 150,
                                          height: 20,
                                          color: Colors.grey[300]),
                                    ),
                                    const SizedBox(height: 10),
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                          width: 100,
                                          height: 20,
                                          color: Colors.grey[300]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                  width: 25,
                                  height: 25,
                                  color: Colors.grey[300]),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        error: (error, stackTrace) =>
            Center(child: SelectableText('Error: $error')),
      ),
    );
  }
}
