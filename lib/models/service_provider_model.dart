class ServiceProviders {
  final String userId;
  final String image;
  final String name;
  final double rating;
  final String category;
  final double latitude;
  final double longitude;
  final String sentimentLabel;
  final String userType; // Add userType to capture from the nested user table

  ServiceProviders({
    required this.userId,
    required this.image,
    required this.name,
    required this.rating,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.sentimentLabel,
    required this.userType,
  });

  factory ServiceProviders.fromMap(Map<String, dynamic> map) {
    return ServiceProviders(
      userId: map['user_id'].toString(),
      image: map['image'],
      name: map['name'],
      rating: map['rating'],
      category: map['category'],
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      sentimentLabel: map['sentiment_label'] ?? 'N/A',
      userType: map['user']?['user_type'] ??
          'Unknown', // Access user_type from nested user data
    );
  }
}
