// import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pamfurred/components/custom_appbar.dart';
// import 'package:pamfurred/components/custom_floating_action_button.dart';
// import 'package:pamfurred/components/globals.dart';
// import 'package:pamfurred/components/regular_text.dart';
// import 'package:pamfurred/components/screen_transitions.dart';
// import 'package:pamfurred/components/title_text.dart';
// import 'package:pamfurred/providers/cart_provider.dart';
// import 'package:pamfurred/providers/global_providers.dart';
// import 'package:pamfurred/providers/serviceprovider_provider.dart';
// import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
// import 'package:pamfurred/providers/sp_profile_provider_services.dart';
// import 'package:pamfurred/screens/cart_screen.dart';
// import 'package:shimmer/shimmer.dart';

// class ServiceproviderProfileScreen extends ConsumerStatefulWidget {
//   const ServiceproviderProfileScreen({super.key});
//   @override
//   ConsumerState<ServiceproviderProfileScreen> createState() =>
//       _ServiceproviderProfileScreenState();
// }

// class _ServiceproviderProfileScreenState
//     extends ConsumerState<ServiceproviderProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final selectedIndex = ref.watch(selectedTabProvider);
//     const defaultImage = 'https://tinyurl.com/3tnt6yyy';

//     // Find the service provider with the matching sp_id
//     final sp = ref.watch(spIndexProvider);

//     // Cart services provider
//     final cartServices = ref.watch(cartNotifierProvider);

//     // Service and package bottomsheet options
//     final serviceOptions = ref.watch(serviceOptionsProvider);

//     // Services riverpod provider variables
//     final selectedServiceType = ref.watch(serviceTypeProvider);
//     final selectedPetType = ref.watch(petTypeProvider);
//     final selectedServiceCategory = ref.watch(selectedServiceCategoryProvider);

//     // Watch all services from the provider
//     final allServices = ref.watch(servicesProvider);

//     // Filter services based on the user's selections
//     final filteredServices = allServices.where((service) {
//       // If "All" is selected for pet type, skip pet type filtering
//       final matchesPetType =
//           selectedPetType == 'All' || service.petType.contains(selectedPetType);

//       // If "All" is selected for service category, skip category filtering
//       final matchesServiceCategory = selectedServiceCategory == 'All' ||
//           service.category == selectedServiceCategory;

//       // If "All" is selected for service type, skip service type filtering
//       final matchesSelectedServiceType = selectedServiceType == 'All' ||
//           service.serviceType.contains(selectedServiceType);

//       // Return services that match all the conditions
//       return matchesPetType &&
//           matchesServiceCategory &&
//           matchesSelectedServiceType;
//     }).toList();

// // Watch all packages from the provider
//     final allPackages = ref.watch(packagesProvider);

// // Watch user selections from various providers
//     final selectedPetTypePackage =
//         ref.watch(petTypePackageProvider); // Pet type for package
//     final selectedPackageCategory =
//         ref.watch(selectedPackageCategoryProvider); // Package category
//     final selectedPackageType = ref.watch(packageTypeProvider); // Package type

// // Filter packages based on the user's selections
//     final filteredPackages = allPackages.where((package) {
//       // If "All" is selected for pet type, skip pet type filtering
//       final matchesPetTypePackage = selectedPetTypePackage == 'All' ||
//           package.petType.contains(selectedPetTypePackage);

//       // If "All" is selected for package category, skip category filtering
//       final matchesPackageCategory = selectedPackageCategory == 'All' ||
//           package.category == selectedPackageCategory;

//       // If "All" is selected for package type, skip package type filtering
//       final matchesSelectedPackageType = selectedPackageType == 'All' ||
//           package.packageType.contains(selectedPackageType);

//       // Return packages that match all the conditions
//       return matchesPetTypePackage &&
//           matchesPackageCategory &&
//           matchesSelectedPackageType;
//     }).toList();

//     final List<Widget> tabTitles = [
//       Center(
//         child: Text(
//           "About",
//           style: TextStyle(
//               color: selectedIndex == 0 ? primaryColor : Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: regularText),
//         ),
//       ),
//       Center(
//         child: Text(
//           "Services",
//           style: TextStyle(
//               color: selectedIndex == 1 ? primaryColor : Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: regularText),
//         ),
//       ),
//       Center(
//         child: Text(
//           "Packages",
//           style: TextStyle(
//               color: selectedIndex == 2 ? primaryColor : Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: regularText),
//         ),
//       ),
//     ];

