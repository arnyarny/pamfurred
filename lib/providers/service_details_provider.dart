import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a FutureProvider.family for fetching service details
// Provider to manage the selected service provider for booking appointment
final selectedServiceProviderIdProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected service ID for fetching details
final selectedServicePackageIdProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected serviceprovider_service_id selected serviceprovider_package_id for fetching details
final selectedServiceProviderServicePackageIdProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected category for fetching details
final selectedSearchResultCategoryProvider = StateProvider<String>((ref) => '');

// Manage if it's a service or a package
final selectedSearchResultServicePackageTypeProvider = StateProvider<String>((ref) => '');

final selectedSearchResultSpSentimentLabel = StateProvider<String>((ref) => '');

final selectedSearchResultSpAvgRating = StateProvider<num?>((ref) => null);

final isServicePackageValidForPetProvider = StateProvider<bool>((ref) => false);

// Provider to manage the selected pet ID for fetching details
final servicePackageMatchesAppointmentPrefProvider = StateProvider<bool>((ref) => false);

