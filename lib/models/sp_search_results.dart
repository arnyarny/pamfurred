class ServiceProviderItem {
  final String spId;
  final String spName;
  final String servicePackageId;
  final String name;
  final String type;
  final String imageUrl;
  final int price;
  final num averageRating;
  final double latitude;
  final double longitude;
  final String sentimentLabel;

  ServiceProviderItem(
      {required this.spId,
      required this.spName,
      required this.servicePackageId,
      required this.name,
      required this.type,
      required this.imageUrl,
      required this.price,
      required this.averageRating,
      required this.latitude,
      required this.longitude,
      required this.sentimentLabel});

  // Factory constructor to create an instance from a map
  factory ServiceProviderItem.fromService(Map<String, dynamic> service) {
    return ServiceProviderItem(
      spId: service['sp_id'],
      spName: service['name'],
      servicePackageId: service['service_id'],
      name: service['service_name'],
      type: 'service',
      imageUrl: service['service_image'] ?? 'https://tinyurl.com/55w8ht23',
      price: service['service_price'],
      averageRating: service['average_rating'],
      latitude: service['latitude'],
      longitude: service['longitude'],
      sentimentLabel: service['sentiment_label'],
    );
  }

  factory ServiceProviderItem.fromPackage(Map<String, dynamic> package) {
    return ServiceProviderItem(
      spId: package['sp_id'],
      spName: package['name'],
      servicePackageId: package['package_id'],
      name: package['package_name'],
      type: 'package',
      imageUrl: package['package_image'],
      price: package['package_price'],
      averageRating: package['average_rating'],
      latitude: package['latitude'],
      longitude: package['longitude'],
      sentimentLabel: package['sentiment_label'],
    );
  }
}