//     // Variable for service provider rating, handling null values
//     final rating = sp['rating'] != null ? sp['rating'].toString() : 'N/A';

//     // Check if the rating is 0.0 and handle it accordingly
//     final displayRating = (rating == '0.0' || rating == 'N/A') ? 'N/A' : rating;

//     final List<Widget> tabContents = [
//       // About tab content
//       Center(
//         child: Column(
//           children: [
//             // This is temporary. Remove this when it's ensured that we don't take null addresses from service providers
//             sp.isNotEmpty
//                 ? spDetailsHeader(
//                     CupertinoIcons.location_solid, sp['address'] ?? 'N/A')
//                 : spDetailsHeader(CupertinoIcons.location_solid, 'N/A'),
//             const SizedBox(height: secondarySizedBox),

// // Rating display logic (assuming 'displayRating' handles null internally)
//             spDetailsHeader(Icons.star, displayRating),
//             const SizedBox(height: secondarySizedBox),

//             spDetailsHeader(
//                 Icons.home_repair_service, sp['service_type'] ?? 'N/A'),
//             const SizedBox(height: secondarySizedBox),

//             spDetailsHeader(Icons.access_time_filled, sp['hours'] ?? 'N/A'),
//             const SizedBox(height: secondarySizedBox),

//             spDetailsHeader(Icons.call, sp['phone'] ?? 'N/A'),
//             const SizedBox(height: secondarySizedBox),

