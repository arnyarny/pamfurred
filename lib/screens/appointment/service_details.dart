// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pamfurred/components/globals.dart';
// import 'package:pamfurred/components/regular_text.dart';
// import 'package:pamfurred/components/title_text.dart';
// import 'package:pamfurred/providers/service_details_provider.dart';
// import 'package:pamfurred/providers/serviceprovider_provider.dart';

// class ServicePackageDetailsScreen extends ConsumerWidget {
//   const ServicePackageDetailsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Retrieve the service provider ID and ensure it is not null
//     final sp = ref.watch(spIndexProvider);
//     if (sp == null) {
//       return const Center(child: Text("No provider ID available"));
//     }

//     // Set the selected service provider ID in the state
//     final spId = sp['sp_id'].toString();
//     ref.read(selectedServiceProviderIdProvider.notifier).state = spId;

//     // Retrieve the selected service ID
//     final selectedServiceId = ref.watch(selectedServiceIdProvider);
//     if (selectedServiceId.isEmpty) {
//       return const Center(child: Text("No service ID selected"));
//     }

//     // Fetch the service details based on the selected service provider ID and service ID
//     final serviceDetails = ref.watch(serviceProviderServiceDetailsProvider(
//         {'spId': spId, 'serviceId': selectedServiceId}));

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: const Text('Service Details')),
//       body: Center(
//         child: serviceDetails.when(
//           data: (service) {
//             if (service == null) {
//               return const Text("No service details available.");
//             }
//             return ListView(
//               padding: const EdgeInsets.all(16.0),
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8.0),
//                       child: Image.network(
//                         service['service_image'] ?? '',
//                         width: 90,
//                         height: 85,
//                         fit: BoxFit.cover,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) {
//                             return child;
//                           } else {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           }
//                         },
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: 90,
//                             height: 85,
//                             color: Colors.grey[300],
//                             child: const Icon(Icons.error),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: tertiarySizedBox),
//                     Expanded(
//                       child: customTitleText(
//                           context, service['service_name'] ?? 'Unknown'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16.0),
//                 _buildDetailSection('Price', '₱${service['price'] ?? '0.00'}'),
//                 _buildDetailSection('Size', service['size'] ?? 'N/A'),
//                 _buildDetailSection(
//                   'Service Type',
//                   (service['service_type_service'] as List<dynamic>?)
//                           ?.join(', ') ??
//                       'N/A',
//                 ),
//                 _buildDetailSection(
//                   'Service Category',
//                   (service['service_category'] as List<dynamic>?)?.join(', ') ??
//                       'N/A',
//                 ),
//               ],
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (error, stack) => Center(child: Text('Error: $error')),
//         ),
//       ),
//     );
//   }

//   // Helper method to build a detail section
//   Widget _buildDetailSection(String title, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         regularBoldTextWidget(title),
//         const SizedBox(height: 4.0),
//         regularTextWidget(value),
//         const SizedBox(height: 16.0),
//       ],
//     );
//   }
// }
