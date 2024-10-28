import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/rating_widget.dart';
// import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
// import 'package:pamfurred/screens/edit_preferences.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      SearchResultsScreenState();
}

class SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  // Move the GlobalKey here
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

  // This method builds the drawer
  Widget buildDrawer(BuildContext context) {
    String? selectedPrice;
    double priceRange = 500;

    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Preferences',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                      suffixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Low',
                  groupValue: selectedPrice,
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value;
                    });
                  },
                ),
                const Text('Low'),
                Radio<String>(
                  value: 'Medium',
                  groupValue: selectedPrice,
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value;
                    });
                  },
                ),
                const Text('Medium'),
                Radio<String>(
                  value: 'High',
                  groupValue: selectedPrice,
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value;
                    });
                  },
                ),
                const Text('High'),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              min: 0,
              max: 1000,
              divisions: 10,
              label: 'Select price range',
              value: priceRange,
              onChanged: (double value) {
                setState(() {
                  priceRange = value;
                });
              },
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
    final providerDataAsync = ref.watch(
      searchResultsServiceProviders(
          checkSelectedServiceCategory(selectedIndex)),
    );

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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                          width: 100, height: 100, color: Colors.grey[300]),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                          width: 25, height: 25, color: Colors.grey[300]),
                    ),
                    const SizedBox(width: 8),
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
