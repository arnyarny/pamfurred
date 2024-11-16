import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

Future<Map<String, dynamic>> fetchAppointmentDetails(String petOwnerId) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  final response = await supabase
      .rpc('get_appointment_details_with_services_and_packages', params: {
    'pet_owner_id_param': petOwnerId, // Pass petOwnerId as a parameter
  });

  final dataList = List<Map<String, dynamic>>.from(response);

  return {'appointments': dataList};
}

// Create a provider for fetching appointment details
final appointmentDetailsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return await fetchAppointmentDetails(ref.watch(userIdProvider).toString());
});

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

final tappedSpAppointmentIdProvider = StateProvider<String>((ref) => '');
