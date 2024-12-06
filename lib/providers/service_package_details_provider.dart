import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/models/sp_search_results.dart';
import 'package:pamfurred/providers/service_details_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';

final servicePackageDetailsProvider =
    FutureProvider.family<ServiceProviderItem, String>(
        (ref, servicePackageId) async {
  final isService =
      ref.watch(selectedSearchResultServicePackageTypeProvider) == 'service';

  final spId = ref.watch(selectedSpIndexProvider).toString();

  if (isService) {
    // Fetch service details
    final filterCriteria =
        ServiceFilterCriteria(spId: spId, serviceId: servicePackageId);
    final services =
        await ref.watch(allServicesProvider(filterCriteria).future);

    final service = services.firstWhere(
      (s) => s.serviceId == servicePackageId,
      orElse: () =>
          throw Exception('Service not found for ID: $servicePackageId'),
    );

    return ServiceProviderItem.fromService({
      'sp_id': service.serviceServiceProviderId,
      // 'name': service.serviceName,
      'service_id': service.serviceId,
      'service_name': service.serviceName,
      'service_image': service.serviceImage,
      'service_price': service.servicePrice
    });
  } else {
    // Fetch package details
    final filterCriteria =
        PackageFilterCriteria(spId: spId, packageId: servicePackageId);
    final packages =
        await ref.watch(allPackagesProvider(filterCriteria).future);

    final package = packages.firstWhere(
      (p) => p.packageId == servicePackageId,
      orElse: () =>
          throw Exception('Package not found for ID: $servicePackageId'),
    );

    return ServiceProviderItem.fromPackage({
      'sp_id': package.packageServiceProviderId,
      // 'name': package.packageName,
      'package_id': package.packageId,
      'package_name': package.packageName,
      'package_image': package.packageImage,
      'package_price': package.packagePrice
    });
  }
});
