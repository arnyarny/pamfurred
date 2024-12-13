import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define a model for the service
class AppointmentService {
  final String? serviceId;
  final String serviceName;
  final num servicePrice;
  final String serviceProviderServiceId;

  AppointmentService({
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceProviderServiceId,
  });

  factory AppointmentService.fromJson(Map<String, dynamic> json) {
    return AppointmentService(
      serviceId: json['service_id'],
      serviceName: json['service_name'] ?? '',
      servicePrice: json['service_price'] ?? 0.0,
      serviceProviderServiceId: json['serviceprovider_service_id'] ?? '',
    );
  }

  // Service is valid if serviceId is not null
  bool get isValid => serviceId != null;
}

class AppointmentPackage {
  final String? packageId;
  final String packageName;
  final num packagePrice;
  final String serviceProviderPackageId;

  AppointmentPackage({
    required this.packageId,
    required this.packageName,
    required this.packagePrice,
    required this.serviceProviderPackageId,
  });

  factory AppointmentPackage.fromJson(Map<String, dynamic> json) {
    return AppointmentPackage(
      packageId: json['package_id'],
      packageName: json['package_name'] ?? '',
      packagePrice: json['package_price'] ?? 0.0,
      serviceProviderPackageId: json['serviceprovider_package_id'] ?? '',
    );
  }

  // Package is valid if packageId is not null
  bool get isValid => packageId != null;
}

final servicesForAppointmentProvider =
    FutureProvider.family<List<AppointmentService>, String>(
        (ref, appointmentId) async {
  final response = await Supabase.instance.client.rpc(
      'get_services_for_appointment',
      params: {'appointment_id_param': appointmentId});

  print('Services Response: $response');

  if (response == null) throw Exception('No data for services');
  return (response as List<dynamic>)
      .map((item) => AppointmentService.fromJson(item))
      .where((service) => service.isValid)
      .toList();
});

final packagesForAppointmentProvider =
    FutureProvider.family<List<AppointmentPackage>, String>(
        (ref, appointmentId) async {
  final response = await Supabase.instance.client.rpc(
      'get_packages_for_appointment',
      params: {'appointment_id_param': appointmentId});

  print('Packages Response: $response');
  if (response == null) throw Exception('No data for packages');
  return (response as List<dynamic>)
      .map((item) => AppointmentPackage.fromJson(item))
      .where((package) => package.isValid)
      .toList();
});

// Combine both services and packages
final appointmentServicesAndPackagesProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, appointmentId) async {
  try {
    final services =
        await ref.watch(servicesForAppointmentProvider(appointmentId).future);
    final packages =
        await ref.watch(packagesForAppointmentProvider(appointmentId).future);

    print('Services: $services');
    print('Packages: $packages');

    return {
      'services': services,
      'packages': packages,
    };
  } catch (e) {
    print('Error fetching combined details: $e');
    throw Exception('Failed to fetch combined details');
  }
});

final totalAmountProvider = StateProvider<String>((ref) => '');
