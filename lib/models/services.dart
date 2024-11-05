import 'package:pamfurred/models/cart_item.dart';

class Service implements CartItem {
  const Service({
    required this.serviceServiceProviderId,
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.servicePrice,
    required this.serviceImage,
    required this.serviceType,
    required this.servicePetType,
    required this.serviceSize,
  });
  final String serviceServiceProviderId;
  final String serviceId;
  final String serviceName;
  final List<String> category;
  final int servicePrice;
  final String serviceImage;
  final List<String> serviceType;
  final List<String> servicePetType;
  final String serviceSize;

  // Override the CartItem getters
  @override
  String get serviceProviderId => serviceServiceProviderId;

  @override
  String get id => serviceId;

  @override
  int get price => servicePrice;

  @override
  String get image => serviceImage;

  @override
  String get name => serviceName;

  @override
  List<String> get petType => servicePetType;

  @override
  String get size => serviceSize;
}
