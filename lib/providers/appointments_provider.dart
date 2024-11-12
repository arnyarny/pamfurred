import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>> fetchAppointmentDetails(String petOwnerId) async {
  final supabase = Supabase.instance.client;

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
