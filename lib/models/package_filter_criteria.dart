class PackageFilterCriteria {
  final String? spId;
  final String? packageId;
  final String? serviceProviderServicePackageId;
  final String? petType;
  final String? packageType;
  final String? packageCategory;
  final String? size;
  final double? weight;

  PackageFilterCriteria(
      {this.spId,
      this.packageId,
      this.serviceProviderServicePackageId,
      this.petType,
      this.packageType,
      this.packageCategory,
      this.size,
      this.weight});
}
