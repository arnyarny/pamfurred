class ServiceProviderItem {
  final String spId;
  final String spName;
  final String spImage;
  final String servicePackageId;
  final String serviceProviderServicePackageId;
  final String name;
  final String servicePackageDesc;
  final String categoryName;
  final String type;
  final String imageUrl;
  final int price;
  final num averageRating;
  final double latitude;
  final double longitude;
  final String sentimentLabel;

  // Added properties
  final String size; // Size of the service/package (if applicable)
  final int minWeight; // Minimum weight
  final int maxWeight; // Maximum weight
  final List<dynamic> petType;
  final List<dynamic> servicePackageType;

  ServiceProviderItem({
    required this.spId,
    required this.spName,
    required this.spImage,
    required this.servicePackageId,
    required this.serviceProviderServicePackageId,
    required this.name,
    required this.servicePackageDesc,
    required this.categoryName,
    required this.type,
    required this.imageUrl,
    required this.price,
    required this.averageRating,
    required this.latitude,
    required this.longitude,
    required this.sentimentLabel,
    required this.size,
    required this.minWeight,
    required this.maxWeight,
    required this.petType,
    required this.servicePackageType,
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
        spImage: service['sp_image'] ?? '',
        servicePackageId: service['service_id'] ?? '',
        serviceProviderServicePackageId:
            service['serviceprovider_service_id'] ?? '',
        name: service['service_name'] ?? 'Unnamed Service',
        servicePackageDesc: service['service_desc'] ?? '',
        categoryName: service['category_name'] ?? 'Unknown category',
        type: 'service',
        imageUrl: service['service_image'] ?? 'https://tinyurl.com/55w8ht23',
        price: service['service_price'],
        averageRating: service['average_rating'] ?? 0.0,
        latitude: service['latitude'] ?? 0.0,
        longitude: service['longitude'] ?? 0.0,
        sentimentLabel: service['sentiment_label'] ?? '',
        size: service['service_size'] ?? '',
        minWeight: service['min_weight'] ?? 0,
        maxWeight: service['max_weight'] ?? 0,
        petType: service['pet_type'] ?? [],
        servicePackageType: service['service_type_service'] ?? [],
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
        spImage: package['sp_image'] ?? '',
        servicePackageId: package['package_id'] ?? '',
        serviceProviderServicePackageId:
            package['serviceprovider_package_id'] ?? '',
        name: package['package_name'] ?? 'Unnamed Package',
        servicePackageDesc: package['package_desc'] ?? '',
        categoryName: package['category_name'] ?? 'Unknown category',
        type: 'package',
        imageUrl: package['package_image'] ?? 'https://tinyurl.com/55w8ht23',
        price: package['package_price'],
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
        petType:
            package['pet_type'] ?? [], // Fetch the pet_type based on package_id
        servicePackageType: package['package_type'] ?? [],
      );
    } else {
      throw Exception(
          'Package data does not match the given package_id and serviceprovider_package_id');
    }
  }
}
