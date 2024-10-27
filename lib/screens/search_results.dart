import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/screens/edit_preferences.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      SearchResultsScreenState();
}

class SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedCategoryIndexProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(context),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      rightToLeftRoute(
                        EditPreferencesScreen(index: selectedIndex),
                      ),
                    );
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
              height: 120,
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
                        // Handle null values for the image
                        Image.network(
                          provider['service_image'] ??
                              '', // Provide a default if null
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                                height: 100,
                                width: 100,
                                child: Icon(Icons.error));
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(secondarySizedBox),
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
                                  ],
                                ),
                                const SizedBox(height: primarySizedBox),
                                Text(
                                  provider['service_name'] ??
                                      'No service', // Default service if null
                                  style: const TextStyle(
                                    fontSize: smallText,
                                    color: Colors.black,
                                  ),
                                ),
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
                                      "${provider['price'] ?? 'N/A'}", // Default price if null
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: tertiarySizedBox),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ratingWidget(provider['rating'].toString()),
                              const SizedBox(height: quaternarySizedBox),
                              provider['sentiment_label'] == null ||
                                      provider['sentiment_label'] == 0
                                  ? const Text(
                                      'N/A',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    )
                                  : sentimentLabelTextWidget(
                                      provider['sentiment_label'] ??
                                          'Unknown', // Handle null
                                    ),
                            ],
                          ),
                        ),
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
                    Container(width: 100, height: 100, color: Colors.grey[300]),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 150,
                                height: 20,
                                color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Container(
                                width: 100,
                                height: 20,
                                color: Colors.grey[300]),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 25, height: 25, color: Colors.grey[300]),
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
