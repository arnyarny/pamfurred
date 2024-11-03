class ServiceFilterCriteria {
  final String spId;
  final List<String>? petType;
  final List<String>? serviceType;
  final List<String>? serviceCategory;
  final String? size;

  ServiceFilterCriteria({
    required this.spId,
    this.petType,
    this.serviceType,
    this.serviceCategory,
    this.size,
  });
}
