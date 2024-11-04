// import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/cart_icon.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/providers/button_pressed_provider.dart';
import 'package:pamfurred/providers/cart_provider.dart';
// import 'package:pamfurred/models/services.dart';
// import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:pamfurred/screens/cart_screen.dart';
// import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

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

  // Variable for service provider rating, checking null values
  final displayRating = sp?['rating'].toString();

  // Ensure 'service_type' is a List<String>
  List<String> serviceTypes = List<String>.from(sp?['service_type'] ?? []);

  // Ensure 'pets_catered' is a List<String>
  List<String> petsCatered = List<String>.from(sp?['pets_catered'] ?? []);

  final timeOpen = sp?['time_open'];

  final timeClose = sp?['time_close'];

  return [
    // About tab content
    Center(
      child: sp!.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // This is temporary. Remove this when it's ensured that we don't take null addresses from service providers
                sp.isNotEmpty
                    ? spDetailsHeader(
                        CupertinoIcons.location_solid, sp['address'] ?? 'N/A')
                    : spDetailsHeader(CupertinoIcons.location_solid, 'N/A'),
                const SizedBox(height: secondarySizedBox),

                // Rating display logic (assuming 'displayRating' handles null internally)
                spDetailsHeader(Icons.star, displayRating!),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(
                  Icons.home_repair_service,
                  serviceTypes.join(', '),
                ),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(Icons.access_time_filled,
                    'Opens from ${formatTime(timeOpen)} to ${formatTime(timeClose)}'),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(Icons.call, sp['phone_number'] ?? 'N/A'),
                const SizedBox(height: secondarySizedBox),

                spDetailsHeader(Icons.pets, 'Caters ${petsCatered.join(', ')}'),
                const SizedBox(height: secondarySizedBox),
              ],
            ),
    ),
  ];
});

String formatTime(String timeString) {
  // Parse the time string into a DateTime object
  final timeParts = timeString.split(':');
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);

  // Create a DateTime object (using a default date since we only care about time)
  final dateTime = DateTime(0, 1, 1, hour, minute);

  // Format it to a readable string (e.g., "8 AM" or "5 PM")
  return DateFormat.jm().format(dateTime); // "j" for hour (1-12), "a" for AM/PM
}

final servicesTabProvider = FutureProvider<List<Widget>>((ref) async {
  // Retrieve the service provider ID
  final sp = ref.watch(spIndexProvider);

  // Define filter criteria
  final filterCriteria = ServiceFilterCriteria(
    spId: sp!['sp_id'].toString(),
    petType: null,
    serviceType: null,
    size: null,
  );

  // Use `allServicesProvider` with `.when` in your UI instead of in the provider body
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
                  const SizedBox(height: tertiarySizedBox),
                  servicesList.isEmpty
                      ? const Center(
                          child: Text("No services available"),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: servicesList.length,
                            itemBuilder: (context, index) {
                              Service fromMap(Map<String, dynamic> map) {
                                return Service(
                                  serviceServiceProviderId:
                                      map['sp_id'] as String? ?? '',
                                  serviceId: map['service_id'] as String? ?? '',
                                  serviceName:
                                      map['service_name'] as String? ?? '',
                                  category:
                                      map['service_category'] is List<dynamic>
                                          ? List<String>.from(
                                              map['service_category']
                                                  as List<dynamic>)
                                          : [],
                                  servicePrice: map['price'] as int? ?? 0,
                                  serviceImage:
                                      map['service_image'] as String? ?? '',
                                  serviceType: map['service_type']
                                          is List<dynamic>
                                      ? List<String>.from(
                                          map['service_type'] as List<dynamic>)
                                      : [],
                                  petType: map['pet_type'] is List<dynamic>
                                      ? List<String>.from(
                                          map['pet_type'] as List<dynamic>)
                                      : [],
                                  serviceSize: map['size'] as String? ?? '',
                                );
                              }

                              final serviceMap = servicesList[index];
                              final service = fromMap(serviceMap);

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
                                                  context, service.serviceName),
                                              Row(
                                                children: [
                                                  regularTextWidget(
                                                      service.serviceSize),
                                                  regularPrimaryColoredTextWidget(
                                                      ' • '),
                                                  Text(
                                                      '₱${service.servicePrice}'),
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

  // Use `allOacakgesProvider` with `.when` in your UI instead of in the provider body
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
                  const SizedBox(height: tertiarySizedBox),
                  packagesList.isEmpty
                      ? const Center(
                          child: Text("No services available"),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: packagesList.length,
                            itemBuilder: (context, index) {
                              Package fromMap(Map<String, dynamic> map) {
                                return Package(
                                    packageServiceProviderId:
                                        map['sp_id'] as String? ?? '',
                                    packageId:
                                        map['package_id'] as String? ?? '',
                                    packageName:
                                        map['package_name'] as String? ?? '',
                                    category: map['package_category'] is List<dynamic>
                                        ? List<String>.from(
                                            map['package_category']
                                                as List<dynamic>)
                                        : [],
                                    packagePrice: map['price'] as int? ?? 0,
                                    packageImage:
                                        map['package_image'] as String? ?? '',
                                    packageType: map['package_type'] is List<dynamic>
                                        ? List<String>.from(map['package_type']
                                            as List<dynamic>)
                                        : [],
                                    petType: map['pet_type'] is List<dynamic>
                                        ? List<String>.from(
                                            map['pet_type'] as List<dynamic>)
                                        : [],
                                    packageSize: map['size'] as String? ?? '');
                              }

                              final packageMap = packagesList[index];
                              final package = fromMap(packageMap);

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
                                                  context, package.packageName),
                                              Row(
                                                children: [
                                                  regularTextWidget(
                                                      (package.packageSize)),
                                                  regularPrimaryColoredTextWidget(
                                                      ' • '),
                                                  Text(
                                                      '₱${package.packagePrice}'),
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
                                                      .setPressed(
                                                          true); // Set pressed state
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
      appBar: customAppBarWithTitle(context, sp['name']),
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
                const CartIcon(),
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
                sp['image'] ?? defaultImage,
                width: double.infinity,
                height: 200,
                fit:
                    sp['image'] == defaultImage ? BoxFit.contain : BoxFit.cover,
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
                    customTitleText(context, sp['name']),
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
                        height: getScreenHeight(context) - 395,
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
