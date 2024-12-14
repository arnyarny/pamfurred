import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/service_details_provider.dart';
import 'package:pamfurred/providers/service_package_details_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/serviceprovider_profile.dart';
import 'package:pamfurred/screens/search_results/search_results_appointment_pref.dart';
import 'package:shimmer/shimmer.dart';

class ServicePackageDetails extends ConsumerWidget {
  const ServicePackageDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider and log when the data is being fetched
    print("Fetching service package details...");
    final details = ref.watch(servicePackageDetailsProvider);

    final itemType = ref.watch(selectedSearchResultServicePackageTypeProvider);

    final spAvgRating = ref.watch(selectedSearchResultSpAvgRating);

    final spSentimentLabel = ref.watch(selectedSearchResultSpSentimentLabel);

    final bool willBook = ref.watch(willBookProvider);

    return details.when(
      data: (item) {
        // Fallback for missing image
        final image = item.imageUrl.isNotEmpty
            ? item.imageUrl
            : 'https://tinyurl.com/55w8ht23';

        List<String> petType = List<String>.from(item.petType);

        List<String> servicePackageType =
            List<String>.from(item.servicePackageType);

        final cartServices = ref.watch(cartNotifierProvider);
        final isInCart = cartServices.any(
          (cartService) =>
              (itemType == "service" &&
                  cartService.id == item.servicePackageId &&
                  cartService.servicePackageDetailsId ==
                      item.serviceProviderServicePackageId) ||
              (itemType == "package" &&
                  cartService.id == item.servicePackageId &&
                  cartService.servicePackageDetailsId ==
                      item.serviceProviderServicePackageId),
        );

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
                              fit: item.imageUrl.isNotEmpty
                                  ? BoxFit.cover
                                  : BoxFit.fitHeight,
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  willBook
                                      ? GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) => const SizedBox(
                                                  height: 300,
                                                  child:
                                                      ChooseSearchResultsAppointmentPreferencesScreen()),
                                            );
                                          },
                                          child: Icon(Icons.filter_list))
                                      : SizedBox.shrink(),
                                  willBook
                                      ? FilledButton.icon(
                                          label: Text(
                                            'Cancel booking',
                                            style: TextStyle(
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(0,
                                                      0.2), // Horizontal and vertical offset
                                                  blurRadius:
                                                      5.0, // Blur effect
                                                  color:
                                                      greyColor, // Shadow color
                                                ),
                                              ],
                                            ),
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll<Color>(
                                                primaryColor, // Uniform color for all states
                                              ),
                                              shape: WidgetStatePropertyAll<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          secondaryBorderRadius),
                                                ),
                                              )),
                                          onPressed: () {
                                            // Clear the cart when this button is pressed
                                            ref
                                                .read(cartNotifierProvider
                                                    .notifier)
                                                .clearCart();
                                            ref
                                                .read(willBookProvider.notifier)
                                                .state = false;
                                            // If willBook is false, reset the providers
                                            resetProviders(ref);
                                          },
                                        )
                                      : FilledButton.icon(
                                          label: Text(
                                            'Book now',
                                            style: TextStyle(
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(0,
                                                      0.2), // Horizontal and vertical offset
                                                  blurRadius:
                                                      5.0, // Blur effect
                                                  color:
                                                      greyColor, // Shadow color
                                                ),
                                              ],
                                            ),
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll<Color>(
                                                secondaryColor, // Uniform color for all states
                                              ),
                                              shape: WidgetStatePropertyAll<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          secondaryBorderRadius),
                                                ),
                                              )),
                                          onPressed: () {
                                            ref
                                                .read(willBookProvider.notifier)
                                                .state = true;

                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) => const SizedBox(
                                                  height: 300,
                                                  child:
                                                      ChooseSearchResultsAppointmentPreferencesScreen()),
                                            );
                                          },
                                        )
                                ],
                              ),
                            ),
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
                                    item.servicePackageDesc,
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
                                  const Icon(
                                      CupertinoIcons.money_rubl_circle_fill,
                                      color: tangerine),
                                  const SizedBox(width: secondarySizedBox),
                                  customTitleText(
                                      context, '₱${item.price.toString()}')
                                ],
                              ),
                            ),
                            const SizedBox(height: secondarySizedBox),

                            // Size display
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                children: [
                                  const Icon(Icons.monitor_weight,
                                      color: tangerine),
                                  const SizedBox(width: secondarySizedBox),
                                  customRegularWeightTitleText(context,
                                      'Size: ${item.size}, ${item.minWeight} - ${item.maxWeight} kg')
                                ],
                              ),
                            ),
                            const SizedBox(height: secondarySizedBox),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                children: [
                                  const Icon(CupertinoIcons.heart_fill,
                                      color: tangerine),
                                  const SizedBox(width: secondarySizedBox),
                                  customRegularWeightTitleText(
                                      context, 'For ${(petType).join(', ')}')
                                ],
                              ),
                            ),
                            const SizedBox(height: secondarySizedBox),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: secondarySizedBox),
                              child: Row(
                                children: [
                                  const Icon(Icons.home_repair_service,
                                      color: tangerine),
                                  const SizedBox(width: secondarySizedBox),
                                  customRegularWeightTitleText(context,
                                      '${(servicePackageType).join(', ')}')
                                ],
                              ),
                            ),
                            const SizedBox(height: secondarySizedBox),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FilledButton.icon(
                                  label: Text(
                                    isInCart
                                        ? 'Remove from cart'
                                        : 'Add to cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(0,
                                              0.2), // Horizontal and vertical offset
                                          blurRadius: 5.0, // Blur effect
                                          color: greyColor, // Shadow color
                                        ),
                                      ],
                                    ),
                                  ),
                                  icon: Icon(
                                    isInCart ? Icons.remove : Icons.add,
                                    color: Colors.white,
                                    size: 23,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0,
                                            0.2), // Horizontal and vertical offset
                                        blurRadius: 5.0, // Blur effect
                                        color: mediumGreyColor, // Shadow color
                                      ),
                                    ],
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStatePropertyAll<Color>(
                                        isInCart
                                            ? primaryColor
                                            : secondaryColor, // Uniform color for all states
                                      ),
                                      shape: WidgetStatePropertyAll<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              secondaryBorderRadius),
                                        ),
                                      )),
                                  onPressed: () {
                                    final cartNotifier =
                                        ref.read(cartNotifierProvider.notifier);

                                    if (itemType == "service") {
                                      final service = Service(
                                          serviceId: item.servicePackageId,
                                          serviceProviderServiceId: item
                                              .serviceProviderServicePackageId,
                                          serviceServiceProviderId: item.spId,
                                          serviceServiceProviderImage:
                                              item.spImage,
                                          serviceName: item.name,
                                          serviceDesc: item.servicePackageDesc,
                                          category: [item.categoryName],
                                          servicePrice: item.price,
                                          serviceImage: image,
                                          serviceType: servicePackageType,
                                          servicePetType: petType,
                                          serviceSize: item.size,
                                          minWeight: item.minWeight,
                                          maxWeight: item.maxWeight,
                                          serviceProviderNameOfService:
                                              item.spName);

                                      isInCart
                                          ? cartNotifier.removeService(service)
                                          : cartNotifier.addService(
                                              service, context);
                                    } else if (itemType == "package") {
                                      final package = Package(
                                          packageId: item.servicePackageId,
                                          serviceProviderPackageId: item
                                              .serviceProviderServicePackageId,
                                          packageServiceProviderId: item.spId,
                                          packageServiceProviderImage:
                                              item.spImage,
                                          packageName: item.name,
                                          packageDesc: item.servicePackageDesc,
                                          category: [item.categoryName],
                                          packagePrice: item.price,
                                          packageImage: image,
                                          packageType: servicePackageType,
                                          packagePetType: petType,
                                          packageSize: item.size,
                                          minWeight: item.minWeight,
                                          maxWeight: item.maxWeight,
                                          serviceProviderNameOfPackage:
                                              item.spName);

                                      isInCart
                                          ? cartNotifier.removePackage(package)
                                          : cartNotifier.addPackage(
                                              package, context);
                                    }
                                  },
                                ),
                              ],
                            )
                          ]),
                          const SizedBox(height: secondarySizedBox),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  slideUpRoute(ServiceproviderProfileScreen()));
                            },
                            child: Container(
                              height: 120,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: lighterGreyColor,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: primaryColor, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: tertiarySizedBox),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: lightGreyColor,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                        imageUrl: item.spImage.isEmpty ||
                                                item.spImage == ''
                                            ? 'https://tinyurl.com/357z4usj'
                                            : item.spImage,
                                        width: 90,
                                        height: 90,
                                        fit: item.spImage.isEmpty
                                            ? BoxFit.contain
                                            : BoxFit.cover,
                                        placeholder: (context, url) {
                                          print("Loading image...");
                                          return Center(
                                            child: // Image placeholder
                                                Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        errorWidget: (context, url, error) {
                                          print("Error loading image: $error");
                                          return const Icon(Icons.error,
                                              size: 48);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: tertiarySizedBox),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.spName,
                                          style: const TextStyle(
                                              fontSize: regularText,
                                              fontWeight: boldWeight,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: primarySizedBox),
                                        ratingWidget(
                                            spAvgRating!.toStringAsFixed(0)),
                                        const SizedBox(height: primarySizedBox),
                                        sentimentLabelTextWidget(
                                            spSentimentLabel)
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: primaryColor,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: tertiarySizedBox),
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
