  // Function to insert a new notification into the notification table
  import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> insertNotification({required String appointmentId, required String appointmentNotifType}) async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('notification').insert({
      'appointment_id': appointmentId,
      'appointment_notif_type': appointmentNotifType, // Or any type based on your logic
      'created_at':
          DateTime.now().toUtc().toIso8601String(), // Current timestamp in UTC
    });
    if (response != null) {
      print('Notification inserted successfully');
    }
  }