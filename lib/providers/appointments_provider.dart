import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>> fetchAppointmentDetails() async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase.rpc('get_appointment_details_with_services_and_packages');

  // Convert the response to a List<Map<String, dynamic>>
  final dataList = List<Map<String, dynamic>>.from(response);
  if (dataList.isEmpty) {
    throw Exception('No appointment details found.');
  }

  // Return the data as a Map with the key 'appointments'
  return {'appointment': dataList};
}
