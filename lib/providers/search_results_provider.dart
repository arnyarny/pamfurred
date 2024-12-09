import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/backend_logic_files/store_location.dart';
import 'package:pamfurred/models/sp_search_results.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// To know which preference was selected
final sortResultsProvider = StateProvider<String>((ref) => 'All');

// Input location providers
final isInputLocationProvider = StateProvider<bool>((ref) => false);
final inputLatProvider = StateProvider<double?>((ref) => null);
final inputLongProvider = StateProvider<double?>((ref) => null);
final inputFullAddressProvider = StateProvider<String?>((ref) => '');

// Input price providers
final isInputPriceProvider = StateProvider<bool>((ref) => false);
final inputMinPriceProvider = StateProvider<num>((ref) => 0);
final inputMaxPriceProvider = StateProvider<num>((ref) => 5000);

// Address providers
final hasDetectedAddressProvider = StateProvider<bool>((ref) => false);
final floorUnitRoomProvider = StateProvider<String?>((ref) => '');
final streetProvider = StateProvider<String>((ref) => '');
final barangayProvider = StateProvider<String>((ref) => '');
final cityProvider = StateProvider<String>((ref) => '');
final provinceProvider = StateProvider<String>((ref) => '');
final fullAddressProvider = StateProvider<String>((ref) => '');
final latProvider = StateProvider<double?>((ref) => null);
final longProvider = StateProvider<double?>((ref) => null);

// Price providers
final minPriceProvider = StateProvider<num>((ref) => 0);
final maxPriceProvider = StateProvider<num>((ref) => 1000);

// Input search providers
final searchedServicePackageProvider = StateProvider<String>((ref) => '');

// For services
final searchResultsServiceProviderServices =
    FutureProvider.family<List<dynamic>, String?>((ref, category) async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase.rpc('get_service_provider_services_by_category', params: {
    'service_category_param': category,
  });

  return response as List<dynamic>;
});

// For packages
final searchResultsServiceProviderPackages =
    FutureProvider.family<List<dynamic>, String?>((ref, category) async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase.rpc('get_service_provider_packages_by_category', params: {
    'package_category_param': category,
  });

  return response as List<dynamic>;
});

// Combined service and package
final combinedSearchResultsProvider =
    FutureProvider.family<List<ServiceProviderItem>, String>(
        (ref, category) async {
  final services =
      await ref.watch(searchResultsServiceProviderServices(category).future);
  final packages =
      await ref.watch(searchResultsServiceProviderPackages(category).future);

  final serviceItems = services
      .map((service) => ServiceProviderItem.fromService(
          service,
          service['service_id'] ?? '',
          service['serviceprovider_service_id'] ?? ''))
      .toList();

  final packageItems = packages
      .map((package) => ServiceProviderItem.fromPackage(
          package,
          package['package_id'] ?? '',
          package['serviceprovider_package_id'] ?? ''))
      .toList();

  return [...serviceItems, ...packageItems];
});

// Sorted by price (cheapest to most expensive) using combinedSearchResultsProvider
final sortSearchResultsByPrice =
    FutureProvider.family<List<ServiceProviderItem>, String>(
        (ref, category) async {
  final combinedResults =
      await ref.watch(combinedSearchResultsProvider(category).future);

  final minPrice = ref.watch(isInputPriceProvider)
      ? ref.watch(inputMinPriceProvider)
      : ref.watch(minPriceProvider);

  final maxPrice = ref.watch(isInputPriceProvider)
      ? ref.watch(inputMaxPriceProvider)
      : ref.watch(maxPriceProvider);

  final filteredAndSortedResults = combinedResults
      .where((item) => item.price >= minPrice && item.price <= maxPrice)
      .toList()
    ..sort((a, b) => a.price.compareTo(b.price));

  return filteredAndSortedResults;
});

// Sorted by location (nearest to farthest) using combinedSearchResultsProvider
final sortSearchResultsByLocation =
    FutureProvider.family<List<ServiceProviderItem>, String>(
        (ref, category) async {
  final combinedResults =
      await ref.watch(combinedSearchResultsProvider(category).future);

  final isInputLocation = ref.watch(isInputLocationProvider);
  final latitude = isInputLocation
      ? ref.watch(inputLatProvider)
      : ref.watch(locationProvider).latitude;
  final longitude = isInputLocation
      ? ref.watch(inputLongProvider)
      : ref.watch(locationProvider).longitude;

  print("Using coordinates: Latitude: $latitude, Longitude: $longitude");

  final sortedResults = combinedResults.map((item) {
    final distance =
        calculateDistance(latitude!, longitude!, item.latitude, item.longitude);

    print('Distance to ${item.name}: $distance km');
    return {'item': item, 'distance': distance};
  }).toList()
    ..sort((a, b) {
      final distanceA = a['distance'] as double;
      final distanceB = b['distance'] as double;

      // Precision handling: if the difference is smaller than a threshold, consider them equal
      if ((distanceA - distanceB).abs() < 0.0001) {
        print("Distances are considered equal: $distanceA km vs $distanceB km");
        return 0; // No sorting if they are nearly identical
      }
      return distanceA.compareTo(distanceB);
    });

  // Return sorted items
  return sortedResults
      .map((entry) => entry['item'] as ServiceProviderItem)
      .toList();
});

// Helper function to calculate the distance between two points
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371.0; // Radius of Earth in kilometers
  final dLat = _degreesToRadians(lat2 - lat1);
  final dLon = _degreesToRadians(lon2 - lon1);

  final a = (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          (sin(dLon / 2) * sin(dLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

// Helper function to convert degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * pi / 180.0;
}
