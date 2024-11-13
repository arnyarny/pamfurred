class ServiceFilterCriteria {
  final String spId;
  final String? serviceId;
  final String? petType;
  final String? serviceType;
  final String? serviceCategory;
  final String? size;

  ServiceFilterCriteria({
    required this.spId,
    this.serviceId,
    this.petType,
    this.serviceType,
    this.serviceCategory,
    this.size,
  });
}
