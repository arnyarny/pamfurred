// appointment_service.dart

import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentService {
  final SupabaseClient supabaseClient;

  AppointmentService(this.supabaseClient);

  Future<String?> cancelAppointment({required String appointmentId}) async {
    try {
      // Set loading to true before starting the appointment cancellation
      // This part might be handled in your UI (setState or other methods)

      final response = await supabaseClient
          .from('appointment')
          .update({'appointment_status': 'Cancelled'})
          .eq('appointment_id', appointmentId)
          .select('appointment_id')
          .single();

      final updatedAppointmentId = response['appointment_id'];

      final insertNotif = await supabaseClient
          .from('notification')
          .insert({
            'created_at': getFormattedDate(),
            'appointment_id': updatedAppointmentId,
            'appointment_notif_type': 'Cancelled'
          })
          .select('notification_id')
          .single();

      final notifId = insertNotif['notification_id'];
      print('Appointment updated with ID: $updatedAppointmentId');
      print('Notification inserted with ID: $notifId');

      // Set loading to false once the operation is complete

      return updatedAppointmentId;
    } catch (e) {
      print("Error canceling appointment: $e");
      return null;
    }
  }
}
