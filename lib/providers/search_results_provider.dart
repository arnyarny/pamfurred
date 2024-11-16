import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/sp_search_results.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// To know which preference was selected
final sortResultsProvider = StateProvider<String>((ref) => 'All');

// Address providers
final hasDetectedAddressProvider = StateProvider<bool>((ref) => false);
final streetProvider = StateProvider<String>((ref) => '');
final cityProvider = StateProvider<String>((ref) => '');
final provinceProvider = StateProvider<String>((ref) => '');
final latProvider = StateProvider<double?>((ref) => null);
final longProvider = StateProvider<double?>((ref) => null);

// Price providers
final minPriceProvider = StateProvider<double>((ref) => 0);
final maxPriceProvider = StateProvider<double>((ref) => 200);

// For services
final searchResultsServiceProviderServices =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase.rpc('get_service_provider_services_by_category', params: {
    'service_category_param': category,
  });

  return response as List<dynamic>;
});

// For packages
final searchResultsServiceProviderPackages =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
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

  // Convert services and packages into ServiceProviderItem list
  final serviceItems = services
      .map((service) => ServiceProviderItem.fromService(service))
      .toList();
  final packageItems = packages
      .map((package) => ServiceProviderItem.fromPackage(package))
      .toList();

  // Combine both lists
  return [...serviceItems, ...packageItems];
});

// Sorted by price (cheapest to most expensive)
final sortSearchResultsByPrice =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase.rpc('get_service_providers_by_price_range', params: {
    'service_category_param': category,
    'min_price': ref.read(minPriceProvider),
    'max_price': ref.read(maxPriceProvider),
  });

  return response as List<dynamic>;
});

// Sorted by location (nearest to farthest)
final sortSearchResultsByLocation =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = Supabase.instance.client;

  // Access the latitude and longitude from the providers
  final latitude = ref.read(latProvider);
  final longitude = ref.read(longProvider);

  final response =
      await supabase.rpc('get_service_providers_by_distance', params: {
    'service_category_param': category,
    'latitude_param': latitude,
    'longitude_param': longitude,
  });

  return response as List<dynamic>;
});
