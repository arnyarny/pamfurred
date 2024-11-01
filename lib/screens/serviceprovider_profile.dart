// import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_floating_action_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
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
      _ServiceproviderProfileScreenState();
}

// Define providers for each tab’s content
final aboutTabProvider = FutureProvider<List<Widget>>((ref) async {
  // Retrieve the service provider ID
  final sp = ref.watch(spIndexProvider);

  // Variable for service provider rating, checking null values
  final displayRating = sp!['rating'].toString();

  // Ensure 'service_type' is a List<String>
  List<String> serviceTypes = List<String>.from(sp['service_type'] ?? []);

  // Ensure 'pets_catered' is a List<String>
  List<String> petsCatered = List<String>.from(sp['pets_catered'] ?? []);

  final timeOpen = sp['time_open'];

  final timeClose = sp['time_close'];

  return [
    // About tab content
    Center(
      child: sp.isEmpty
          ? const CircularProgressIndicator(
              value: 2,
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
                spDetailsHeader(Icons.star, displayRating),
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

final servicesTabProvider = FutureProvider<List<Widget>>((ref) {
  // Retrieve the service provider ID
  final sp = ref.watch(spIndexProvider);
  final allServices = ref.watch(allServicesProvider(sp!['sp_id']));

  return [
    Center(
      child: SizedBox(
        height: 915 - 395,
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
                              serviceId: map['service_id'] as String? ?? '',
                              serviceName: map['service_name'] as String? ?? '',
                              category: map['category'] as String? ?? '',
                              servicePrice: map['price'] as int? ?? 0,
                              serviceImage: map['service_image'],
                              serviceType: (map['service_type'] is List)
                                  ? List<String>.from(map['service_type'])
                                  : [],
                              petType: (map['pet_type'] is List)
                                  ? List<String>.from(map['pet_type'])
                                  : [],
                            );
                          }

                          final serviceMap = servicesList[index];
                          final service = fromMap(serviceMap);

                          return Consumer(
                            builder: (context, watch, child) {
                              final cartServices =
                                  ref.watch(cartNotifierProvider);
                              final isInCart = cartServices.any((cartService) =>
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
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          } else {
                                            return Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
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
                                          Text('₱${service.servicePrice}'),
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
                                                  .read(buttonPressedProvider
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
                                                final cartNotifier = ref.read(
                                                    cartNotifierProvider
                                                        .notifier);
                                                isInCart
                                                    ? cartNotifier
                                                        .removeService(service)
                                                    : cartNotifier
                                                        .addService(service);
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    ),
  ];
});

final packagesTabProvider = FutureProvider<List<Widget>>((ref) async {
  // Retrieve the service provider ID
  final sp = ref.watch(spIndexProvider);
  final allServices = ref.watch(allPackagesProvider(sp!['sp_id']));

  return [
    Center(
      child: SizedBox(
        height: 915 - 395,
        child: allServices.when(
          data: (servicesList) => Column(
            children: [
              const SizedBox(height: tertiarySizedBox),
              servicesList.isEmpty
                  ? const Center(
                      child: Text("No packages available"),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: servicesList.length,
                        // Inside your ListView.builder
                        itemBuilder: (context, index) {
                          final service = servicesList[index];

                          // Temporary. The DB should require a package name and its price
                          final packageName = service['package_name'] ??
                              'N/A'; // Default value
                          final price = service['price'] ??
                              0;

                          return Card(
                            color: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(primaryBorderRadius),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      primaryBorderRadius),
                                  child: Image.network(
                                    service['package_image'] ??
                                        '', // Use an empty string or placeholder image for null
                                    width: 90,
                                    height: 85,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child; // Image loaded successfully
                                      } else {
                                        return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 90,
                                              height: 85,
                                              color: Colors.grey[300],
                                            )); // Shimmer effect while loading
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
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
                                      customTitleText(context, packageName),
                                      Text(
                                          '₱$price'), // Displaying price safely
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    )
  ];
});

class _ServiceproviderProfileScreenState
    extends ConsumerState<ServiceproviderProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider).toInt();
    const defaultImage = 'https://tinyurl.com/3tnt6yyy';

    final sp = ref.watch(spIndexProvider);

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
      appBar: customAppBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: customFloatingActionButton(context,
          buttonText: 'Book appointment', onPressed: () {
        Navigator.push(context, slideUpRoute(const CartScreen()));
      }),
      body: Center(
        child: Column(
          children: [
            if (sp != null)
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
                  if (sp != null) customTitleText(context, sp['name']),
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
                      height:
                          getScreenHeight(context) - 395, // Adjust as needed
                      child: ListView(
                        children: widgetList,
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) {
                      debugPrint('Error loading content: $error');
                      return Center(
                          child: Text('Error loading content: $error'));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: primarySizedBox),
          ],
        ),
      ),
    );
  }

  TextStyle _getTabTextStyle(bool isSelected) {
    return TextStyle(
      color: isSelected ? primaryColor : Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: regularText,
    );
  }
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
