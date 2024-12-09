class ServiceProviderItem {
  final String spId;
  final String spName;
  final String servicePackageId;
  final String serviceProviderServicePackageId;
  final String name;
  final String categoryName;
  final String type;
  final String imageUrl;
  final num price;
  final num averageRating;
  final double latitude;
  final double longitude;
  final String sentimentLabel;

  // Added properties
  final String size; // Size of the service/package (if applicable)
  final num minWeight; // Minimum weight for the service
  final num maxWeight; // Maximum weight for the service

  ServiceProviderItem(
      {required this.spId,
      required this.spName,
      required this.servicePackageId,
      required this.serviceProviderServicePackageId,
      required this.name,
      required this.categoryName,
      required this.type,
      required this.imageUrl,
      required this.price,
      required this.averageRating,
      required this.latitude,
      required this.longitude,
      required this.sentimentLabel,
      required this.size, // Size is now required in constructor
      required this.minWeight, // Minimum weight is now required
      required this.maxWeight // Maximum weight is now required
      });

  // Factory constructor to create an instance from a service map
  factory ServiceProviderItem.fromService(
      Map<String, dynamic> service, String serviceId, String spServiceId) {
    print("Creating ServiceProviderItem from service...");
    print("Service data: $service");

    if (service['service_id'] == serviceId &&
        service['serviceprovider_service_id'] == spServiceId) {
      print("Matching service ID and SP service ID");
      return ServiceProviderItem(
        spId: service['sp_id'] ?? '',
        spName: service['sp_name'] ?? 'Unknown SP Name',
        servicePackageId: service['service_id'] ?? '',
        serviceProviderServicePackageId:
            service['serviceprovider_service_id'] ?? '',
        name: service['service_name'] ?? 'Unnamed Service',
        categoryName: service['category_name'] ?? 'Unknown category',
        type: 'service',
        imageUrl: service['service_image'] ?? 'https://tinyurl.com/55w8ht23',
        price: service['service_price'] ?? 0,
        averageRating: service['average_rating'] ?? 0.0,
        latitude: service['latitude'] ?? 0.0,
        longitude: service['longitude'] ?? 0.0,
        sentimentLabel: service['sentiment_label'] ?? '',
        size: service['service_size'] ?? '', // Log this
        minWeight: service['min_weight'] ?? 0,
        maxWeight: service['max_weight'] ?? 0,
      );
    } else {
      print("Service data does not match given IDs");
      throw Exception(
          'Service data does not match the given service_id and serviceprovider_service_id');
    }
  }

  // Factory constructor to create an instance from a package map
  factory ServiceProviderItem.fromPackage(
      Map<String, dynamic> package, String packageId, String spPackageId) {
    // Ensure that the data corresponds to both package_id and serviceprovider_package_id
    if (package['package_id'] == packageId &&
        package['serviceprovider_package_id'] == spPackageId) {
      return ServiceProviderItem(
        spId: package['sp_id'] ?? '',
        spName: package['sp_name'] ?? 'Unknown SP Name',
        servicePackageId: package['package_id'] ?? '',
        serviceProviderServicePackageId:
            package['serviceprovider_package_id'] ?? '',
        name: package['package_name'] ?? 'Unnamed Package',
        categoryName: package['category_name'] ?? 'Unknown category',
        type: 'package',
        imageUrl: package['package_image'] ?? 'https://tinyurl.com/55w8ht23',
        price: package['package_price'] ?? 0,
        averageRating: package['average_rating'] ?? 0.0,
        latitude: package['latitude'] ?? 0.0,
        longitude: package['longitude'] ?? 0.0,
        sentimentLabel: package['sentiment_label'] ?? '',
        size: package['package_size'] ??
            '', // Fetch the size based on package_id and serviceprovider_package_id
        minWeight: package['min_weight'] ??
            0, // Fetch the min_weight based on package_id and serviceprovider_package_id
        maxWeight: package['max_weight'] ??
            0, // Fetch the max_weight based on package_id and serviceprovider_package_id
      );
    } else {
      throw Exception(
          'Package data does not match the given package_id and serviceprovider_package_id');
    }
  }
}