//             spDetailsHeader(Icons.pets, sp['pets_catered'] ?? 'N/A'),
//             const SizedBox(height: secondarySizedBox),
//           ],
//         ),
//       ),
//       // Services tab
//       Center(
//         child: SizedBox(
//           height: getScreenHeight(context) - 395,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Replace dropdown with button to show modal bottom sheet
//                   Container(
//                     width: 250,
//                     decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(secondaryBorderRadius),
//                         border: Border.all(width: 0.5, color: primaryColor)),
//                     child: Center(
//                       child: TextButton(
//                         onPressed: () {
//                           showModalBottomSheet(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Container(
//                                 height: 230,
//                                 decoration: const BoxDecoration(
//                                   borderRadius: BorderRadius.only(
//                                       topLeft:
//                                           Radius.circular(tertiaryBorderRadius),
//                                       topRight: Radius.circular(
//                                           tertiaryBorderRadius)),
//                                   color: lighterGreyColor,
//                                 ),
//                                 child: ListView.builder(
//                                   itemCount: serviceOptions.length,
//                                   itemBuilder: (context, index) {
//                                     final option = serviceOptions[index];
//                                     return ListTile(
//                                       title: Text(option),
//                                       onTap: () {
//                                         ref
//                                             .read(
//                                                 selectedServiceCategoryProvider
//                                                     .notifier)
//                                             .state = option;
//                                         Navigator.pop(context);
//                                       },
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               selectedServiceCategory,
//                               style: const TextStyle(fontSize: regularText),
//                             ),
//                             const Icon(Icons.arrow_drop_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return Container(
//                             height: 230,
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: secondarySizedBox),
//                                 customTitleText(context, 'Pet Type'),
//                                 const SizedBox(height: secondarySizedBox),
//                                 Flexible(
//                                   child: SingleChildScrollView(
//                                     scrollDirection: Axis
//                                         .horizontal, // Enable horizontal scrolling
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         CustomRadioButton(
//                                           autoWidth: true,
//                                           buttonLables: const [
//                                             'All',
//                                             'Dog',
//                                             'Cat',
//                                             'Rabbit',
//                                           ],
//                                           buttonValues: const [
//                                             'All',
//                                             'Dog',
//                                             'Cat',
//                                             'Rabbit',
//                                           ],
//                                           radioButtonValue: (value) =>
//                                               // Updating pet type
//                                               {
//                                             ref
//                                                 .read(petTypeProvider.notifier)
//                                                 .updatePetType(value)
//                                           },
//                                           defaultSelected:
//                                               ref.watch(petTypeProvider),
//                                           selectedColor: primaryColor,
//                                           unSelectedColor: Colors.transparent,
//                                           elevation: 0,
//                                           enableShape: true,
//                                           buttonTextStyle:
//                                               const ButtonTextStyle(
//                                                   textStyle: TextStyle(
//                                                       fontSize: regularText)),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: secondarySizedBox),
//                                 customTitleText(context, 'Service Type'),
//                                 const SizedBox(height: secondarySizedBox),
//                                 Flexible(
//                                   child: SingleChildScrollView(
//                                     scrollDirection: Axis
//                                         .horizontal, // Enable horizontal scrolling
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         CustomRadioButton(
//                                           autoWidth: true,
//                                           buttonLables: const [
//                                             'All',
//                                             'Home service',
//                                             'In-clinic',
//                                           ],
//                                           buttonValues: const [
//                                             'All',
//                                             'Home service',
//                                             'In-clinic',
//                                           ],
//                                           radioButtonValue: (value) =>
//                                               // Updating service type
//                                               {
//                                             ref
//                                                 .read(serviceTypeProvider
//                                                     .notifier)
//                                                 .updateServiceType(value)
//                                           },
//                                           defaultSelected:
//                                               ref.watch(serviceTypeProvider),
//                                           selectedColor: primaryColor,
//                                           unSelectedColor: Colors.transparent,
//                                           elevation: 0,
//                                           enableShape: true,
//                                           buttonTextStyle:
//                                               const ButtonTextStyle(
//                                                   textStyle: TextStyle(
//                                                       fontSize: regularText)),
//                                           width: 150,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     icon: const Icon(
//                       Icons.filter_list,
//                       color: primaryColor,
//                       size: 25,
//                     ),
//                   )
//                 ],
//               ),
//               const SizedBox(
//                 height: tertiarySizedBox,
//               ),
//               filteredServices.isEmpty
//                   ? const Center(
//                       child: Text("No services available"),
//                     )
//                   : Expanded(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(bottom: 80),
//                         itemCount: filteredServices.length,
//                         itemBuilder: (context, index) {
//                           // Get the current service from the filtered list
//                           final service = filteredServices[index];
//                           return Card(
//                             color: Colors.transparent,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.circular(primaryBorderRadius),
//                             ),
//                             child: Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(
//                                       primaryBorderRadius),
//                                   child: Image.network(
//                                     service.image,
//                                     width: 90,
//                                     height: 85,
//                                     fit: BoxFit.cover,
//                                     loadingBuilder:
//                                         (context, child, loadingProgress) {
//                                       if (loadingProgress == null) {
//                                         return child; // Image loaded successfully
//                                       } else {
//                                         return Shimmer.fromColors(
//                                           baseColor: Colors.grey[300]!,
//                                           highlightColor: Colors.grey[100]!,
//                                           child: Container(
//                                             width: 90,
//                                             height: 85,
//                                             color: Colors.grey[300],
//                                           ),
//                                         ); // Shimmer effect while loading
//                                       }
//                                     },
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: 90,
//                                         height: 85,
//                                         color: Colors.grey[300],
//                                         child: const Icon(
//                                           Icons.error,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                     width:
//                                         tertiarySizedBox), // Adjust spacing as needed
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       customTitleText(context, service.name),
//                                       Text('₱${service.price}'),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 37,
//                                   child: Center(
//                                     child: CircleAvatar(
//                                       backgroundColor: secondaryColor,
//                                       // Check if the service is already in the cart by comparing its ID
//                                       child: cartServices.any((cartService) =>
//                                               cartService.id == service.id)
//                                           ? IconButton(
//                                               icon: const Icon(
//                                                 Icons.remove,
//                                                 color: Colors.white,
//                                                 size: 23,
//                                               ),
//                                               onPressed: () {
//                                                 // Remove the service using its ID
//                                                 ref
//                                                     .read(cartNotifierProvider
//                                                         .notifier)
//                                                     .removeService(service);
//                                               },
//                                             )
//                                           : IconButton(
//                                               icon: const Icon(
//                                                 Icons.add,
//                                                 color: Colors.white,
//                                                 size: 23,
//                                               ),
//                                               onPressed: () {
//                                                 // Add the service using its ID
//                                                 ref
//                                                     .read(cartNotifierProvider
//                                                         .notifier)
//                                                     .addService(service);
//                                               },
//                                             ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//       // Packages tab content
//       Center(
//         child: SizedBox(
//           height: getScreenHeight(context) - 395,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Replace dropdown with button to show modal bottom sheet
//                   Container(
//                     width: 250,
//                     decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(secondaryBorderRadius),
//                         border: Border.all(width: 0.5, color: primaryColor)),
//                     child: Center(
//                       child: TextButton(
//                         onPressed: () {
//                           showModalBottomSheet(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Container(
//                                 height: 230,
//                                 decoration: const BoxDecoration(
//                                   borderRadius: BorderRadius.only(
//                                       topLeft:
//                                           Radius.circular(tertiaryBorderRadius),
//                                       topRight: Radius.circular(
//                                           tertiaryBorderRadius)),
//                                   color: lighterGreyColor,
//                                 ),
//                                 child: ListView.builder(
//                                   itemCount: serviceOptions.length,
//                                   itemBuilder: (context, index) {
//                                     final option = serviceOptions[index];
//                                     return ListTile(
//                                       title: Text(option),
//                                       onTap: () {
//                                         ref
//                                             .read(
//                                                 selectedPackageCategoryProvider
//                                                     .notifier)
//                                             .state = option;
//                                         Navigator.pop(context);
//                                       },
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               selectedPackageCategory,
//                               style: const TextStyle(fontSize: regularText),
//                             ),
//                             const Icon(Icons.arrow_drop_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return Container(
//                             height: 230,
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: secondarySizedBox),
//                                 customTitleText(context, 'Pet Type'),
//                                 const SizedBox(height: secondarySizedBox),
//                                 Flexible(
//                                   child: SingleChildScrollView(
//                                     scrollDirection: Axis
//                                         .horizontal, // Enable horizontal scrolling
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         CustomRadioButton(
//                                           autoWidth: true,
//                                           buttonLables: const [
//                                             'All',
//                                             'Dog',
//                                             'Cat',
//                                             'Rabbit',
//                                           ],
//                                           buttonValues: const [
//                                             'All',
//                                             'Dog',
//                                             'Cat',
//                                             'Rabbit',
//                                           ],
//                                           radioButtonValue: (value) =>
//                                               // Updating pet type
//                                               {
//                                             ref
//                                                 .read(petTypePackageProvider
//                                                     .notifier)
//                                                 .updatePetTypePackage(value)
//                                           },
//                                           defaultSelected:
//                                               ref.watch(petTypePackageProvider),
//                                           selectedColor: primaryColor,
//                                           unSelectedColor: Colors.transparent,
//                                           elevation: 0,
//                                           enableShape: true,
//                                           buttonTextStyle:
//                                               const ButtonTextStyle(
//                                                   textStyle: TextStyle(
//                                                       fontSize: regularText)),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: secondarySizedBox),
//                                 customTitleText(context, 'Service Type'),
//                                 const SizedBox(height: secondarySizedBox),
//                                 Flexible(
//                                   child: SingleChildScrollView(
//                                     scrollDirection: Axis
//                                         .horizontal, // Enable horizontal scrolling
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         CustomRadioButton(
//                                           autoWidth: true,
//                                           buttonLables: const [
//                                             'All',
//                                             'Home service',
//                                             'In-clinic',
//                                           ],
//                                           buttonValues: const [
//                                             'All',
//                                             'Home service',
//                                             'In-clinic',
//                                           ],
//                                           radioButtonValue: (value) =>
//                                               // Updating service type
//                                               {
//                                             ref
//                                                 .read(packageTypeProvider
//                                                     .notifier)
//                                                 .updatePackageType(value)
//                                           },
//                                           defaultSelected:
//                                               ref.watch(serviceTypeProvider),
//                                           selectedColor: primaryColor,
//                                           unSelectedColor: Colors.transparent,
//                                           elevation: 0,
//                                           enableShape: true,
//                                           buttonTextStyle:
//                                               const ButtonTextStyle(
//                                                   textStyle: TextStyle(
//                                                       fontSize: regularText)),
//                                           width: 150,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     icon: const Icon(
//                       Icons.filter_list,
//                       color: primaryColor,
//                       size: 25,
//                     ),
//                   )
//                 ],
//               ),
//               const SizedBox(
//                 height: tertiarySizedBox,
//               ),
//               filteredPackages.isEmpty
//                   ? const Center(
//                       child: Text("No packages available"),
//                     )
//                   : Expanded(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(bottom: 80),
//                         itemCount: filteredPackages.length,
//                         itemBuilder: (context, index) {
//                           final package = filteredPackages[index];
//                           return Card(
//                             color: Colors.transparent,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.circular(primaryBorderRadius),
//                             ),
//                             child: Row(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(
//                                       primaryBorderRadius),
//                                   child: Image.network(
//                                     package.image,
//                                     width: 90,
//                                     height: 85,
//                                     fit: BoxFit.cover,
//                                     loadingBuilder:
//                                         (context, child, loadingProgress) {
//                                       if (loadingProgress == null) {
//                                         return child; // Image loaded successfully
//                                       } else {
//                                         return Shimmer.fromColors(
//                                           baseColor: Colors.grey[300]!,
//                                           highlightColor: Colors.grey[100]!,
//                                           child: Container(
//                                             width: 90,
//                                             height: 85,
//                                             color: Colors.grey[300],
//                                           ),
//                                         ); // Shimmer effect while loading
//                                       }
//                                     },
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: 90,
//                                         height: 85,
//                                         color: Colors.grey[300],
//                                         child: const Icon(
//                                           Icons.error,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                     width:
//                                         tertiarySizedBox), // Adjust spacing as needed
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       customTitleText(context, package.name),
//                                       Text('₱${package.price}'),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 37,
//                                   child: Center(
//                                     child: CircleAvatar(
//                                       backgroundColor: secondaryColor,
//                                       // Check if the service is already in the cart by comparing its ID
//                                       child: cartServices.any((cartPackage) =>
//                                               cartPackage.id == package.id)
//                                           ? IconButton(
//                                               icon: const Icon(
//                                                 Icons.remove,
//                                                 color: Colors.white,
//                                                 size: 23,
//                                               ),
//                                               onPressed: () {
//                                                 // Remove the service using its ID
//                                                 ref
//                                                     .read(cartNotifierProvider
//                                                         .notifier)
//                                                     .removePackage(package);
//                                               },
//                                             )
//                                           : IconButton(
//                                               icon: const Icon(
//                                                 Icons.add,
//                                                 color: Colors.white,
//                                                 size: 23,
//                                               ),
//                                               onPressed: () {
//                                                 // Add the service using its ID
//                                                 ref
//                                                     .read(cartNotifierProvider
//                                                         .notifier)
//                                                     .addPackage(package);
//                                               },
//                                             ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     )
//             ],
//           ),
//         ),
//       ),
//     ];

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: customAppBar(context),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: customFloatingActionButton(context,
//           buttonText: 'Book appointment', onPressed: () {
//         Navigator.push(context, slideUpRoute(const CartScreen()));
//       }),
//       body: Center(
//         child: Column(
//           children: [
//             Image.network(
//               sp['image'],
//               width: double.infinity,
//               height: 200,
//               fit: sp['image'] == defaultImage ? BoxFit.contain : BoxFit.cover,
//               loadingBuilder: (BuildContext context, Widget child,
//                   ImageChunkEvent? loadingProgress) {
//                 if (loadingProgress == null) {
//                   return child;
//                 } else {
//                   return Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Container(
//                       width: double.infinity,
//                       height: 200,
//                       color: Colors.grey[300],
//                     ),
//                   ); // Shimmer effect while loading
//                 }
//               },
//               errorBuilder:
//                   (BuildContext context, Object error, StackTrace? stackTrace) {
//                 return Container(
//                   color: lighterGreyColor,
//                   width: double.infinity,
//                   height: 200,
//                   child: const Center(
//                     child: Icon(
//                       Icons.error,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(
//               width: screenPadding(context),
//               child: Column(
//                 children: [
//                   const SizedBox(height: tertiarySizedBox),
//                   customTitleText(context, sp['name']),
//                   const SizedBox(height: secondarySizedBox),
//                   Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: List.generate(tabContents.length, (index) {
//                           return GestureDetector(
//                             onTap: () => ref
//                                 .read(selectedTabProvider.notifier)
//                                 .state = index,
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(
//                                   horizontal: primarySizedBox),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(
//                                       quaternaryBorderRadius),
//                                   color: selectedIndex == index
//                                       ? lighterSecondaryColor
//                                       : Colors.transparent,
//                                 ),
//                                 child: Padding(
//                                     padding: const EdgeInsets.all(10),
//                                     child: tabTitles[index]),
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                       const SizedBox(height: tertiarySizedBox),
//                       tabContents[selectedIndex],
//                     ],
//                   )
//                 ],
//               ),
//             ),
//             const SizedBox(height: primarySizedBox),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget spDetailsHeader(IconData icon, String detail) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Icon(icon, size: 20, color: const Color.fromARGB(255, 26, 10, 10)),
//             const SizedBox(width: secondarySizedBox),
//             regularTextWidget(detail),
//           ],
//         ),
//         const SizedBox(height: secondarySizedBox),
//       ],
//     );
//   }
// }