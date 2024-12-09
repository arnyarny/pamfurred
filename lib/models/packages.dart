import 'package:pamfurred/models/cart_item.dart';

class Package implements CartItem {
  const Package({
    required this.packageServiceProviderId,
    required this.serviceProviderNameOfPackage,
    required this.packageId,
    required this.serviceProviderPackageId,
    required this.packageName,
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
  });

  final String packageServiceProviderId;
  final String serviceProviderNameOfPackage;
  final String packageId;
  final String serviceProviderPackageId;
  final String packageName;
  final List<String> category;
  // final int minSize;
  // final dynamic maxSize;
  final int packagePrice;
  final String packageImage;
  final List<String> packageType;
  final List<String> packagePetType;
  final String packageSize;
  final double minWeight;
  final double maxWeight;

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
  String get name => packageName;

  @override
  List<String> get petType => packagePetType;

  @override
  String get size => packageSize;
}
