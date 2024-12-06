import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a FutureProvider.family for fetching service details
// Provider to manage the selected service provider for booking appointment
final selectedServiceProviderIdProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected service ID for fetching details
final selectedServicePackageIdProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected service package type after search result
final selectedSearchResultServicePackageTypeProvider = StateProvider<String>((ref) => '');