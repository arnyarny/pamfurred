// import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/cart_icon.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/providers/button_pressed_provider.dart';
import 'package:pamfurred/providers/cart_provider.dart';
// import 'package:pamfurred/models/services.dart';
// import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/screens/appointment/cart_screen.dart';
// import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:shimmer/shimmer.dart';

class ServiceproviderProfileScreen extends ConsumerStatefulWidget {
  const ServiceproviderProfileScreen({super.key});

  @override
  ConsumerState<ServiceproviderProfileScreen> createState() =>
      ServiceproviderProfileScreenState();
}

// Define providers for each tab’s content
final aboutTabProvider = FutureProvider<List<Widget>>((ref) async {
  // Retrieve the service provider ID
  final sp = ref.watch(spIndexProvider);

  print('SP ID: ${sp?['sp_id']}');

  // Pet owner user ID
  String userId = ref.watch(userIdProvider).toString();

  // Variable for service provider rating, checking null values
  final displayRating = (sp?['average_rating'] as double).toStringAsFixed(1);

  // Ensure 'service_type' is a List<String>
  List<String> serviceTypes =
      List<String>.from(sp?['unique_package_service_types'] ?? []);

  // Ensure 'pets_catered' is a List<String>
  List<String> petsCatered = List<String>.from(sp?['unique_pet_types'] ?? []);

  final timeOpen = sp?['time_open'];

  final timeClose = sp?['time_close'];

  double latitude = sp?['latitude'];
  double longitude = sp?['longitude'];

  String fullAddress = sp?['full_address'];

  return [
    // About tab content
    Center(
      child: sp!.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                spSentimentLabelHeader(CupertinoIcons.text_bubble,
                    sentimentLabelTextWidget(sp['sentiment_label'])),
                const SizedBox(height: secondarySizedBox),

                spDistanceDetailsHeader(
                  CupertinoIcons.location,
                  FutureBuilder<String?>(
                    future: getDistanceToTarget(userId, latitude, longitude),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return regularTextWidget(
                            'Error: ${snapshot.error}'); // Display error message if there's an error
                      } else if (snapshot.hasData) {
                        // Check if the data is not null
                        return regularTextWidget(snapshot.data ??
                            'Distance not available'); // Display the calculated distance
                      } else {
                        return regularTextWidget(
                            ''); // Handle the case where there is no data
                      }
                    },
                  ),
                ),
                const SizedBox(height: secondarySizedBox),

                // This is temporary. Remove this when it's ensured that we don't take null addresses from service providers
                sp.isNotEmpty
                    ? spDetailsHeader(Icons.location_on_outlined, fullAddress)
                    : spDetailsHeader(CupertinoIcons.location_solid, 'N/A'),
                const SizedBox(height: secondarySizedBox),

                // Rating display logic (assuming 'displayRating' handles null internally)
                spDetailsHeader(Icons.star_border, displayRating!),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(
                  Icons.home_repair_service_outlined,
                  serviceTypes.join(', '),
                ),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(Icons.access_time,
                    'Opens from ${formatTime(timeOpen)} to ${formatTime(timeClose)}'),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(
                    Icons.call_outlined, sp['phone_number'] ?? 'N/A'),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(
                    CupertinoIcons.heart, 'Caters ${petsCatered.join(', ')}'),
                const SizedBox(height: secondarySizedBox),
              ],
            ),
    ),
  ];
});

