import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/notifications_provider.dart';
// import 'package:pamfurred/components/custom_appbar.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Details')),
      body: Consumer(
        builder: (context, ref, child) {
          final notificationDetails = ref.watch(selectedNotificationIdProvider);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Title: ${notificationDetails['title']}',
                //   style: const TextStyle(
                //       fontSize: 20, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 10),
                Text('Notification ID: $notificationDetails'),
                const SizedBox(height: 10),
                // Text('Created At: ${notificationDetails['created_at']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
