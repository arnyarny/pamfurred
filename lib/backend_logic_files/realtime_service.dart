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

    // Fetch existing processed appointment IDs and sent notification IDs from Supabase
    final Set<String> processedAppointmentIds =
        await _fetchProcessedAppointmentIds(loggedInPetOwnerId);
    final Set<String> sentNotificationIds =
        await _fetchSentNotificationIds(loggedInPetOwnerId);

    print(
        'Fetched existing processed appointment IDs and sent notification IDs from Supabase');

    // Listen to real-time updates in the 'appointment' table
    _client
        .from('appointment')
        .stream(primaryKey: ['appointment_id'])
        .eq('pet_owner_id', loggedInPetOwnerId)
        .listen(
          (changes) async {
            for (final change in changes) {
              final petOwnerId = change['pet_owner_id'];
              final appointmentId = change['appointment_id'];
              final appointmentStatus = change['appointment_status'];

              // Skip changes that are not updates or relevant to the logged-in service provider
              if (petOwnerId != loggedInPetOwnerId || appointmentId == null) {
                continue;
              }

              // If the appointment_id is already processed, it is an update (existing record)
              if (!processedAppointmentIds.contains(appointmentId)) {
                // Process 'Done' status
                if (appointmentStatus == 'Done') {
                  processedAppointmentIds.add(appointmentId);
                  _updateProcessedAppointmentIds(
                      loggedInPetOwnerId, processedAppointmentIds);
                  sendNotification(change, sentNotificationIds, 'done');
                }

                // Process 'Cancelled' status
                if (appointmentStatus == 'Cancelled') {
                  processedAppointmentIds.add(appointmentId);
                  _updateProcessedAppointmentIds(
                      loggedInPetOwnerId, processedAppointmentIds);
                  sendNotification(change, sentNotificationIds, 'cancelled');
                }
              }
            }
          },
          onError: (error) {
            print('Real-time stream error: $error');
          },
        );
  }

  Future<Set<String>> _fetchProcessedAppointmentIds(String userId) async {
    try {
      final response = await _client
          .from('user')
          .select('processed_appointment_ids')
          .eq('user_id', userId)
          .single();

      if (response != null &&
          response['processed_appointment_ids'] is List<dynamic>) {
        return (response['processed_appointment_ids'] as List<dynamic>)
            .cast<String>()
            .toSet();
      }
    } catch (e) {
      print('Error fetching processed appointment IDs: $e');
    }
    return {};
  }

  Future<Set<String>> _fetchSentNotificationIds(String userId) async {
    try {
      final response = await _client
          .from('user')
          .select('sent_notification_ids')
          .eq('user_id', userId)
          .single();

      if (response != null &&
          response['sent_notification_ids'] is List<dynamic>) {
        return (response['sent_notification_ids'] as List<dynamic>)
            .cast<String>()
            .toSet();
      }
    } catch (e) {
      print('Error fetching sent notification IDs: $e');
    }
    return {};
  }

  Future<void> _updateProcessedAppointmentIds(
      String userId, Set<String> processedAppointmentIds) async {
    try {
      final response = await _client.from('user').update({
        'processed_appointment_ids': processedAppointmentIds.toList(),
      }).eq('user_id', userId);

      if (response != null) {
        print('Error updating processed appointment IDs: ${response!.message}');
      }
    } catch (e) {
      print('Error updating processed appointment IDs: $e');
    }
  }

  Future<void> _updateSentNotificationIds(
      String userId, Set<String> sentNotificationIds) async {
    try {
      final response = await _client.from('user').update({
        'sent_notification_ids': sentNotificationIds.toList(),
      }).eq('user_id', userId);

      if (response != null) {
        print('Error updating sent notification IDs: ${response.message}');
      }
    } catch (e) {
      print('Error updating sent notification IDs: $e');
    }
  }

  void sendNotification(Map<String, dynamic> appointment,
      Set<String> sentNotificationIds, String notificationType) async {
    final userId = appointment['sp_id'];
    final appointmentId = appointment['appointment_id'];

    if (userId != null && appointmentId != null) {
      if (sentNotificationIds.contains(appointmentId)) {
        print('Notification already sent for appointment ID $appointmentId');
        return;
      }

      try {
        final response = await Supabase.instance.client
            .from('service_provider')
            .select('name')
            .eq('sp_id', userId)
            .single();

        if (response != null && response.isNotEmpty) {
          final name = response['name'] ?? 'Unknown User';

          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
            'appointment_channel',
            'Appointment Notifications',
            channelDescription: 'Notifications for appointment updates',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'pamfurred',
          );

          final uniqueNotificationId =
              (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

          final NotificationDetails details =
              NotificationDetails(android: androidDetails);

          String title = '';
          String body = '';

          if (notificationType == 'done') {
            title = 'Appointment Done';
            body = 'Your appointment with $name has been completed.';
          } else if (notificationType == 'cancelled') {
            title = 'Appointment Cancelled';
            body = 'Your appointment with $name has been cancelled.';
          }

          await flutterLocalNotificationsPlugin.show(
            uniqueNotificationId,
            title,
            body,
            details,
          );

          sentNotificationIds.add(appointmentId);
          _updateSentNotificationIds(userId, sentNotificationIds);

          print('Notification sent for appointment ID $appointmentId');
        }
      } catch (e) {
        print('Error sending notification: $e');
      }
    }
  }

  Future<void> saveSentNotificationIds() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        print('No logged-in user.');
        return;
      }

      final loggedInPetOwnerId = currentUser.id;

      // Fetch the sent notification IDs to ensure you're adding to the existing list
      final Set<String> sentNotificationIds =
          await _fetchSentNotificationIds(loggedInPetOwnerId);

      await _updateSentNotificationIds(loggedInPetOwnerId, sentNotificationIds);

      print('Sent notification IDs saved successfully.');
    } catch (e) {
      print('Error saving sent notification IDs: $e');
    }
  }
}
