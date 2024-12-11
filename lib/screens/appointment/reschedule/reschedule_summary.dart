import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/appointment_services_and_packages.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';

class RescheduleSummary extends ConsumerStatefulWidget {
  const RescheduleSummary({super.key});

  @override
  ConsumerState<RescheduleSummary> createState() => RescheduleSummaryState();
}

class RescheduleSummaryState extends ConsumerState<RescheduleSummary> {
  @override
  Widget build(BuildContext context) {
    final appointmentId = ref.watch(tappedSpAppointmentIdProvider);
    if (appointmentId.isEmpty) {
      return const Center(child: Text('No appointment selected.'));
    }

    final rescheduleDate = ref.watch(selectedDateProvider).toString();
    final rescheduleTime = ref.watch(selectedTimeslotProvider).toString();

    final specificAppointmentDetails =
        ref.watch(specificAppointmentDetailsProvider(appointmentId));
    final combinedDetails =
        ref.watch(appointmentServicesAndPackagesProvider(appointmentId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBarWithTitle(context, 'Appointment Summary'),
      body: specificAppointmentDetails.when(
        data: (details) {
          // print(details);
          return combinedDetails.when(
            data: (combined) {
              final services =
                  (combined['services'] as List<AppointmentService>?) ?? [];
              final packages =
                  (combined['packages'] as List<AppointmentPackage>?) ?? [];

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
                        getAppointmentTitle(context, 'Date'),
                        const SizedBox(height: primarySizedBox),
                        getAppointmentDetail(
                            context, secondaryFormatDate(rescheduleDate)),
                        const SizedBox(height: tertiarySizedBox),
                        getAppointmentTitle(context, 'Time'),
                        const SizedBox(height: primarySizedBox),
                        getAppointmentDetail(
                            context, formatTime(rescheduleTime)),
                        const SizedBox(height: secondarySizedBox),

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

                        // _buildDetailRow('Service provider',
                        //     details?['establishment_name'] ?? 'No name'),
                        // _buildDetailRow(
                        //     'Pet name', details?['pet_name'] ?? 'No pet name'),
                        // _buildDetailRow('Appointment type',
                        //     details?['appointment_type'] ?? 'Unknown'),
                        // _buildDetailRow(
                        //     'Address',
                        //     details?['appointment_address'] ??
                        //         'Address not available'),
                        // _buildDetailRow(
                        //     'Date', secondaryFormatDate(rescheduleDate)),
                        // _buildDetailRow('Time', formatTime(rescheduleTime)),
                        // const SizedBox(height: 20),
                        // if (services.isNotEmpty) ...[
                        //   const Text('Services',
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold, fontSize: 16)),
                        //   ...services.map((service) => _buildDetailRow(
                        //       service.serviceName,
                        //       '₱${service.servicePrice.toString()}')),
                        //   const SizedBox(height: 10),
                        // ],
                        // if (packages.isNotEmpty) ...[
                        //   const Text('Packages',
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.bold, fontSize: 16)),
                        //   ...packages.map((package) => _buildDetailRow(
                        //       package.packageName,
                        //       '₱${package.packagePrice.toString()}')),
                        //   const SizedBox(height: 10),
                        // ],
                        // _buildDetailRow('Total',
                        //     '₱${details?['total_amount']?.toString() ?? '0.0'}'),
                        CustomWideButton(
                          text: 'Confirm appointment',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  getAppointmentTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customTitleText(context, title),
        const SizedBox(width: primarySizedBox),
      ],
    );
  }

  getAppointmentDetail(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customRegularWeightTitleText(context, title),
        const SizedBox(width: primarySizedBox),
      ],
    );
  }

  Widget buildCartItem({required dynamic name, required String price}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        getPrice(price),
      ],
    );
  }

  getPrice(String s) {
    return Text(
      '₱$s',
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  getAppointmentTotalTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customTitleTextWithPrimaryColor(context, title),
        const SizedBox(width: primarySizedBox),
      ],
    );
  }

  // Widget _buildDetailRow(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       children: [
  //         Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
  //         Text(value),
  //       ],
  //     ),
  //   );
  // }
}
