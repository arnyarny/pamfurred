import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

Future<Map<String, dynamic>> fetchAppointmentDetails(String petOwnerId) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  final response = await supabase
      .rpc('get_appointment_details_with_services_and_packages', params: {
    'pet_owner_id_param': petOwnerId, // Pass petOwnerId as a parameter
  });

  // Convert the response to a list of maps
  final dataList = List<Map<String, dynamic>>.from(response);

  // Use a Set to keep track of unique appointment IDs
  final seenAppointmentIds = <dynamic>{};
  final uniqueAppointments = dataList.where((appointment) {
    final appointmentId = appointment['appointment_id'];
    if (seenAppointmentIds.contains(appointmentId)) {
      return false; // Skip duplicates
    } else {
      seenAppointmentIds.add(appointmentId);
      return true; // Keep unique appointment
    }
  }).toList();

  return {'appointments': uniqueAppointments};
}

// Function to fetch specific appointment details by appointment_id from the fetched list
Map<String, dynamic>? getAppointmentDetailsById(
    String appointmentId, Map<String, dynamic> appointmentsData) {
  final appointments =
      List<Map<String, dynamic>>.from(appointmentsData['appointments'] ?? []);
  return appointments.firstWhere(
    (appointment) => appointment['appointment_id'] == appointmentId,
    orElse: () => {},
  );
}

// Create a provider for fetching appointment details
final appointmentDetailsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return await fetchAppointmentDetails(ref.watch(userIdProvider).toString());
});

// Provider for fetching specific appointment details by appointment ID
final specificAppointmentDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
        (ref, appointmentId) async {
  final appointmentData = await ref.watch(appointmentDetailsProvider.future);
  return getAppointmentDetailsById(appointmentId, appointmentData);
});

// Packages in the appointment
Map<String, dynamic> processAppointmentDetails(
    Map<String, dynamic> appointment) {
  // Process inclusions to join them into a readable string, if required.
  final inclusions = List<String>.from(appointment['package_inclusions'] ?? []);
  return {
    ...appointment,
    'formatted_inclusions': inclusions.join(', '),
  };
}

final appointmentSpIndexProvider = Provider<Map<String, dynamic>?>((ref) {
  final allItems = ref.watch(appointmentDetailsProvider);
  final selectedSp = ref.watch(tappedSpAppointmentIdProvider);

  // Ensure we have data before accessing
  return allItems.maybeWhen(
    data: (items) {
      // Extract the list of appointments from the map
      final appointments = items['appointments'] as List<Map<String, dynamic>>?;

      // Check if appointments is not null, then apply firstWhere
      return appointments
          ?.firstWhere((item) => item['sp_id'].toString() == selectedSp);
    },
    orElse: () => null,
  );
});

Future<List<Map<String, dynamic>>> fetchAppointmentsForDate(ref) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  // Use ref to get sp_id
  final spId = ref.watch(selectedSpIndexProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  final response = await supabase.rpc('get_appointments_for_date', params: {
    'selected_date': selectedDate,
    'sp_id_param': spId,
  });

  return List<Map<String, dynamic>>.from(response as List);
}

final fetchAppointmentsPerDateProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, selectedDate) async {
  // Pass `ref` to the `fetchAppointmentsForDate` function
  return fetchAppointmentsForDate(ref);
});

final tappedSpAppointmentIdProvider = StateProvider<String>((ref) => '');

final selectedAppointmentIdProvider = StateProvider<String>((ref) => '');

// Handler to check if pet matches the pet type offered by service provider
final matchesPetType = StateProvider<bool>((ref) => true);

// Address providers for add new address
final addedFloorUnitRoomProvider = StateProvider<String?>((ref) => '');
final addedStreetProvider = StateProvider<String>((ref) => '');
final addedBarangayProvider = StateProvider<String>((ref) => '');
final addedCityProvider = StateProvider<String>((ref) => '');
final addedProvinceProvider = StateProvider<String>((ref) => '');
final addedAppointmentAddressProvider = StateProvider<String>((ref) => '');
