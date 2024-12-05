class ServiceFilterCriteria {
  final String spId;
  final String? serviceId;
  final String? petType;
  final String? serviceType;
  final String? serviceCategory;
  final double? weight;

  ServiceFilterCriteria(
      {required this.spId,
      this.serviceId,
      this.petType,
      this.serviceType,
      this.serviceCategory,
      this.weight});
}
