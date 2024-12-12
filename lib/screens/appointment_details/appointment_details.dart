import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/appointment_services_and_packages.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/screens/appointment/appointment_components/components.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentDetailsScreen extends ConsumerStatefulWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  ConsumerState<AppointmentDetailsScreen> createState() =>
      AppointmentDetailsScreenState();
}

class AppointmentDetailsScreenState
    extends ConsumerState<AppointmentDetailsScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appointmentId = ref.watch(tappedSpAppointmentIdProvider);
    if (appointmentId.isEmpty) {
      return const Center(child: Text('No appointment selected.'));
    }

    final specificAppointmentDetails =
        ref.watch(specificAppointmentDetailsProvider(appointmentId));
    final combinedDetails =
        ref.watch(appointmentServicesAndPackagesProvider(appointmentId));

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: customAppBarWithTitle(context, 'Appointment Details'),
          body: specificAppointmentDetails.when(
            data: (details) {
              return combinedDetails.when(
                data: (combined) {
                  final services =
                      (combined['services'] as List<AppointmentService>?) ?? [];
                  final packages =
                      (combined['packages'] as List<AppointmentPackage>?) ?? [];

                  final appointmentDate =
                      details?['appointment_date'].toString();
                  final appointmentTime =
                      details?['appointment_time'].toString();

                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Center(
                      child: SizedBox(
                        width: screenPadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: tertiarySizedBox),
                            getAppointmentTitle(context, 'Service provider'),
                            const SizedBox(height: primarySizedBox),
                            getAppointmentDetail(
                                context, details?['establishment_name']),
                            const SizedBox(height: tertiarySizedBox),
                            getAppointmentTitle(context, 'Pet name'),
                            const SizedBox(height: primarySizedBox),
                            getAppointmentDetail(context, details?['pet_name']),
                            const SizedBox(height: tertiarySizedBox),
                            getAppointmentTitle(context, 'Appointment type'),
                            const SizedBox(height: primarySizedBox),
                            getAppointmentDetail(
                                context, details?['appointment_type']),
                            const SizedBox(height: tertiarySizedBox),
                            getAppointmentTitle(context, 'Address'),
                            const SizedBox(height: primarySizedBox),
                            wrappedText(
                                context, details?['appointment_address'] ?? ''),
                            const SizedBox(height: tertiarySizedBox),
                            getAppointmentTitle(context, 'Date and time'),
                            const SizedBox(height: primarySizedBox),
                            getAppointmentDetail(context,
                                '${secondaryFormatDate(appointmentDate!)}, ${formatTime(appointmentTime!)}'),
                            const SizedBox(height: tertiarySizedBox),
                            if (services.isNotEmpty) ...[
                              getAppointmentTitle(context, 'Services'),
                              const SizedBox(height: primarySizedBox),
                              ...services.map((service) => buildCartItem(
                                  name: '${service.serviceName}',
                                  price: '${service.servicePrice.toString()}')),
                            ],
                            const SizedBox(height: primarySizedBox),
                            if (packages.isNotEmpty) ...[
                              getAppointmentTitle(context, 'Packages'),
                              const SizedBox(height: primarySizedBox),
                              ...packages.map((package) => buildCartItem(
                                  name: '${package.packageName}',
                                  price: '${package.packagePrice.toString()}')),
                            ],
                            const SizedBox(height: secondarySizedBox),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                getAppointmentTotalTitle(context, 'Total'),
                                regularPrimaryColoredBoldTextWidget(
                                    '₱${details?['total_amount']}')
                              ],
                            ),
                            const SizedBox(height: quaternarySizedBox),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    Center(child: Text('Error: $error')),
              );
            },
            loading: () => Container(
              color: Colors.white,
            ),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black54, // Semi-transparent background
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  createRescheduledAppointment(
      {required String date,
      required String time,
      required String appointmentStatus}) async {
    setState(() {
      isLoading =
          true; // Set loading to true before starting the appointment creation
    });
    final supabase = Supabase.instance.client;

    // Get the current time in UTC
    DateTime timestamp = DateTime.now().toUtc();

    final appointmentId = ref.watch(tappedSpAppointmentIdProvider);

    final response = await supabase
        .from('appointment')
        .update({
          'appointment_date': date,
          'appointment_time': time,
          'appointment_type': appointmentStatus,
          'created_at': timestamp.toString(),
        })
        .eq('appointment_id', appointmentId)
        .select('appointment_id')
        .single();

    final fetchedAppointmentId = response['appointment_id'];
    print('Appointment created with ID: $appointmentId');
    ref.read(appointmentIdProvider.notifier).state = appointmentId.toString();

    setState(() {
      isLoading =
          false; // Set loading to false once the appointment creation is done
    });

    return fetchedAppointmentId;
  }
}
