import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;

  void listenToAppointments() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      print('No logged-in user.');
      return;
    }

    final loggedInPetOwnerId = currentUser.id;

    // Listen to real-time updates in the 'appointment' table
    _client
        .from('appointment')
        .stream(primaryKey: ['appointment_id'])
        .eq('pet_owner_id', loggedInPetOwnerId)
        .listen(
          (changes) async {
            for (final change in changes) {
              final appointmentId = change['appointment_id'];
              final appointmentStatus = change['appointment_status'];

              if (appointmentId == null) continue;

              // Process 'Done' status
              if (appointmentStatus == 'Done') {
                await _createNotification(appointmentId, 'Done');
              }

              // Process 'Cancelled' status
              if (appointmentStatus == 'Cancelled') {
                await _createNotification(appointmentId, 'Cancelled');
              }
            }
          },
          onError: (error) {
            print('Real-time stream error: $error');
          },
        );
  }

  Future<void> _createNotification(
      String appointmentId, String notificationType) async {
    try {
      // Check if a notification already exists for this appointment and type
      final existingNotification = await _client
          .from('notification')
          .select('notification_id')
          .eq('appointment_id', appointmentId)
          .eq('appointment_notif_type',
              notificationType) // Corrected column name
          .maybeSingle();

      if (existingNotification != null) {
        print('Notification already exists for appointment ID $appointmentId');
        return;
      }

      // Create a new notification in the 'notification' table
      await _client.from('notification').insert({
        'appointment_id': appointmentId,
        'appointment_notif_type': notificationType, // Corrected column name
        'created_at': DateTime.now().toIso8601String(),
      });

      // Fetch related service provider details for notification content
      final appointment = await _client
          .from('appointment')
          .select('sp_id, service_provider(name)')
          .eq('appointment_id', appointmentId)
          .single();

      if (appointment == null) {
        print('Appointment or service provider details not found.');
        return;
      }

      final serviceProviderName =
          appointment['service_provider']['name'] ?? 'Unknown';

      // Prepare notification content
      String title = '';
      String body = '';

      if (notificationType == 'Done') {
        title = 'Appointment Done';
        body = 'Your appointment with $serviceProviderName has been completed.';
      } else if (notificationType == 'Cancelled') {
        title = 'Appointment Cancelled';
        body = 'Your appointment with $serviceProviderName has been cancelled.';
      }

      // Display the notification
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Notifications',
        channelDescription: 'Notifications for appointment updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'pamfurred',
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      final uniqueNotificationId =
          (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

      await flutterLocalNotificationsPlugin.show(
        uniqueNotificationId,
        title,
        body,
        details,
      );

      print('Notification sent for appointment ID $appointmentId');
    } catch (e) {
      print('Error creating notification: $e');
    }
  }
}
