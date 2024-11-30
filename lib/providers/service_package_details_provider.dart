import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/models/sp_search_results.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final servicePackageDetailsProvider =
    FutureProvider.family<ServiceProviderItem, String>(
        (ref, servicePackageId) async {
  // Determine if the ID belongs to a service or a package
  // This could involve querying a metadata table or inferring based on the ID structure
  final metadata =
      await fetchMetadataForId(servicePackageId); // Implement this function
  final isService = metadata['type'] == 'service';

  if (isService) {
    // Fetch service details
    final filterCriteria =
        ServiceFilterCriteria(spId: '', serviceId: servicePackageId);
    final services =
        await ref.watch(allServicesProvider(filterCriteria).future);

    final service = services.firstWhere(
      (s) => s.serviceId == servicePackageId,
      orElse: () =>
          throw Exception('Service not found for ID: $servicePackageId'),
    );

    return ServiceProviderItem.fromService({
      'sp_id': service.serviceServiceProviderId,
      'name': service.serviceName,
      'service_id': service.serviceId,
      'service_name': service.serviceName,
      'service_image': service.serviceImage,
      'service_price': service.servicePrice
    });
  } else {
    // Fetch package details
    final filterCriteria =
        PackageFilterCriteria(spId: '', packageId: servicePackageId);
    final packages =
        await ref.watch(allPackagesProvider(filterCriteria).future);

    final package = packages.firstWhere(
      (p) => p.packageId == servicePackageId,
      orElse: () =>
          throw Exception('Package not found for ID: $servicePackageId'),
    );

    return ServiceProviderItem.fromPackage({
      'sp_id': package.packageServiceProviderId,
      'name': package.packageName,
      'package_id': package.packageId,
      'package_name': package.packageName,
      'package_image': package.packageImage,
      'package_price': package.packagePrice
    });
  }
});

// Helper function to fetch metadata for a given ID
Future<Map<String, dynamic>> fetchMetadataForId(String servicePackageId) async {
  // Replace this with your actual logic for fetching metadata
  // For example, querying the database or using an API endpoint
  
  final supabase = supabase_flutter.Supabase.instance.client;
  final response = await supabase
      .from('service_package_metadata') // Your metadata table
      .select('type') // Fetch type field (e.g., 'service' or 'package')
      .eq('id', servicePackageId)
      .single();

  return response as Map<String, dynamic>;
}
