import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final supabase = supabase_flutter.Supabase.instance.client;

final allServicesProvider =
    FutureProvider.family<List<dynamic>, ServiceFilterCriteria>(
        (ref, filterCriteria) async {
  final response = await supabase.rpc('get_service_provider_services',
      params: {'spid': filterCriteria.spId});

  List<dynamic> services = response as List<dynamic>;

  // Apply client-side filtering if needed
  if (filterCriteria.petType != null) {
    services = services
        .where(
            (service) => filterCriteria.petType!.contains(service['pet_type']))
        .toList();
  }
  if (filterCriteria.serviceType != null) {
    services = services
        .where((service) =>
            filterCriteria.serviceType!.contains(service['service_type']))
        .toList();
  }
  if (filterCriteria.serviceCategory != null) {
    services = services
        .where((service) => filterCriteria.serviceCategory!
            .contains(service['service_category']))
        .toList();
  }
  if (filterCriteria.size != null) {
    services = services
        .where((service) => service['size'] == filterCriteria.size)
        .toList();
  }

  return services;
});

class ServiceTypeNotifier extends StateNotifier<String> {
  ServiceTypeNotifier() : super('All');

  void updateServiceType(String value) {
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
