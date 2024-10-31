import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_floating_action_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/regular_text.dart';
// import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
// import 'package:pamfurred/screens/cart_screen.dart';
import 'package:shimmer/shimmer.dart';

class ServiceproviderProfileScreen extends ConsumerStatefulWidget {
  const ServiceproviderProfileScreen({super.key});

  @override
  ConsumerState<ServiceproviderProfileScreen> createState() =>
      _ServiceproviderProfileScreenState();
}

class _ServiceproviderProfileScreenState
    extends ConsumerState<ServiceproviderProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);
    const defaultImage = 'https://tinyurl.com/3tnt6yyy';

    // Find the service provider with the matching sp_id
    final sp = ref.watch(spIndexProvider);

    // Check if sp is null or if sp_id is null
    if (sp == null || sp['sp_id'] == null) {
      return const Center(
        child: Text("Error."),
      ); // Return if sp or sp_id is null
    }

    final servicesTabProvider = FutureProvider<List<dynamic>>((ref) {
      final selectedServiceType = ref.watch(serviceTypeProvider);
      print(selectedServiceType);
      final selectedPetType = ref.watch(petTypeProvider);
      print(selectedPetType);
      final selectedServiceCategory =
          ref.watch(selectedServiceCategoryProvider);
      print(selectedServiceCategory);
      final allServicesAsync =
          ref.watch(allServicesProvider(sp['sp_id'].toString()));
      print(allServicesAsync);

      return allServicesAsync.when(
        data: (allServices) {
          return allServices.where((service) {
            final matchesPetType = selectedPetType == 'All' ||
                (service['pet_type'] is List &&
                    (service['pet_type'] as List).contains(selectedPetType));
            final matchesServiceCategory = selectedServiceCategory == 'All' ||
                (service['pet_category'] is List &&
                    (service['pet_category'] as List)
                        .contains(selectedServiceCategory));
            final matchesSelectedServiceType = selectedServiceType == 'All' ||
                (service['service_type_service'] is List &&
                    (service['service_type_service'] as List)
                        .contains(selectedServiceType));

            return matchesPetType &&
                matchesServiceCategory &&
                matchesSelectedServiceType;
          }).toList();
        },
        loading: () => [],
        error: (error, stackTrace) => [],
      );
    });

    final packagesTabProvider = FutureProvider<List<dynamic>>((ref) {
      final selectedPackageType = ref.watch(packageTypeProvider);
      final selectedPetTypePackage = ref.watch(petTypePackageProvider);
      final selectedPackageCategory =
          ref.watch(selectedPackageCategoryProvider);
      final allPackagesAsync =
          ref.watch(allPackagesProvider(sp['sp_id'].toString()));

      return allPackagesAsync.when(
        data: (allPackages) {
          return allPackages.where((package) {
            final matchesPetType = selectedPetTypePackage == 'All' ||
                (package['pet_type'] is List &&
                    (package['pet_type'] as List)
                        .contains(selectedPetTypePackage));
            final matchesPackageCategory = selectedPackageCategory == 'All' ||
                (package['category'] is List &&
                    (package['category'] as List)
                        .contains(selectedPackageCategory));
            final matchesSelectedPackageType = selectedPackageType == 'All' ||
                (package['package_type'] is List &&
                    (package['package_type'] as List)
                        .contains(selectedPackageType));

            return matchesPetType &&
                matchesPackageCategory &&
                matchesSelectedPackageType;
          }).toList();
        },
        loading: () => [],
        error: (error, stackTrace) => [],
      );
    });

    // Variable for service provider rating, checking null values
    final displayRating = sp['rating'];

    final spName = sp['name'] ?? 'N/A';

    // Cart services provider
    final cartServices = ref.watch(cartNotifierProvider);

    // Service and package bottomsheet options
    final serviceOptions = ref.watch(serviceOptionsProvider);

    final selectedServiceCategory =
        ref.watch(selectedServiceCategoryProvider); //Service category

    final selectedPackageCategory =
        ref.watch(selectedPackageCategoryProvider); // Package category

    final List<Widget> tabTitles = [
      Center(
        child: Text(
          "About",
          style: TextStyle(
              color: selectedIndex == 0 ? primaryColor : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: regularText),
        ),
      ),
      Center(
        child: Text(
          "Services",
          style: TextStyle(
              color: selectedIndex == 1 ? primaryColor : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: regularText),
        ),
      ),
      Center(
        child: Text(
          "Packages",
          style: TextStyle(
              color: selectedIndex == 2 ? primaryColor : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: regularText),
        ),
      ),
    ];

    final tabContents = FutureProvider<List<Widget>>((ref) {
      final data = [
        // About tab content
        Center(
          child: Column(
            children: [
              // This is temporary. Remove this when it's ensured that we don't take null addresses from service providers
              sp.isNotEmpty
                  ? spDetailsHeader(CupertinoIcons.location_solid, spName)
                  // spDetailsHeader(
                  //     CupertinoIcons.location_solid, sp['address'] ?? 'N/A')
                  : spDetailsHeader(CupertinoIcons.location_solid, 'N/A'),
              const SizedBox(height: secondarySizedBox),

              // Rating display logic (assuming 'displayRating' handles null internally)
              spDetailsHeader(Icons.star, displayRating),
              const SizedBox(height: secondarySizedBox),

              // spDetailsHeader(
              //     Icons.home_repair_service, sp['service_type'] ?? 'N/A'),
              // const SizedBox(height: secondarySizedBox),

              // spDetailsHeader(Icons.access_time_filled, sp['hours'] ?? 'N/A'),
              // const SizedBox(height: secondarySizedBox),

              // spDetailsHeader(Icons.call, sp['phone'] ?? 'N/A'),
              // const SizedBox(height: secondarySizedBox),

              // spDetailsHeader(Icons.pets, sp['pets_catered'] ?? 'N/A'),
              // const SizedBox(height: secondarySizedBox),
            ],
          ),
        ),
        // Services tab
        Center(
          child: ref.watch(servicesTabProvider).when(
                data: (filteredServices) {
                  if (filteredServices.isEmpty) {
                    return const Center(child: Text("No services available"));
                  }
                  return SizedBox(
                    height: getScreenHeight(context) - 395,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Replace dropdown with button to show modal bottom sheet
                            Container(
                              width: 250,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                  border: Border.all(
                                      width: 0.5, color: primaryColor)),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 230,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                    tertiaryBorderRadius),
                                                topRight: Radius.circular(
                                                    tertiaryBorderRadius)),
                                            color: lighterGreyColor,
                                          ),
                                          child: ListView.builder(
                                            itemCount: serviceOptions.length,
                                            itemBuilder: (context, index) {
                                              final option =
                                                  serviceOptions[index];
                                              return ListTile(
                                                title: Text(option),
                                                onTap: () {
                                                  ref
                                                      .read(
                                                          selectedServiceCategoryProvider
                                                              .notifier)
                                                      .state = option;
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedServiceCategory,
                                        style: const TextStyle(
                                            fontSize: regularText),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 230,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          customTitleText(context, 'Pet Type'),
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          Flexible(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis
                                                  .horizontal, // Enable horizontal scrolling
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  CustomRadioButton(
                                                    autoWidth: true,
                                                    buttonLables: const [
                                                      'All',
                                                      'Dog',
                                                      'Cat',
                                                      'Rabbit',
                                                    ],
                                                    buttonValues: const [
                                                      'All',
                                                      'Dog',
                                                      'Cat',
                                                      'Rabbit',
                                                    ],
                                                    radioButtonValue: (value) =>
                                                        // Updating pet type
                                                        {
                                                      ref
                                                          .read(petTypeProvider
                                                              .notifier)
                                                          .updatePetType(value)
                                                    },
                                                    defaultSelected: ref
                                                        .watch(petTypeProvider),
                                                    selectedColor: primaryColor,
                                                    unSelectedColor:
                                                        Colors.transparent,
                                                    elevation: 0,
                                                    enableShape: true,
                                                    buttonTextStyle:
                                                        const ButtonTextStyle(
                                                            textStyle: TextStyle(
                                                                fontSize:
                                                                    regularText)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          customTitleText(
                                              context, 'Service Type'),
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          Flexible(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis
                                                  .horizontal, // Enable horizontal scrolling
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  CustomRadioButton(
                                                    autoWidth: true,
                                                    buttonLables: const [
                                                      'All',
                                                      'Home service',
                                                      'In-clinic',
                                                    ],
                                                    buttonValues: const [
                                                      'All',
                                                      'Home service',
                                                      'In-clinic',
                                                    ],
                                                    radioButtonValue: (value) =>
                                                        // Updating service type
                                                        {
                                                      ref
                                                          .read(
                                                              serviceTypeProvider
                                                                  .notifier)
                                                          .updateServiceType(
                                                              value)
                                                    },
                                                    defaultSelected: ref.watch(
                                                        serviceTypeProvider),
                                                    selectedColor: primaryColor,
                                                    unSelectedColor:
                                                        Colors.transparent,
                                                    elevation: 0,
                                                    enableShape: true,
                                                    buttonTextStyle:
                                                        const ButtonTextStyle(
                                                            textStyle: TextStyle(
                                                                fontSize:
                                                                    regularText)),
                                                    width: 150,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.filter_list,
                                color: primaryColor,
                                size: 25,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: tertiarySizedBox,
                        ),
                        filteredServices.isEmpty
                            ? const Center(
                                child: Text("No services available"),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: filteredServices.length,
                                  itemBuilder: (context, index) {
                                    // Get the current service from the filtered list
                                    final service = filteredServices[index];
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
                                              service.image,
                                              width: 90,
                                              height: 85,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child; // Image loaded successfully
                                                } else {
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      width: 90,
                                                      height: 85,
                                                      color: Colors.grey[300],
                                                    ),
                                                  ); // Shimmer effect while loading
                                                }
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 90,
                                                  height: 85,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.error,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  tertiarySizedBox), // Adjust spacing as needed
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                customTitleText(
                                                    context, service.name),
                                                Text('₱${service.price}'),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 37,
                                            child: Center(
                                              child: CircleAvatar(
                                                backgroundColor: secondaryColor,
                                                // Check if the service is already in the cart by comparing its ID
                                                child: cartServices.any(
                                                        (cartService) =>
                                                            cartService.id ==
                                                            service.id)
                                                    ? IconButton(
                                                        icon: const Icon(
                                                          Icons.remove,
                                                          color: Colors.white,
                                                          size: 23,
                                                        ),
                                                        onPressed: () {
                                                          // Remove the service using its ID
                                                          ref
                                                              .read(
                                                                  cartNotifierProvider
                                                                      .notifier)
                                                              .removeService(
                                                                  service
                                                                      as Service);
                                                        },
                                                      )
                                                    : IconButton(
                                                        icon: const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 23,
                                                        ),
                                                        onPressed: () {
                                                          // Add the service using its ID
                                                          ref
                                                              .read(
                                                                  cartNotifierProvider
                                                                      .notifier)
                                                              .addService(service
                                                                  as Service);
                                                        },
                                                      ),
                                              ),
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
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    const Center(child: Text("Error loading services")),
              ),
        ),
        // Packages tab content
        Center(
          child: ref.watch(packagesTabProvider).when(
                data: (filteredPackages) {
                  if (filteredPackages.isEmpty) {
                    return const Center(child: Text("No packages available"));
                  }
                  return SizedBox(
                    height: getScreenHeight(context) - 395,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Replace dropdown with button to show modal bottom sheet
                            Container(
                              width: 250,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                  border: Border.all(
                                      width: 0.5, color: primaryColor)),
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 230,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                    tertiaryBorderRadius),
                                                topRight: Radius.circular(
                                                    tertiaryBorderRadius)),
                                            color: lighterGreyColor,
                                          ),
                                          child: ListView.builder(
                                            itemCount: serviceOptions.length,
                                            itemBuilder: (context, index) {
                                              final option =
                                                  serviceOptions[index];
                                              return ListTile(
                                                title: Text(option),
                                                onTap: () {
                                                  ref
                                                      .read(
                                                          selectedPackageCategoryProvider
                                                              .notifier)
                                                      .state = option;
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedPackageCategory,
                                        style: const TextStyle(
                                            fontSize: regularText),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 230,
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          customTitleText(context, 'Pet Type'),
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          Flexible(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis
                                                  .horizontal, // Enable horizontal scrolling
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  CustomRadioButton(
                                                    autoWidth: true,
                                                    buttonLables: const [
                                                      'All',
                                                      'Dog',
                                                      'Cat',
                                                      'Rabbit',
                                                    ],
                                                    buttonValues: const [
                                                      'All',
                                                      'Dog',
                                                      'Cat',
                                                      'Rabbit',
                                                    ],
                                                    radioButtonValue: (value) =>
                                                        // Updating pet type
                                                        {
                                                      ref
                                                          .read(
                                                              petTypePackageProvider
                                                                  .notifier)
                                                          .updatePetTypePackage(
                                                              value)
                                                    },
                                                    defaultSelected: ref.watch(
                                                        petTypePackageProvider),
                                                    selectedColor: primaryColor,
                                                    unSelectedColor:
                                                        Colors.transparent,
                                                    elevation: 0,
                                                    enableShape: true,
                                                    buttonTextStyle:
                                                        const ButtonTextStyle(
                                                            textStyle: TextStyle(
                                                                fontSize:
                                                                    regularText)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          customTitleText(
                                              context, 'Service Type'),
                                          const SizedBox(
                                              height: secondarySizedBox),
                                          Flexible(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis
                                                  .horizontal, // Enable horizontal scrolling
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  CustomRadioButton(
                                                    autoWidth: true,
                                                    buttonLables: const [
                                                      'All',
                                                      'Home service',
                                                      'In-clinic',
                                                    ],
                                                    buttonValues: const [
                                                      'All',
                                                      'Home service',
                                                      'In-clinic',
                                                    ],
                                                    radioButtonValue: (value) =>
                                                        // Updating service type
                                                        {
                                                      ref
                                                          .read(
                                                              packageTypeProvider
                                                                  .notifier)
                                                          .updatePackageType(
                                                              value)
                                                    },
                                                    defaultSelected: ref.watch(
                                                        serviceTypeProvider),
                                                    selectedColor: primaryColor,
                                                    unSelectedColor:
                                                        Colors.transparent,
                                                    elevation: 0,
                                                    enableShape: true,
                                                    buttonTextStyle:
                                                        const ButtonTextStyle(
                                                            textStyle: TextStyle(
                                                                fontSize:
                                                                    regularText)),
                                                    width: 150,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.filter_list,
                                color: primaryColor,
                                size: 25,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: tertiarySizedBox,
                        ),
                        filteredPackages.isEmpty
                            ? const Center(
                                child: Text("No packages available"),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: filteredPackages.length,
                                  itemBuilder: (context, index) {
                                    final package = filteredPackages[index];
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
                                              package.image,
                                              width: 90,
                                              height: 85,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child; // Image loaded successfully
                                                } else {
                                                  return Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      width: 90,
                                                      height: 85,
                                                      color: Colors.grey[300],
                                                    ),
                                                  ); // Shimmer effect while loading
                                                }
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 90,
                                                  height: 85,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.error,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  tertiarySizedBox), // Adjust spacing as needed
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                customTitleText(
                                                    context, package.name),
                                                Text('₱${package.price}'),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 37,
                                            child: Center(
                                              child: CircleAvatar(
                                                backgroundColor: secondaryColor,
                                                // Check if the service is already in the cart by comparing its ID
                                                child: cartServices.any(
                                                        (cartPackage) =>
                                                            cartPackage.id ==
                                                            package.id)
                                                    ? IconButton(
                                                        icon: const Icon(
                                                          Icons.remove,
                                                          color: Colors.white,
                                                          size: 23,
                                                        ),
                                                        onPressed: () {
                                                          // Remove the service using its ID
                                                          ref
                                                              .read(
                                                                  cartNotifierProvider
                                                                      .notifier)
                                                              .removePackage(
                                                                  package);
                                                        },
                                                      )
                                                    : IconButton(
                                                        icon: const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 23,
                                                        ),
                                                        onPressed: () {
                                                          // Add the service using its ID
                                                          ref
                                                              .read(
                                                                  cartNotifierProvider
                                                                      .notifier)
                                                              .addPackage(
                                                                  package);
                                                        },
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    const Center(child: Text("Error loading packages")),
              ),
        ),
      ];
      return data;
    });

    final asyncTabContent = ref.watch(tabContents);

    // Use `.asData` to get the length safely if data is available
    final length = asyncTabContent.asData?.value.length ?? 3;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: customFloatingActionButton(context,
          buttonText: 'Book appointment', onPressed: () {
        // Navigator.push(context, slideUpRoute(const CartScreen()));
      }),
      body: Center(
        child: Column(
          children: [
            Image.network(
              sp['image'],
              width: double.infinity,
              height: 200,
              fit: sp['image'] == defaultImage ? BoxFit.contain : BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                    ),
                  ); // Shimmer effect while loading
                }
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  color: lighterGreyColor,
                  width: double.infinity,
                  height: 200,
                  child: const Center(
                    child: Icon(
                      Icons.error,
                    ),
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
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(length, (index) {
                          return GestureDetector(
                            onTap: () => ref
                                .read(selectedTabProvider.notifier)
                                .state = index,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: primarySizedBox),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      quaternaryBorderRadius),
                                  color: selectedIndex == index
                                      ? lighterSecondaryColor
                                      : const Color.fromARGB(0, 100, 54, 54),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: tabTitles[index]),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: tertiarySizedBox),
                      Consumer(
                        builder: (context, ref, _) {
                          return asyncTabContent.when(
                            data: (widgetlist) {
                              if (widgetlist.isEmpty) {
                                return const Center(
                                    child: Text('No content available'));
                              }
                              return SizedBox(
                                height: getScreenHeight(context) -
                                    395, // Adjust this value as needed
                                child: ListView(
                                  children: widgetlist,
                                ),
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stack) => Center(
                                child: Text('Error loading content: $error')),
                          );
                        },
                      ),

                      // tabContents[selectedIndex],
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: primarySizedBox),
          ],
        ),
      ),
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
}
