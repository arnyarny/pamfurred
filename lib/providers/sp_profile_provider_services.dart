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

  // print('Supabase Response: $response');

  if (response is! List) {
    print('Unexpected Response Type: $response');
    return [];
  }

  List<dynamic> services = response;

  // print('Initial Services from Supabase: $services');

  // Map and filter services
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
      serviceProviderNameOfService: service['sp_name'] as String? ?? '',
      serviceProviderServiceId: service['serviceprovider_service_id'] ?? '',
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

  // print('Mapped Service List: $serviceList');

  // Apply filters with debug logs
  if (filterCriteria.petType != null && filterCriteria.petType!.isNotEmpty) {
    serviceList = serviceList.where((service) {
      return service.servicePetType.contains(filterCriteria.petType);
    }).toList();
    // print('After petType filter: $serviceList');
  }

  if (filterCriteria.serviceType != null &&
      filterCriteria.serviceType!.isNotEmpty) {
    serviceList = serviceList.where((service) {
      return service.serviceType.contains(filterCriteria.serviceType);
    }).toList();
    // print('After serviceType filter: $serviceList');
  }

  if (filterCriteria.serviceCategory != null &&
      filterCriteria.serviceCategory!.isNotEmpty) {
    serviceList = serviceList.where((service) {
      return service.category.contains(filterCriteria.serviceCategory);
    }).toList();
    // print('After serviceCategory filter: $serviceList');
  }

  if (filterCriteria.weight != null) {
    serviceList = serviceList.where((service) {
      return filterCriteria.weight! >= service.minWeight &&
          filterCriteria.weight! <= service.maxWeight;
    }).toList();
    // print('After weight filter: $serviceList');
  }

  return serviceList;
});

// Hold selected service ID when a service is selected in search results
// Selected service provider category in home screen
final selectedServiceIdProvider = StateProvider<String>((ref) => '');
