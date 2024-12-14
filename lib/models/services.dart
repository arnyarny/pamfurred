import 'package:pamfurred/models/cart_item.dart';

class Service implements CartItem {
  const Service({
    required this.serviceServiceProviderId,
    required this.serviceProviderNameOfService,
    required this.serviceServiceProviderImage,
    required this.serviceId,
    required this.serviceProviderServiceId,
    required this.serviceName,
    this.serviceDesc,
    required this.category,
    required this.servicePrice,
    required this.serviceImage,
    required this.serviceType,
    required this.servicePetType,
    required this.serviceSize,
    required this.minWeight,
    required this.maxWeight,
  });
  final String serviceServiceProviderId;
  final String serviceProviderNameOfService;
  final String serviceServiceProviderImage;
  final String serviceId;
  final String serviceProviderServiceId;
  final String serviceName;
  final String? serviceDesc;
  final List<String> category;
  final int servicePrice;
  final String serviceImage;
  final List<String> serviceType;
  final List<String> servicePetType;
  final String serviceSize;
  final int minWeight;
  final int maxWeight;

  // Override the CartItem getters
  @override
  String get serviceProviderId => serviceServiceProviderId;

  @override
  String get serviceProviderName => serviceProviderNameOfService;

  @override
  String get id => serviceId;

  @override
  String get servicePackageDetailsId => serviceProviderServiceId;

  @override
  int get price => servicePrice;

  @override
  String get image => serviceImage;

  @override
  List<String> get servicePackageType => serviceType;

  @override
  String get name => serviceName;

  @override
  String get servicePackageDesc => serviceDesc!;

  @override
  List<String> get petType => servicePetType;

  @override
  String get size => serviceSize;
}
