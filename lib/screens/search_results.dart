import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/service_details_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
// import 'package:pamfurred/screens/pin_location.dart';
import 'package:pamfurred/screens/service_package_details.dart';
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
                        value: 'Distance',
                        groupValue: selectedFilter,
                        onChanged: (String? value) {
                          setState(() {
                            selectedFilter = value!;
                            ref.read(sortResultsProvider.notifier).state =
                                'Distance';
                          });
                        },
                      ),
                      const Text(
                        'Distance',
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
    final selectedCategory = checkSelectedServiceCategory(selectedIndex);

    // Use combined provider based on sorting option
    final providerDataAsync = checkResultsSorter == 'All' ||
            checkResultsSorter == ''
        ? ref.watch(combinedSearchResultsProvider(selectedCategory))
        : checkResultsSorter == 'Distance'
            ? ref.watch(sortSearchResultsByLocation(selectedCategory))
            : checkResultsSorter == 'Price'
                ? ref.watch(sortSearchResultsByPrice(selectedCategory))
                : ref.watch(combinedSearchResultsProvider(selectedCategory));

    return Expanded(
      child: providerDataAsync.when(
        data: (providers) => PullToRefresh(
          providersToRefresh: [
            combinedSearchResultsProvider(selectedCategory),
          ],
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              var provider = providers[index];

              return SizedBox(
                height: 150,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final spId = ref
                            .read(selectedServicePackageIdProvider.notifier)
                            .state = provider.servicePackageId;
                        print('Service Provider ID: $spId');
                        ref.read(selectedSpIndexProvider.notifier).state =
                            provider.spId;
                        Navigator.push(context,
                            slideUpRoute(const ServicePackageDetails()));
                      },
                      child: Card(
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
                                  NetworkImage(provider.imageUrl), context),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return CachedNetworkImage(
                                    imageUrl: provider.imageUrl,
                                    width: 120,
                                    height: 138,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) {
                                      // Placeholder while loading
                                      return Container(
                                        width: 120,
                                        height: 138,
                                        color: Colors
                                            .grey[300], // Placeholder color
                                      );
                                    },
                                    errorWidget: (context, url, error) {
                                      // Error icon if the image fails to load
                                      return const SizedBox(
                                        width: 120,
                                        height: 138,
                                        child: Icon(Icons.error),
                                      );
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
                                padding:
                                    const EdgeInsets.all(secondarySizedBox),
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
                                            capitalizeFirstLetter(
                                                provider.spName),
                                          ),
                                        ),
                                        ratingWidget((provider.averageRating)
                                            .toStringAsFixed(1)),
                                      ],
                                    ),
                                    const SizedBox(height: primarySizedBox),
                                    Text(
                                      capitalizeFirstLetter(provider.name),
                                      style: const TextStyle(
                                        fontSize: regularText,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: primarySizedBox),
                                    Row(
                                      children: [
                                        const Text(
                                          "₱",
                                          style: TextStyle(
                                            fontSize: smallText,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: primarySizedBox),
                                        customTitleTextWithPrimaryColor(
                                          context,
                                          "${provider.price}",
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: primarySizedBox),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        sentimentLabelTextWidget(
                                          provider.sentimentLabel,
                                        ),
                                        Row(
                                          children: [
                                            FutureBuilder<String?>(
                                              future: getDistanceToTarget(
                                                  ref,
                                                  provider.latitude,
                                                  provider.longitude),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else if (snapshot.hasData) {
                                                  return Row(
                                                    children: [
                                                      const Icon(
                                                          CupertinoIcons
                                                              .location,
                                                          size: 19),
                                                      Text(snapshot.data ??
                                                          'Distance not available'),
                                                    ],
                                                  );
                                                } else {
                                                  return const Text('');
                                                }
                                              },
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
                    ),
                    const SizedBox(height: primarySizedBox),
                  ],
                ),
              );
            },
          ),
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
