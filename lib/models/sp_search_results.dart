class ServiceProviderItem {
  final String spName;
  final String name;
  final String type;
  final String imageUrl;
  final int price;
  final double averageRating;
  final double latitude;
  final double longitude;
  final String sentimentLabel;

  ServiceProviderItem(
      {required this.spName,
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
      spName: service['name'],
      name: service['service_name'],
      type: 'service',
      imageUrl: service['service_image'],
      price: service['service_price'],
      averageRating: service['average_rating'],
      latitude: service['latitude'],
      longitude: service['longitude'],
      sentimentLabel: service['sentiment_label'],
    );
  }

  factory ServiceProviderItem.fromPackage(Map<String, dynamic> package) {
    return ServiceProviderItem(
      spName: package['name'],
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
