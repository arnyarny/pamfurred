import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/appointments_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      NotificationsScreenState();
}

class NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late List<bool> isTapped; // Track the tapped state for each card

  @override
  void initState() {
    super.initState();
    isTapped =
        []; // Initialize the list, but we'll populate it after fetching the data
  }

  // Function to check if the date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Function to check if the date is yesterday
  bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Function to compute time elapsed since the notification was created
  String timeElapsed(DateTime notificationArrival) {
    final now = DateTime.now();
    final difference = now.difference(notificationArrival);

    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    final months = (days / 30).floor();
    final years = (days / 365).floor();

    String result;

    if (minutes < 1) {
      result = "Just now";
    } else if (minutes < 60) {
      result = "$minutes minute${minutes == 1 ? '' : 's'} ago";
    } else if (hours < 24) {
      result = "$hours hour${hours == 1 ? '' : 's'} ago";
    } else if (days < 30) {
      result = "$days day${days == 1 ? '' : 's'} ago";
    } else if (days < 365) {
      result = "$months month${months == 1 ? '' : 's'} ago";
    } else {
      result = "$years year${years == 1 ? '' : 's'} ago";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentAsyncValue = ref.watch(appointmentDetailsProvider);

    final appointments = appointmentAsyncValue.when(
      data: (data) {
        final fetchedAppointments =
            data['appointments'] as List<Map<String, dynamic>>? ?? [];
        if (isTapped.length != fetchedAppointments.length) {
          // Ensure `isTapped` is updated whenever appointments length changes
          isTapped = List<bool>.filled(fetchedAppointments.length, false);
        }
        return fetchedAppointments;
      },
      loading: () => [],
      error: (error, stackTrace) => [],
    );

    // Sort the appointments by notification arrival in descending order
    appointments.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    // Separate appointments into "Today," "Yesterday," and "Older"
    List todayAppointments = appointments.where((appointment) {
      final createdAt = appointment['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isToday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();

    List yesterdayAppointments = appointments.where((appointment) {
      final createdAt = appointment['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isYesterday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();

    List olderAppointments = appointments.where((appointment) {
      final createdAt = appointment['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return !isToday(parsedDate) && !isYesterday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox(
            width: screenPadding(context), // Responsive padding
            child: Column(
              children: [
                const SizedBox(height: secondarySizedBox),
                Expanded(
                  child: PullToRefresh(
                    providersToRefresh: [appointmentDetailsProvider],
                    child: ListView(
                      children: [
                        // Section for "Today" appointments
                        if (todayAppointments.isNotEmpty) ...[
                          buildSectionHeader("Today"),
                          ...todayAppointments.map((appointment) {
                            int index = appointments.indexOf(appointment);
                            return reusableNotificationCard(index, appointment);
                          }),
                        ],

                        const SizedBox(height: primarySizedBox),

                        // Section for "Yesterday" appointments
                        if (yesterdayAppointments.isNotEmpty) ...[
                          buildSectionHeader("Yesterday"),
                          ...yesterdayAppointments.map((appointment) {
                            int index = appointments.indexOf(appointment);
                            return reusableNotificationCard(index, appointment);
                          }),
                        ],

                        const SizedBox(height: primarySizedBox),

                        // Section for "Earlier" appointments
                        if (olderAppointments.isNotEmpty) ...[
                          buildSectionHeader("Earlier"),
                          ...olderAppointments.map((appointment) {
                            int index = appointments.indexOf(appointment);
                            return reusableNotificationCard(index, appointment);
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section header builder
  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: headerText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Reusable card widget for notifications
  // Reusable card widget for notifications
  Widget reusableNotificationCard(int index, Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle the tapped state for the specific card
          isTapped[index] = !isTapped[index];
        });
      },
      child: Card(
        color: isTapped[index]
            ? Colors.white
            : lighterGreyColor, // Toggle card color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (appointment['appointment_status'] == 'Upcoming') ...[
                    customTitleText(context, 'Upcoming '),
                    customTitleText(context, "appointment"),
                  ],
                  if (appointment['appointment_status'] != 'Upcoming') ...[
                    customTitleText(context, "Appointment"),
                    customTitleText(
                        context,
                        toLowercase(appointment['appointment_status'] == "Done"
                            ? " completed"
                            : " ${appointment['appointment_status']}")),
                  ]
                ],
              ),
              const SizedBox(height: primarySizedBox),
              RichText(
                text: TextSpan(
                  children: [
                    // Determine the initial message based on appointment status
                    TextSpan(
                      text: (() {
                        if (appointment['appointment_status'] == 'Upcoming') {
                          return 'You have an';
                        } else {
                          return 'Your appointment with';
                        }
                      })(),
                      style: const TextStyle(
                          fontSize: regularText, color: Colors.black),
                    ),
                    if (appointment['appointment_status'] == 'Upcoming') ...[
                      const TextSpan(
                        text:
                            ' upcoming ', // Null check for 'establishment_name'
                        style: TextStyle(
                            fontSize: regularText, color: primaryColor),
                      ),
                      const TextSpan(
                        text:
                            'appointment with', // Null check for 'establishment_name'
                        style: TextStyle(
                            fontSize: regularText, color: Colors.black),
                      ),
                      TextSpan(
                        text:
                            ' ${appointment['establishment_name']}', // Null check for 'establishment_name'
                        style: const TextStyle(
                            fontSize: regularText, color: primaryColor),
                      ),
                    ],
                    if (appointment['appointment_status'] != 'Upcoming') ...[
                      TextSpan(
                        text:
                            ' ${appointment['establishment_name']}', // Null check for 'establishment_name'
                        style: const TextStyle(
                            fontSize: regularText, color: primaryColor),
                      ),
                      const TextSpan(
                        text:
                            ' has been ', // Null check for 'establishment_name'
                        style: TextStyle(
                            fontSize: regularText, color: Colors.black),
                      ),
                      TextSpan(
                        text: appointment['appointment_status'] == 'Done'
                            ? 'completed'
                            : toLowercase(appointment['appointment_status']), // Null check for 'establishment_name'
                        style: const TextStyle(
                            fontSize: regularText, color: primaryColor),
                      ),
                    ],
                    // Final period to end the sentence
                    const TextSpan(
                      text: ".",
                      style:
                          TextStyle(fontSize: regularText, color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: primarySizedBox),
              // Displaying notification arrival time
              Text(
                timeElapsed(DateTime.parse(
                    appointment['created_at'] ?? DateTime.now().toString())),
                style:
                    const TextStyle(fontSize: smallText, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
