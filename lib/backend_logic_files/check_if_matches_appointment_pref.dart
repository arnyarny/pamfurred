Future<bool> doesAppointmentMatchCriteria(
  List<String> servicePackagePetType,
  List<String> selectedAppointmentPackageServiceType,
  String appointmentPetTypeProvider,
  String servicePackageTypeProvider,
  int servicePackageMinWeight,
  int servicePackageMaxWeight,
  double selectedPetWeightProvider,
) async {
  // Print initial input values for debugging
  print('Service Package Pet Types: $servicePackagePetType');
  print(
      'Selected Appointment Package Service Types: $selectedAppointmentPackageServiceType');
  print('Appointment Pet Type Provider: $appointmentPetTypeProvider');
  print('Service Package Type Provider: $servicePackageTypeProvider');
  print('Service Package Min Weight: $servicePackageMinWeight');
  print('Service Package Max Weight: $servicePackageMaxWeight');
  print('Selected Pet Weight Provider: $selectedPetWeightProvider');

  // Check if all criteria match and print intermediate results
  bool isPetTypeValid =
      servicePackagePetType.contains(appointmentPetTypeProvider);
  print('Pet Type Valid: $isPetTypeValid');

  bool isWeightValid = selectedPetWeightProvider >= servicePackageMinWeight &&
      selectedPetWeightProvider <= servicePackageMaxWeight;
  print('Weight Valid: $isWeightValid');

  bool isServiceTypeValid = selectedAppointmentPackageServiceType
      .contains(servicePackageTypeProvider);
  print('Service Type Valid: $isServiceTypeValid');

  // Return true if all criteria match
  bool doesMatch =
      isPetTypeValid && isWeightValid && isServiceTypeValid;
  print('Does Appointment Match Criteria: $doesMatch');
  

  return doesMatch;
}
