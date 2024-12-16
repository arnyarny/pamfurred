Future<bool> doesAppointmentMatchCriteria(
  List<String> servicePackagePetType,
  List<String> selectedAppointmentPackageServiceType,
  String appointmentPetTypeProvider,
  String servicePackageTypeProvider,
  int servicePackageMinWeight,
  int servicePackageMaxWeight,
  double selectedPetWeightProvider,
) async {
  // Check if all criteria match and print intermediate results
  bool isPetTypeValid =
      servicePackagePetType.contains(appointmentPetTypeProvider);

  bool isWeightValid = selectedPetWeightProvider >= servicePackageMinWeight &&
      selectedPetWeightProvider <= servicePackageMaxWeight;

  bool isServiceTypeValid = selectedAppointmentPackageServiceType
      .contains(servicePackageTypeProvider);
  // Return true if all criteria match
  bool doesMatch = isPetTypeValid && isWeightValid && isServiceTypeValid;

  return doesMatch;
}
