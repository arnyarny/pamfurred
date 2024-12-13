import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/confetti.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/appointment_services_and_packages.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/appointment_components/components.dart';
import 'package:pamfurred/screens/main_screen.dart';

class SuccessfulRescheduleAppointment extends ConsumerStatefulWidget {
  const SuccessfulRescheduleAppointment({super.key});

  @override
  ConsumerState<SuccessfulRescheduleAppointment> createState() =>
      SuccessfulRescheduleAppointmentState();
}

class SuccessfulRescheduleAppointmentState
    extends ConsumerState<SuccessfulRescheduleAppointment> {
  Map<String, dynamic>? mapAppointmentDetails;

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(totalAmountProvider);

    final rescheduleDate = ref.watch(selectedDateProvider);
    final rescheduleTime = ref.watch(selectedTimeslotProvider);

    final formattedRescheduleDate = secondaryFormatDate(rescheduleDate!);
    final formattedRescheduleTime = formatTime(rescheduleTime!);

    final appointmentId = ref.watch(tappedSpAppointmentIdProvider);
    if (appointmentId.isEmpty) {
      return const Center(child: Text('No appointment selected.'));
    }

    final specificAppointmentDetails =
        ref.watch(specificAppointmentDetailsProvider(appointmentId));
    final combinedDetails =
        ref.watch(appointmentServicesAndPackagesProvider(appointmentId));

    return specificAppointmentDetails.when(
      data: (details) {
        return combinedDetails.when(
            data: (combined) {
              final services =
                  (combined['services'] as List<AppointmentService>?) ?? [];
              final packages =
                  (combined['packages'] as List<AppointmentPackage>?) ?? [];

              return PopScope(
                canPop: false,
                child: Scaffold(
                  body: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/background.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Center confetti widget
                      const ConfettiDisplay(),
                      Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/pamfurred_logo.png',
                                width: 325,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                          const SizedBox(height: tertiarySizedBox),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/check.png',
                                width: 175,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                          const SizedBox(height: tertiarySizedBox),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customTitleText(
                                  context, 'Appointment Rescheduled!'),
                              const SizedBox(
                                height: primarySizedBox,
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: Text(
                                      'Your appointment has been rescheduled successfully.',
                                      style: TextStyle(
                                          fontSize: regularText,
                                          fontWeight: regularWeight,
                                          color: Colors.black,
                                          overflow: TextOverflow.visible),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: tertiarySizedBox),
                          SizedBox(
                            width: screenPadding(context),
                            child: Column(
                              children: [
                                // Appointment ID
                                getAppointmentTitle(context, 'Appointment ID'),
                                const SizedBox(height: primarySizedBox),
                                getAppointmentDetail(
                                    context,
                                    ref
                                        .watch(appointmentIdProvider)
                                        .toString()),

                                const SizedBox(height: secondarySizedBox),

                                // Service provider name
                                getAppointmentTitle(
                                    context, 'Service provider'),
                                const SizedBox(height: primarySizedBox),
                                getAppointmentDetail(
                                    context, details?['establishment_name']),

                                const SizedBox(height: secondarySizedBox),

                                // Reschedule date and time
                                getAppointmentTitle(context, 'Date and time'),
                                const SizedBox(height: primarySizedBox),
                                getAppointmentDetail(context,
                                    '$formattedRescheduleDate, $formattedRescheduleTime'),

                                const SizedBox(height: secondarySizedBox),

                                // Service and/or packages
                                if (services.isNotEmpty) ...[
                                  getAppointmentTitle(context, 'Services'),
                                  const SizedBox(height: primarySizedBox),
                                  ...services.map((service) => buildCartItem(
                                      name: '${service.serviceName}',
                                      price:
                                          '${service.servicePrice.toString()}')),
                                ],
                                const SizedBox(height: primarySizedBox),
                                if (packages.isNotEmpty) ...[
                                  getAppointmentTitle(context, 'Packages'),
                                  const SizedBox(height: primarySizedBox),
                                  ...packages.map((package) => buildCartItem(
                                      name: '${package.packageName}',
                                      price:
                                          '${package.packagePrice.toString()}')),
                                ],

                                const SizedBox(height: secondarySizedBox),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    getAppointmentTotalTitle(context, 'Total'),
                                    regularPrimaryColoredBoldTextWidget(
                                        '₱$total')
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: tertiarySizedBox),
                          Center(
                            child: customPaddedTextButton(
                                text: 'Return to dashboard',
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      crossFadeRoute(const MainScreen(
                                        initialPage: 0,
                                      )));
                                }),
                          )
                        ],
                      ))
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
