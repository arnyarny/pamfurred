import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/backend_logic_files/cancel_appointment.dart';
import 'package:pamfurred/components/connectivity_wrapper.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/error_widget.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/screens/appointment_details/appointment_details.dart';
import 'package:pamfurred/screens/appointment_details/give_feedback.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/globals.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  AppointmentsScreenState createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = false;

  final SupabaseClient supabaseClient = Supabase.instance.client;
  late AppointmentService appointmentService;

  final Map<String, Color> statusColors = {
    'Upcoming': const Color.fromRGBO(255, 143, 0, 1),
    'Done': Colors.green,
    'Cancelled': const Color.fromRGBO(160, 62, 6, 1),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    appointmentService = AppointmentService(supabaseClient);
  }

  Future<void> cancelAppointment(String appointmentId) async {
    setState(() {
      isLoading = true;
    });

    final result = await appointmentService.cancelAppointment(
        appointmentId: appointmentId);

    if (result != null) {
      print('Appointment cancelled with ID: $result');
    } else {
      print('Failed to cancel appointment');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentAsyncValue = ref.watch(appointmentDetailsProvider);

    return ConnectivityWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 20,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: [
              _buildTab('Today'),
              _buildTab('Pending'),
              _buildTab('Upcoming'),
              _buildTab('Done'),
              _buildTab('Cancelled'),
              _buildTab('All'),
            ],
            labelColor: tangerine,
            indicatorColor: tangerine,
          ),
        ),
        body: Center(
          child: appointmentAsyncValue.when(
            data: (appointmentData) {
              final appointmentList =
                  appointmentData['appointments'] as List<Map<String, dynamic>>;

              return TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: List.generate(6, (index) {
                  return _buildAppointmentList(index, appointmentList);
                }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: somethingWentWrong()),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Text(text),
    );
  }

  Widget _buildAppointmentList(
      int tabIndex, List<Map<String, dynamic>> appointmentList) {
    final filteredAppointments = appointmentList.where((appointment) {
      final dateFormat =
          DateFormat('yyyy-MM-dd HH:mm'); // Update format as needed
      DateTime appointmentDate;

      try {
        appointmentDate = dateFormat.parse(
            '${appointment['appointment_date']} ${appointment['appointment_time']}');
      } catch (e) {
        appointmentDate = DateTime.now();
      }

      switch (tabIndex) {
        case 0: // Today
          final today = DateTime.now();
          return appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day &&
              appointment['appointment_status'] == 'Today';
        case 1:
          return appointment['appointment_status'] == 'Pending';
        case 2: // Upcoming
          return appointment['appointment_status'] == 'Upcoming';
        case 3: // Done
          return appointment['appointment_status'] == 'Done';
        case 4: // Cancelled
          return appointment['appointment_status'] == 'Cancelled';
        case 5: // All
          return true; // No filter for "All"
        default:
          return false;
      }
    }).toList();

    // Sort appointments by `appointment_date` and `appointment_time`
    filteredAppointments.sort((a, b) {
      final dateTimeA = DateFormat('yyyy-MM-dd HH:mm')
          .parse('${a['appointment_date']} ${a['appointment_time']}');
      final dateTimeB = DateFormat('yyyy-MM-dd HH:mm')
          .parse('${b['appointment_date']} ${b['appointment_time']}');
      return dateTimeA.compareTo(dateTimeB);
    });

    if (filteredAppointments.isEmpty) {
      return const Center(child: Text('No Appointments Available'));
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];

        return GestureDetector(
          onTap: () {
            ref.read(tappedSpAppointmentIdProvider.notifier).state =
                appointment['appointment_id'];
            Navigator.push(
                context, slideUpRoute(const AppointmentDetailsScreen()));
          },
          child: Card(
            color: Colors.white,
            elevation: 1.5,
            shape: const LinearBorder(
                side: BorderSide(width: 1.0, color: lighterGreyColor)),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customBoldWeightRegularText(context,
                        '${appointment['establishment_name'] ?? 'N/A'}'),
                    Text(
                      appointment['appointment_status'] ?? 'Unknown',
                      style: TextStyle(
                          color:
                              statusColors[appointment['appointment_status']] ??
                                  Colors.black87,
                          fontSize: regularText),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: primarySizedBox),
                    Text(
                      appointment['appointment_date'] == null
                          ? 'N/A'
                          : secondaryFormatDate(
                              appointment['appointment_date']),
                      style: const TextStyle(color: darkGreyColor),
                    ),
                    const SizedBox(height: primarySizedBox),
                    Text(
                      appointment['appointment_time'] == null
                          ? 'N/A'
                          : formatTime(appointment['appointment_time']),
                      style: const TextStyle(color: greyColor),
                    ),
                  ],
                ),
              ),
              // Cancel and Reschedule buttons
              (appointment['appointment_status'] == 'Upcoming' ||
                          appointment['appointment_status'] == 'Pending') &&
                      isOneDayBeforeOrEarlier(appointment[
                          'appointment_date']) // If it's 1 day before the appointment_date
                  ? Padding(
                      padding: const EdgeInsets.only(left: tertiarySizedBox),
                      child: Row(
                        children: [
                          customSmallPaddedTextButton(
                              text: 'Cancel',
                              onPressed: () {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.warning,
                                  animType: QuickAlertAnimType.slideInUp,
                                  title: 'Cancel Appointment',
                                  text:
                                      'Are you sure you want to cancel this appointment?',
                                  confirmBtnColor: Colors.red,
                                  confirmBtnText: 'Yes',
                                  showCancelBtn: true,
                                  cancelBtnText: 'No',
                                  onConfirmBtnTap: () async {
                                    setState(() {
                                      isLoading =
                                          true; // Set isLoading to true when confirming cancellation
                                    });

                                    final toBeCancelledAppointId = ref
                                        .read(tappedSpAppointmentIdProvider
                                            .notifier)
                                        .state = appointment['appointment_id'];

                                    // Call the cancelAppointment function and await the result
                                    await cancelAppointment(
                                        toBeCancelledAppointId);
                                    if (context.mounted) {
                                      Navigator.pop(
                                          context); // Close the QuickAlert dialog after the action is completed
                                    }

                                    setState(() {
                                      isLoading =
                                          false; // Set isLoading to false once the cancellation is complete
                                    });

                                    if (context.mounted) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.success,
                                        title: 'Appointment Cancelled',
                                        text:
                                            'Your appointment has been cancelled',
                                      );
                                    }
                                  },
                                );
                              }),
                          const SizedBox(
                            width: secondarySizedBox,
                          ),
                          customSmallPaddedTextButton(
                              text: 'Reschedule',
                              onPressed: () {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.warning,
                                    animType: QuickAlertAnimType.slideInUp,
                                    title: 'Reschedule Appointment',
                                    text:
                                        'Are you sure you want to reschedule this appointment?',
                                    confirmBtnColor: Colors.red,
                                    confirmBtnText: 'Yes',
                                    showCancelBtn: true,
                                    cancelBtnText: 'No',
                                    onConfirmBtnTap: () {});
                              },
                              backgroundColor: Colors.green,
                              textColor: Colors.white),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              // Give feedback button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        ref.read(tappedSpAppointmentIdProvider.notifier).state =
                            appointment['sp_id'];
                        ref.read(selectedAppointmentIdProvider.notifier).state =
                            appointment['appointment_id'];
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return const GiveFeedbackBottomSheet();
                          },
                        );
                      },
                      child: appointment['appointment_status'] == 'Done' &&
                              appointment['is_reviewed'] == false
                          ? const Text(
                              'Give feedback',
                              style: TextStyle(
                                  color: secondaryColor,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset:
                                          Offset(1.0, 1.0), // Smaller offset
                                      blurRadius: 2.0, // Reduced blur
                                      color: lightGreyColor, // Softer color
                                    ),
                                  ],
                                  decoration: TextDecoration.underline,
                                  decorationColor: secondaryColor),
                            )
                          : const SizedBox
                              .shrink(), // Show nothing if conditions are not met
                    ),
                    const SizedBox(width: quaternarySizedBox),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  bool isOneDayBeforeOrEarlier(String? dateStr) {
    if (dateStr == null) return false;

    try {
      // Parse the given date string
      final DateTime givenDate = DateTime.parse(dateStr);

      // Get the current date (ignoring time by setting it to midnight)
      final DateTime today = DateTime.now();
      final DateTime currentDate = DateTime(today.year, today.month, today.day);

      // Calculate the difference in days
      final int difference = givenDate.difference(currentDate).inDays;

      // Check if the given date is 1 day before or earlier
      return difference <= -1;
    } catch (e) {
      // Return false if there's an error in parsing the date
      return false;
    }
  }
}
