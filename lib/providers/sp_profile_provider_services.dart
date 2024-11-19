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

// Filter out services without required details and map them to Service objects
  List<Service> serviceList = services
      .where((service) =>
          service['sp_id'] != null &&
          service['service_id'] != null &&
          service['service_name'] != null &&
          service['service_name'].toString().isNotEmpty)
      .map((service) {
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
      minWeight: service['min_weight'] != null
          ? double.tryParse(service['min_weight'].toString()) ?? 0.0
          : 0.0,
      maxWeight: service['max_weight'] != null
          ? double.tryParse(service['max_weight'].toString()) ?? 0.0
          : 0.0,
    );
  }).toList();

  // Apply client-side filtering based on string matches

  // Filter by petType if it is provided
  if (filterCriteria.petType != null && filterCriteria.petType!.isNotEmpty) {
    serviceList = serviceList.where((service) {
      return service.servicePetType.contains(filterCriteria.petType);
    }).toList();
  }

  // Filter by serviceType if it is provided
  if (filterCriteria.serviceType != null &&
      filterCriteria.serviceType!.isNotEmpty) {
    serviceList = serviceList.where((service) {
      return service.serviceType.contains(filterCriteria.serviceType);
    }).toList();
  }

  // Filter by serviceCategory if it is provided
  if (filterCriteria.serviceCategory != null &&
      filterCriteria.serviceCategory!.isNotEmpty) {
    serviceList = serviceList.where((service) {
      return service.category.contains(filterCriteria.serviceCategory);
    }).toList();
  }

  // Filter by weight if it is provided
  if (filterCriteria.weight != null) {
    serviceList = serviceList.where((service) {
      return filterCriteria.weight! >= service.minWeight &&
          filterCriteria.weight! <= service.maxWeight;
    }).toList();
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
