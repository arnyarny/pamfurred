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

          return specificAppointmentDetails.when(
            data: (data) {
              if (data == null) {
                return const Center(child: Text('No details available.'));
              }

              final appointmentDate =
                  data['appointment_date'] ?? 'Not available';

              return SingleChildScrollView(
                // Wrap the body in a SingleChildScrollView to avoid overflow
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard('Appointment ID', appointmentId),
                    const SizedBox(height: 12),
                    _buildDetailCard('Appointment Date',
                        secondaryFormatDate(appointmentDate)),
                    const SizedBox(height: 12),
                    _buildDetailCard('Appointment Time',
                        formatTime(data['appointment_time'])),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                        'Service Provider', data['establishment_name']),
                    const SizedBox(height: 12),
                    _buildDetailCard('Pet Name', data['pet_name']),
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

  Widget _buildDetailCard(String label, String value) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // Use Expanded to prevent overflow when text is too long
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                overflow:
                    TextOverflow.ellipsis, // Ensure the label does not overflow
              ),
            ),
            Expanded(
              // Use Expanded to prevent overflow for value
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                overflow:
                    TextOverflow.ellipsis, // Ensure the value does not overflow
              ),
            ),
          ],
        ),
      ),
    );
  }
}
