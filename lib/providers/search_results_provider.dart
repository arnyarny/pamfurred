import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Default results
final searchResultsServiceProviders =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase.rpc('get_service_providers_by_category', params: {
    'service_category_param': category,
  });

  return response as List<dynamic>;
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
