import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/models/sp_search_results.dart';
import 'package:pamfurred/providers/service_details_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';

final servicePackageDetailsProvider =
    FutureProvider<ServiceProviderItem>((ref) async {
  // Get the IDs from the StateProviders
  final spId = ref.watch(selectedSpIndexProvider);
  final servicePackageId = ref.watch(selectedServicePackageIdProvider);
  final serviceProviderServicePackageId =
      ref.watch(selectedServiceProviderServicePackageIdProvider);

  // Check selected type of servicePackageId
  final isService =
      ref.watch(selectedSearchResultServicePackageTypeProvider) == 'service';

  if (servicePackageId.isEmpty) {
    throw Exception('servicePackageId is empty!');
  }

  // print('Fetching details for servicePackageId: $servicePackageId');
  // print('isService: $isService');
  // print('spId: $spId');
  // print('servicePackageId: $servicePackageId');
  // print('serviceProviderServicePackageId: $serviceProviderServicePackageId');

  if (isService) {
    print('Fetching service details...');
    // Fetch service details based on servicePackageId, serviceProviderServicePackageId, and spId
    final filterCriteria = ServiceFilterCriteria(
        spId: spId,
        serviceId: servicePackageId,
        serviceProviderServicePackageId: serviceProviderServicePackageId);
    print('Service filter criteria: $filterCriteria');

    final services =
        await ref.watch(allServicesProvider(filterCriteria).future);
    print('Fetched services: ${services.length}');

    final service = services.firstWhere(
      (s) =>
          s.serviceId == servicePackageId &&
          s.serviceProviderServiceId == serviceProviderServicePackageId &&
          s.serviceServiceProviderId ==
              spId, // Ensures service matches spId as well
      orElse: () {
        print(
            'Service not found for servicePackageId: $servicePackageId, serviceProviderServicePackageId: $serviceProviderServicePackageId, spId: $spId');
        throw Exception('Service not found for the provided IDs');
      },
    );

    print('Found service: ${service.serviceName}');
    return ServiceProviderItem.fromService(
      {
        'sp_id': service.serviceServiceProviderId,
        'sp_name': service.serviceProviderNameOfService,
        'sp_image': service.serviceServiceProviderImage,
        'service_id': service.serviceId,
        'serviceprovider_service_id': service.serviceProviderServiceId,
        'service_name': service.serviceName,
        'service_desc': service.serviceDesc,
        'service_image': service.serviceImage,
        'service_price': service.servicePrice,
        'service_size': service.serviceSize,
        'min_weight': service.minWeight,
        'max_weight': service.maxWeight,
        'service_type_service': service.serviceType,
        'pet_type': service.servicePetType,
      },
      service.serviceId, // serviceId as the second argument
      service
          .serviceProviderServiceId, // serviceProviderServiceId as the third argument
    );
  } else {
    print('Fetching package details...');
    // Fetch package details based on servicePackageId, serviceProviderServicePackageId, and spId
    final filterCriteria = PackageFilterCriteria(
        spId: spId,
        packageId: servicePackageId,
        serviceProviderServicePackageId: serviceProviderServicePackageId);
    print('Package filter criteria: $filterCriteria');

    final packages =
        await ref.watch(allPackagesProvider(filterCriteria).future);
    print('Fetched packages: ${packages.length}');

    final package = packages.firstWhere(
      (p) =>
          p.packageId == servicePackageId &&
          p.serviceProviderPackageId == serviceProviderServicePackageId &&
          p.packageServiceProviderId ==
              spId, // Ensures package matches spId as well
      orElse: () {
        print(
            'Package not found for servicePackageId: $servicePackageId, serviceProviderServicePackageId: $serviceProviderServicePackageId, spId: $spId');
        throw Exception('Package not found for the provided IDs');
      },
    );

    print('Found package: ${package.packageName}');
    return ServiceProviderItem.fromPackage(
      {
        'sp_id': package.packageServiceProviderId,
        'sp_name': package.serviceProviderNameOfPackage,
        'sp_image': package.packageServiceProviderImage,
        'package_id': package.packageId,
        'serviceprovider_package_id': package.serviceProviderPackageId,
        'package_name': package.packageName,
        'package_desc': package.packageDesc,
        'package_image': package.packageImage,
        'package_price': package.packagePrice,
        'package_size': package.packageSize,
        'min_weight': package.minWeight,
        'max_weight': package.maxWeight,
        'package_type': package.packageType,
        'pet_type': package.packagePetType,
      },
      package.packageId, // packageId as the second argument
      package
          .serviceProviderPackageId, // serviceProviderPackageId as the third argument
    );
  }
});
