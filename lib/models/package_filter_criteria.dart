class PackageFilterCriteria {
  final String spId;
  final String? petType;
  final String? packageType;
  final String? packageCategory;
  final String? size;
  final double? weight;

  PackageFilterCriteria({
    required this.spId,
    this.petType,
    this.packageType,
    this.packageCategory,
    this.size,
    this.weight
  });
}