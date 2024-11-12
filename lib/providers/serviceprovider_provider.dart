import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final serviceProviderFutureProvider =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  // Perform the query with the 'contains' operator
  final response = await supabase
      .from('service_provider_with_categories_and_sentiment')
      .select('*')
      .contains('unique_categories', '["$category"]');

  // Return the data as List<dynamic>
  return response as List<dynamic>;
});

final serviceProviderFutureProviderWithoutCategory =
    FutureProvider<List<dynamic>>((ref) async {
  final supabase = supabase_flutter.Supabase.instance.client;
  final response = await supabase
      .from('service_provider_with_categories_and_sentiment')
      .select('*');

  return response as List<dynamic>;
});

// Provider to manage the selected service provider for booking appointment
final selectedSpIndexProvider = StateProvider<String>((ref) => '');

// Modify spIndexProvider to handle AsyncValue properly
final spIndexProvider = Provider<Map<String, dynamic>?>((ref) {
  final allItems = ref.watch(serviceProviderFutureProviderWithoutCategory);
  final selectedSp = ref.watch(selectedSpIndexProvider);

  // Ensure we have data before accessing
  return allItems.maybeWhen(
    data: (items) {
      // Find the service provider with the matching sp_id
      return items.firstWhere(
        (item) => item['sp_id'].toString() == selectedSp,
        orElse: () => null,
      );
    },
    orElse: () => null,
  );
});

// Provider to manage the selected package or service category for booking appointment
final selectedAppointmentCategoryProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected package or service type for booking appointment
final selectedAppointmentPackageServiceTypeProvider =
    StateProvider<String>((ref) => '');

// Provider to manage the selected pet type for booking appointment
final selectedAppointmentPetTypeProvider = StateProvider<String>((ref) => '');

// Provider to manage the selected pet type index for booking appointment
final selectedAppointmentPetTypeIndexProvider =
    StateProvider<String>((ref) => '');

// To make sure the selected pet remains as the default when revisiting a screen
final selectedPetProfileIdProvider = StateProvider<String?>((ref) => null);
