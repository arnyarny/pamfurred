import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_package;

final serviceProviderFutureProvider =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = supabase_package.Supabase.instance.client;
  final response = await supabase
      .from('service_provider')
      .select(
          'image, name, rating, latitude, longitude, sentiment_label, category, user:user_id(user_type)')
      .contains('category', '["$category"]')
      .eq('user.user_type', 'service_provider');

  return response as List<dynamic>;
});

// Provider to manage the selected service provider ID for booking
final selectedSpIndexProvider = StateProvider<String>((ref) => '');

final selectedSpCategoryProvider = StateProvider<String>((ref) => '');

// Provider to find the selected service providers that match the selected ID, returning as a List
final spIndexProvider = Provider.family<List<dynamic>, String>((ref, category) {
  // Fetch the list of service providers in the specified category
  final allItems =
      ref.watch(serviceProviderFutureProvider(category)).asData?.value;

  // Get the selected service provider ID
  final selectedSp = ref.watch(selectedSpIndexProvider);

  // Find all service providers that match the selected ID and return as List
  if (allItems != null && selectedSp.isNotEmpty) {
    return allItems
        .where((item) => item['user']['user_id'].toString() == selectedSp)
        .toList();
  }
  return [];
});
