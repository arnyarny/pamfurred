import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;


final allServicesProvider =
    FutureProvider.family<List<dynamic>, String>((ref, spId) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  final response = await supabase.rpc('get_service_provider_services',
      params: {'spid': spId}); // Call the RPC function with sp_id

  return response as List<dynamic>;
});

// Service type provider
final serviceTypeProvider = StateNotifierProvider<ServiceTypeNotifier, String>(
  (ref) => ServiceTypeNotifier(),
);

class ServiceTypeNotifier extends StateNotifier<String> {
  ServiceTypeNotifier() : super('All');

  void updateServiceType(String value) {
    state = value;
  }
}

// Pet type provider
final petTypeProvider = StateNotifierProvider<PetTypeNotifier, String>(
  (ref) => PetTypeNotifier(),
);

class PetTypeNotifier extends StateNotifier<String> {
  PetTypeNotifier() : super('All');

  void updatePetType(String value) {
    state = value;
  }
}

// Provider to manage the list of service options
final serviceOptionsProvider = Provider<List<String>>((ref) {
  return [
    'Pet grooming services',
    'Pet boarding services',
    'Veterinary services',
    'All'
  ];
});

// Provider to manage the selected service category
final selectedServiceCategoryProvider = StateProvider<String>((ref) {
  return 'All'; // Adjust default value if needed
});