final servicesTabProvider = FutureProvider<List<Widget>>((ref) async {
  // Retrieve the service provider ID
  final sp = ref.watch(spIndexProvider);
  // Access user ID
  final userId = ref.watch(userIdProvider);

  // Access the list of pet profiles
  final petProfileData = ref.watch(petProfileProvider(userId!));

  // Define filter criteria
  final filterCriteria = ServiceFilterCriteria(
    spId: sp?['sp_id'].toString() ?? '',
    petType: null,
    serviceType: null,
    size: null,
  );

  return [
    Consumer(
      builder: (context, ref, child) {
        final allServices = ref.watch(allServicesProvider(filterCriteria));

        return Center(
          child: SizedBox(
            height: getScreenHeight(context),
            child: allServices.when(
              data: (servicesList) => Column(
                children: [
                  // const SizedBox(height: tertiarySizedBox),
                  servicesList.isEmpty
                      ? const Center(child: Text("No services available"))
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: servicesList.length,
                            itemBuilder: (context, index) {
                              final service = servicesList[index];

                              return Consumer(
                                builder: (context, ref, child) {
                                  final cartServices =
                                      ref.watch(cartNotifierProvider);
                                  final isInCart = cartServices.any(
                                      (cartService) =>
                                          cartService.id == service.serviceId);

                                  return Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          primaryBorderRadius),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              primaryBorderRadius),
                                          child: Image.network(
                                            service.serviceImage,
                                            width: 90,
                                            height: 85,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    width: 90,
                                                    height: 85,
                                                    color: Colors.grey[300],
                                                  ),
                                                );
                                              }
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 90,
                                                height: 85,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: tertiarySizedBox),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              customTitleText(
                                                  context,
                                                  capitalizeFirstLetter(
                                                      service.serviceName)),
                                              Row(
                                                children: [
                                                  regularTextWidget(
                                                      service.serviceSize),
                                                  regularPrimaryColoredTextWidget(
                                                      ' • '),
                                                  Text(
                                                      '₱${service.servicePrice}')
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 37,
                                          child: Center(
                                            child: CircleAvatar(
                                              backgroundColor: isInCart
                                                  ? Colors.red
                                                  : secondaryColor,
                                              child: GestureDetector(
                                                onTap: () {
                                                  ref
                                                      .read(
                                                          buttonPressedProvider
                                                              .notifier)
                                                      .setPressed(true);
                                                },
                                                child: IconButton(
                                                  icon: Icon(
                                                    isInCart
                                                        ? Icons.remove
                                                        : Icons.add,
                                                    color: Colors.white,
                                                    size: 23,
                                                  ),
                                                  onPressed: () {
                                                    final cartNotifier =
                                                        ref.read(
                                                            cartNotifierProvider
                                                                .notifier);
                                                    isInCart
                                                        ? cartNotifier
                                                            .removeService(
                                                                service)
                                                        : cartNotifier
                                                            .addService(
                                                                service);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ],
              ),
              loading: () => Center(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: const CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        );
      },
    ),
  ];
});

final packagesTabProvider = FutureProvider<List<Widget>>((ref) async {
  // Retrieve the service provider ID
  final sp = ref.watch(spIndexProvider);

  if (sp == null) {
    return [const Center(child: Text("No provider ID available"))];
  }

  // Define filter criteria
  final filterCriteria = PackageFilterCriteria(
    spId: sp['sp_id'].toString(),
    petType: null,
    packageType: null,
    size: null,
  );

  return [
    Consumer(
      builder: (context, ref, child) {
        final allPackages = ref.watch(allPackagesProvider(filterCriteria));

        return Center(
          child: SizedBox(
            height: getScreenHeight(context),
            child: allPackages.when(
              data: (packagesList) => Column(
                children: [
                  // const SizedBox(height: tertiarySizedBox),
                  packagesList.isEmpty
                      ? const Center(child: Text("No services available"))
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: packagesList.length,
                            itemBuilder: (context, index) {
                              final package = packagesList[index];

                              return Consumer(
                                builder: (context, ref, child) {
                                  final cartServices =
                                      ref.watch(cartNotifierProvider);
                                  final isInCart = cartServices.any(
                                      (cartService) =>
                                          cartService.id == package.packageId);

                                  return Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          primaryBorderRadius),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              primaryBorderRadius),
                                          child: Image.network(
                                            package.packageImage,
                                            width: 90,
                                            height: 85,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              } else {
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
                                                  highlightColor:
                                                      Colors.grey[100]!,
                                                  child: Container(
                                                    width: 90,
                                                    height: 85,
                                                    color: Colors.grey[300],
                                                  ),
                                                );
                                              }
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 90,
                                                height: 85,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: tertiarySizedBox),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              customTitleText(
                                                  context,
                                                  capitalizeFirstLetter(
                                                      package.packageName)),
                                              Row(
                                                children: [
                                                  regularTextWidget(
                                                      package.packageSize),
                                                  regularPrimaryColoredTextWidget(
                                                      ' • '),
                                                  Text(
                                                      '₱${package.packagePrice}')
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 37,
                                          child: Center(
                                            child: CircleAvatar(
                                              backgroundColor: isInCart
                                                  ? Colors.red
                                                  : secondaryColor,
                                              child: GestureDetector(
                                                onTap: () {
                                                  ref
                                                      .read(
                                                          buttonPressedProvider
                                                              .notifier)
                                                      .setPressed(true);
                                                },
                                                child: IconButton(
                                                  icon: Icon(
                                                    isInCart
                                                        ? Icons.remove
                                                        : Icons.add,
                                                    color: Colors.white,
                                                    size: 23,
                                                  ),
                                                  onPressed: () {
                                                    final cartNotifier =
                                                        ref.read(
                                                            cartNotifierProvider
                                                                .notifier);
                                                    isInCart
                                                        ? cartNotifier
                                                            .removePackage(
                                                                package)
                                                        : cartNotifier
                                                            .addPackage(
                                                                package);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ],
              ),
              loading: () => Center(
                child: Container(
                  color: Colors.white, // White background
                  padding: const EdgeInsets.all(16.0), // Optional padding
                  child: const CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        );
      },
    ),
  ];
});

class ServiceproviderProfileScreenState
    extends ConsumerState<ServiceproviderProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider).toInt();
    const defaultImage = 'https://tinyurl.com/3tnt6yyy';

    final sp = ref.watch(spIndexProvider);

    // Return a loading indicator with a white background if sp is null
    if (sp == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Define tabs titles as static widgets
    final List<Widget> tabTitles = [
      Center(
        child: Text("About", style: _getTabTextStyle(selectedIndex == 0)),
      ),
      Center(
        child: Text("Services", style: _getTabTextStyle(selectedIndex == 1)),
      ),
      Center(
        child: Text("Packages", style: _getTabTextStyle(selectedIndex == 2)),
      ),
    ];

    // Watch each tab’s provider based on selectedIndex
    final asyncTabContent = selectedIndex == 0
        ? ref.watch(aboutTabProvider)
        : selectedIndex == 1
            ? ref.watch(servicesTabProvider)
            : ref.watch(packagesTabProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBarWithTitle(context, sp['service_provider_name']),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          // Navigator.push(context, slideUpRoute(const SuccessfulAppointment()));
          Navigator.push(context, slideUpRoute(const CartScreen()));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(secondaryBorderRadius),
            border: Border.all(width: 0.5, color: primaryColor),
            color: primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.only(
                left: tertiarySizedBox, right: primarySizedBox),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CartIcon(
                  iconColor: lighterSecondaryColor,
                  borderColor: Colors.white,
                  badgeColor: Colors.black,
                ),
                TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, slideUpRoute(const CartScreen()));
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white,
                    ),
                    iconAlignment: IconAlignment.end,
                    label: const Text(
                      'Book appointment',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: regularText,
                          fontWeight: regularWeight),
                    )),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Image.network(
                sp['service_provider_image'] ?? defaultImage,
                width: double.infinity,
                height: 200,
                fit: sp['service_provider_image'] == defaultImage
                    ? BoxFit.contain
                    : BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  return loadingProgress == null
                      ? child
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                          ),
                        );
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Container(
                    color: lighterGreyColor,
                    width: double.infinity,
                    height: 200,
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  );
                },
              ),
              SizedBox(
                width: screenPadding(context),
                child: Column(
                  children: [
                    const SizedBox(height: tertiarySizedBox),
                    customTitleText(context, sp['service_provider_name']),
                    const SizedBox(height: secondarySizedBox),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(tabTitles.length, (index) {
                        return GestureDetector(
                          onTap: () => ref
                              .read(selectedTabProvider.notifier)
                              .state = index.toInt(),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: primarySizedBox),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(quaternaryBorderRadius),
                              color: selectedIndex == index
                                  ? lighterSecondaryColor
                                  : Colors.transparent,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: tabTitles[index],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: tertiarySizedBox),
                    asyncTabContent.when(
                      data: (widgetList) => SizedBox(
                        height: getScreenHeight(context),
                        child: ListView(
                          children: widgetList,
                        ),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) {
                        return const Text('');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: primarySizedBox),
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle _getTabTextStyle(bool isSelected) {
  return TextStyle(
    color: isSelected ? primaryColor : Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: regularText,
  );
}

Widget spDetailsHeader(IconData icon, String detail) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 26, 10, 10)),
          const SizedBox(width: secondarySizedBox),
          regularTextWidget(detail),
        ],
      ),
      const SizedBox(height: secondarySizedBox),
    ],
  );
}

Widget spDistanceDetailsHeader(IconData icon, Widget distanceFutureBuilder) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 26, 10, 10)),
          const SizedBox(width: secondarySizedBox),
          distanceFutureBuilder,
        ],
      ),
      const SizedBox(height: secondarySizedBox),
    ],
  );
}

spSentimentLabelHeader(IconData icon, Widget sentimentLabelTextWidget) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 26, 10, 10)),
          const SizedBox(width: secondarySizedBox),
          sentimentLabelTextWidget
        ],
      ),
      const SizedBox(height: secondarySizedBox),
    ],
  );
}
