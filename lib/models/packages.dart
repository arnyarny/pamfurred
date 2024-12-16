import 'package:pamfurred/models/cart_item.dart';

class Package implements CartItem {
  const Package(
      {required this.packageServiceProviderId,
      required this.serviceProviderNameOfPackage,
      required this.packageServiceProviderImage,
      required this.packageId,
      required this.serviceProviderPackageId,
      required this.packageName,
      this.packageDesc,
      required this.category,
      // required this.minSize,
      // required this.maxSize,
      required this.packagePrice,
      required this.packageImage,
      required this.packageType,
      required this.packagePetType,
      required this.packageSize,
      required this.minWeight,
      required this.maxWeight,
      this.inclusions});

  final String packageServiceProviderId;
  final String serviceProviderNameOfPackage;
  final String packageServiceProviderImage;
  final String packageId;
  final String serviceProviderPackageId;
  final String packageName;
  final String? packageDesc;
  final String category;
  final int packagePrice;
  final String packageImage;
  final List<String> packageType;
  final List<String> packagePetType;
  final String packageSize;
  final int minWeight;
  final int maxWeight;
  final List<dynamic>? inclusions;

  // Override the CartItem getters
  @override
  String get serviceProviderId => packageServiceProviderId;

  @override
  String get serviceProviderName => serviceProviderNameOfPackage;

  @override
  String get id => packageId;

  @override
  String get servicePackageDetailsId => serviceProviderPackageId;

  @override
  int get price => packagePrice;

  @override
  String get image => packageImage;

  @override
  List<String> get servicePackageType => packageType;

  @override
  String get name => packageName;

  @override
  String get servicePackageDesc => packageDesc!;

  @override
  List<String> get petType => packagePetType;

  @override
  String get size => packageSize;
}
