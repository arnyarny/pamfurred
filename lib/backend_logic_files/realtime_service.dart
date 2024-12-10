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

    print('Start listening to real-time updates');
// Listen to real-time updates in the 'appointment' table
    _client
        .from('notification_with_appointment')
        .stream(primaryKey: ['notification_id'])
        .eq('pet_owner_id', loggedInPetOwnerId)
        .listen(
          (changes) async {
            for (final change in changes) {
              final notificationId = change['notification_id'];
              final appointmentNotifType = change['appointment_notif_type'];
              final appointmentId = change['appointment_id'];
              print('\nNotification ID: $notificationId');
              print('\nNotiftype: $appointmentNotifType');

              if (appointmentNotifType == 'Done' ||
                  appointmentNotifType == 'Cancelled') {
                await _createNotification(
                    notificationId, appointmentNotifType, appointmentId);
              }
            }
          },
          onError: (error) {
            print('Real-time stream error: $error');
          },
        );
  }

  Future<void> _createNotification(String notificationId,
      String notificationType, String appointmentId) async {
    try {
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

      print('Notification sent for notification ID $notificationId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
