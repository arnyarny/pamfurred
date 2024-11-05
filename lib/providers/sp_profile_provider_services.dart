import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/models/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final supabase = supabase_flutter.Supabase.instance.client;

final allServicesProvider =
    FutureProvider.family<List<Service>, ServiceFilterCriteria>(
        (ref, filterCriteria) async {
  final response = await supabase.rpc('get_service_provider_services',
      params: {'spid': filterCriteria.spId});

  List<dynamic> services = response as List<dynamic>;

  // Convert each service map to a Service object
  List<Service> serviceList = services.map((service) {
    return Service(
      serviceServiceProviderId: service['sp_id'] as String? ?? '',
      serviceId: service['service_id'] as String? ?? '',
      serviceName: service['service_name'] as String? ?? '',
      category: service['service_category'] is List<dynamic>
          ? List<String>.from(service['service_category'] as List<dynamic>)
          : [],
      servicePrice: service['price'] as int? ?? 0,
      serviceImage: service['service_image'] as String? ?? '',
      serviceType: service['service_type_service'] is List<dynamic>
          ? List<String>.from(service['service_type_service'] as List<dynamic>)
          : [],
      servicePetType: service['pet_type'] is List<dynamic>
          ? List<String>.from(service['pet_type'] as List<dynamic>)
          : [],
      serviceSize: service['size'] as String? ?? '',
    );
  }).toList();

  // Apply client-side filtering
  if (filterCriteria.petType != null) {
    serviceList = serviceList
        .where((service) =>
            service.servicePetType.any(filterCriteria.petType!.contains))
        .toList();
  }
  if (filterCriteria.serviceType != null) {
    serviceList = serviceList
        .where((service) =>
            service.serviceType.any(filterCriteria.serviceType!.contains))
        .toList();
  }
  if (filterCriteria.serviceCategory != null) {
    serviceList = serviceList
        .where((service) =>
            service.category.any(filterCriteria.serviceCategory!.contains))
        .toList();
  }
  if (filterCriteria.size != null) {
    serviceList = serviceList
        .where((service) => service.serviceSize == filterCriteria.size)
        .toList();
  }

  return serviceList;
});

// Provider to fetch a specific service details by provider ID and service ID
final specificServiceProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String spId, String serviceId)>(
        (ref, params) async {
  final (spId, serviceId) = params;
  final supabase = supabase_flutter.Supabase.instance.client;

  // Call the Supabase RPC function
  final response = await supabase.rpc('get_service_provider_services', params: {
    'spid': spId,
  });

  final services = response as List<dynamic>;

  // Filter to find the specific service by service_id
  final specificService = services.firstWhere(
    (service) => service['service_id'] == serviceId,
    orElse: () => throw Exception('Service not found'),
  );

  return specificService as Map<String, dynamic>; // Return the specific service
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
