class PackageFilterCriteria {
  final String spId;
  final String? packageId;
  final String? petType;
  final String? packageType;
  final String? packageCategory;
  final String? size;
  final double? weight;

  PackageFilterCriteria(
      {required this.spId,
      this.packageId,
      this.petType,
      this.packageType,
      this.packageCategory,
      this.size,
      this.weight});
}
