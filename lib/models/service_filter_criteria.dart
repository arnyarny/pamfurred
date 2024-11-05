class ServiceFilterCriteria {
  final String spId;
  final String? serviceId;
  final List<String>? petType;
  final List<String>? serviceType;
  final List<String>? serviceCategory;
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
