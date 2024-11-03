import 'package:pamfurred/models/cart_item.dart';

class Package implements CartItem {
  const Package(
      {required this.packageServiceProviderId,
      required this.packageId,
      required this.packageName,
      required this.category,
      // required this.minSize,
      // required this.maxSize,
      required this.packagePrice,
      required this.packageImage,
      required this.packageType,
      required this.petType,
      required this.packageSize});

  final String packageServiceProviderId;
  final String packageId;
  final String packageName;
  final List<String> category;
  // final int minSize;
  // final dynamic maxSize;
  final int packagePrice;
  final String packageImage;
  final List<String> packageType;
  final List<String> petType;
  final String packageSize;

  // Override the CartItem getters
  @override
  String get serviceProviderId => packageServiceProviderId;

  @override
  String get id => packageId;

  @override
  int get price => packagePrice;

  @override
  String get image => packageImage;

  @override
  String get name => packageName;
}
