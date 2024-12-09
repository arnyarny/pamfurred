import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/empty_list_widget.dart';
import 'package:pamfurred/components/error_builder.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/providers/service_details_provider.dart';
import 'package:pamfurred/providers/service_package_details_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/service_package_details.dart';
import 'package:shimmer/shimmer.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedHomeScreenSpCategoryProvider.notifier).state =
          selectedCategory;
    });

    // Check the searchedServicePackageProvider state
    final searchedServicePackage = ref.watch(searchedServicePackageProvider);
    final combinedProviderDataAsync = checkResultsSorter == 'None' ||
            checkResultsSorter == ''
        ? ref.watch(combinedSearchResultsProvider(selectedCategory))
        : checkResultsSorter == 'Nearest'
            ? ref.watch(sortSearchResultsByLocation(selectedCategory))
            : checkResultsSorter == 'Price'
                ? ref.watch(sortSearchResultsByPrice(selectedCategory))
                : ref.watch(combinedSearchResultsProvider(selectedCategory));

    return Expanded(
      child: combinedProviderDataAsync.when(
        data: (providers) {
          // Filter providers based on searchedServicePackage if it's not empty
          final filteredProviders = searchedServicePackage.isEmpty
              ? providers
              : providers.where((provider) {
                  // Filter logic, for example:
                  return provider.name
                      .toLowerCase()
                      .contains(searchedServicePackage.toLowerCase());
                }).toList();

          if (filteredProviders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  emptyListWidget(Icons.search_off, 'No results found', '')
                ],
              ),
            );
          }

          return PullToRefresh(
            providersToRefresh: [
              combinedSearchResultsProvider(selectedCategory),
              servicePackageDetailsProvider
            ],
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredProviders.length,
              itemBuilder: (context, index) {
                var provider = filteredProviders[index];

                return SizedBox(
                  height: 150,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Service Provider ID
                          ref.read(selectedSpIndexProvider.notifier).state =
                              provider.spId;
                          print(
                              'selectedSpIndexProvider ID: ${ref.read(selectedSpIndexProvider)}');

                          // Service/Package ID
                          final servicePackageId = ref
                              .read(selectedServicePackageIdProvider.notifier)
                              .state = provider.servicePackageId.toString();
                          print(
                              'selectedServicePackageIdProvider ID: $servicePackageId');

                          // serviceprovider_service_id or serviceprovider_package_id
                          final serviceProviderServicePackageId = ref
                              .read(
                                  selectedServiceProviderServicePackageIdProvider
                                      .notifier)
                              .state = provider.serviceProviderServicePackageId;
                          print(
                              'selectedServiceProviderServicePackageIdProvider ID: $serviceProviderServicePackageId');

                          // Service/Package Type
                          ref
                              .read(
                                  selectedSearchResultServicePackageTypeProvider
                                      .notifier)
                              .state = provider.type;
                          print(
                              'selectedSearchResultServicePackageTypeProvider: ${ref.read(selectedSearchResultServicePackageTypeProvider)}');
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (context) {
                              return SizedBox(
                                  height: 500,
                                  child: const ServicePackageDetails());
                            },
                          );
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
                                      imageUrl: provider.imageUrl == ''
                                          ? 'https://tinyurl.com/55w8ht23'
                                          : provider.imageUrl,
                                      width: 120,
                                      height: 138,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) {
                                        // Placeholder while loading
                                        return Container(
                                          width: 120,
                                          height: 138,
                                          color: Colors.grey[300],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          Text(
                                            "${provider.size}",
                                            style: TextStyle(
                                              fontSize: regularText,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            " • ",
                                            style: TextStyle(
                                              fontSize: smallText,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            "₱",
                                            style: TextStyle(
                                              fontSize: smallText,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(
                                              width: primarySizedBox),
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
                                                  provider.longitude,
                                                ),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return ErrorMessage();
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
          );
        },
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
