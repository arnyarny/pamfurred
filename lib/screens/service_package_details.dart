import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/service_package_details_provider.dart';
import 'package:pamfurred/screens/appointment/serviceprovider_profile.dart';

class ServicePackageDetails extends ConsumerWidget {
  const ServicePackageDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider and log when the data is being fetched
    print("Fetching service package details...");
    final details = ref.watch(servicePackageDetailsProvider);

    return details.when(
      data: (item) {
        // Log fetched item details and size
        print("Data received: $item");
        print("Item size: ${item.size}");

        // Fallback for missing image
        final image = item.imageUrl.isNotEmpty
            ? item.imageUrl
            : 'https://tinyurl.com/55w8ht23';
        print("Using image URL: $image");

        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(tertiaryBorderRadius),
              topRight: Radius.circular(tertiaryBorderRadius),
            ),
            color: lighterGreyColor,
          ),
          child: Column(
            children: [
              // Notch
              Padding(
                padding: const EdgeInsets.only(top: secondarySizedBox),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(tertiaryBorderRadius),
                    ),
                    color: greyColor,
                  ),
                  width: 50,
                  height: 5,
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Log that content is being built
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main image
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(secondaryBorderRadius),
                            child: CachedNetworkImage(
                              imageUrl: image,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                print("Loading image...");
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorWidget: (context, url, error) {
                                print("Error loading image: $error");
                                return const Icon(Icons.error, size: 48);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Log title and provider details
                          Column(children: [
                            // Title and provider name
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  customTitleText(context, item.name),
                                ],
                              ),
                            ),
                            const SizedBox(height: primarySizedBox),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Service Provider: ${item.spName}',
                                    style: TextStyle(
                                      fontSize: regularText,
                                      color: greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: tertiarySizedBox),

                            // Price details
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                children: [
                                  const Icon(Icons.money_rounded,
                                      color: primaryColor),
                                  const SizedBox(width: secondarySizedBox),
                                  customTitleText(
                                      context, '₱${item.price.toString()}')
                                ],
                              ),
                            ),
                            const SizedBox(height: secondarySizedBox),

                            // **Size display** here
                            if (item.size.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: secondarySizedBox),
                                child: Row(
                                  children: [
                                    const Icon(Icons.abc, color: primaryColor),
                                    const SizedBox(width: secondarySizedBox),
                                    customRegularWeightTitleText(
                                        context, 'Size: ${item.size}')
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: secondarySizedBox),

                            // Weight range display
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                children: [
                                  const Icon(Icons.scale, color: primaryColor),
                                  const SizedBox(width: secondarySizedBox),
                                  customRegularWeightTitleText(context,
                                      '${item.minWeight} - ${item.maxWeight} kg')
                                ],
                              ),
                            ),
                          ]),
                          const SizedBox(height: tertiarySizedBox),
                          CustomWideButton(
                              leadingText: 'Visit  ${item.spName}',
                              trailingIcon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    slideUpRoute(
                                        ServiceproviderProfileScreen()));
                              })
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () {
        print("Loading service package details...");
        return const Center(child: CircularProgressIndicator());
      },
      error: (err, stack) {
        print("Error occurred: $err");
        return Center(
          child: Text(
            'An error occurred: $err',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        );
      },
    );
  }
}
