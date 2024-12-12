class ServiceFilterCriteria {
  final String? spId;
  final String? serviceId;
  final String? serviceProviderServicePackageId;
  final String? petType;
  final String? serviceType;
  final String? serviceCategory;
  final String? size;
  final double? weight;

  ServiceFilterCriteria(
      {this.spId,
      this.serviceId,
      this.serviceProviderServicePackageId,
      this.petType,
      this.serviceType,
      this.serviceCategory,
      this.size,
      this.weight});
}
