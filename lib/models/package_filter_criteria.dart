class PackageFilterCriteria {
  final String spId;
  final List<String>? petType;
  final List<String>? packageType;
  final List<String>? packageCategory;
  final String? size;

  PackageFilterCriteria({
    required this.spId,
    this.petType,
    this.packageType,
    this.packageCategory,
    this.size,
  });
}
