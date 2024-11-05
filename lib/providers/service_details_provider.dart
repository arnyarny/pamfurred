import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define a FutureProvider.family for fetching service details
final serviceProviderServiceDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, Map<String, String>>(
        (ref, params) async {
  final supabase = Supabase.instance.client;
  final spId = params['spId']!;
  final serviceId = params['serviceId']!;

  final response =
      await supabase.rpc('get_service_provider_service_details', params: {
    'spId': spId,
    'serviceId': serviceId,
  });

  // Assuming response data returns as a list with a single item
  final data = (response as List<dynamic>).isNotEmpty
      ? response[0] as Map<String, dynamic>
      : null;
  return data;
});

// Provider to manage the selected service provider for booking appointment
final selectedServiceProviderIdProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected service ID for fetching details
final selectedServiceIdProvider = StateProvider<String>((ref) => '');
