import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/providers/appointments_provider.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarWithTitle(context, 'Appointment Details'),
      backgroundColor: Colors.white,
      body: Consumer(
        builder: (context, ref, child) {
          final appointmentId = ref.watch(tappedSpAppointmentIdProvider);

          if (appointmentId == '' || appointmentId.isEmpty) {
            return const Center(child: Text('No appointment selected.'));
          }

          final specificAppointmentDetails =
              ref.watch(specificAppointmentDetailsProvider(appointmentId));

          print(specificAppointmentDetails);

          return specificAppointmentDetails.when(
            data: (data) {
              if (data == null) {
                return const Center(child: Text('No details available.'));
              }

              final appointmentDate =
                  data['appointment_date'] ?? 'Not available';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appointment ID: $appointmentId'),
                    const SizedBox(height: 10),
                    Text(
                        'Appointment Date: ${secondaryFormatDate(appointmentDate)}'),
                    const SizedBox(height: 10),
                    Text(
                        'Appointment Time: ${formatTime(data['appointment_time'])}'),
                    const SizedBox(height: 10),
                    Text('Service provider: ${data['establishment_name']}'),
                    const SizedBox(height: 10),
                    Text('Pet name: ${data['pet_name']}'),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Error: $error'),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
