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
      await _client
          .from('notification')
          .select('notification_id')
          .eq('appointment_id', appointmentId)
          .eq('appointment_notif_type',
              notificationType) // Corrected column name
          .maybeSingle();

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

// Display the notification with expanded text support
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'appointment_channel', // Channel ID
        'Appointment Notifications', // Channel Name
        channelDescription:
            'Notifications for appointment updates', // Channel Description
        importance: Importance.max, // Max importance for prominent display
        priority: Priority.max, // Max priority
        styleInformation: BigTextStyleInformation(
          body, // Full text for expanded view
          contentTitle: title, // Title in expanded view
        ),
        icon: 'pamfurred', // Notification icon
      );

      final NotificationDetails details =
          NotificationDetails(android: androidDetails);

// Generate a unique notification ID
      final uniqueNotificationId =
          (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

// Show the notification
      await flutterLocalNotificationsPlugin.show(
        uniqueNotificationId, // Unique notification ID
        title, // Title for collapsed view
        body, // Body for collapsed view
        details, // Notification details
      );

      print('Notification sent for appointment ID $appointmentId');
    } catch (e) {
      print('Skipping notifications, already sent');
    }
  }
}
