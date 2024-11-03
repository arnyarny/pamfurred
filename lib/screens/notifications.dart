import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
// import 'package:pamfurred/components/pull_to_refresh.dart';
// import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/title_text.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  // Mock db that contains notifications data
  List<Map<String, dynamic>> appointments = [
    {
      'status': 'Done',
      'service_provider': 'Critter Care Grooming Services',
      'notification_arrival': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'status': 'Cancelled',
      'service_provider': 'Fuzzy Finish Pet Salon',
      'notification_arrival': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'status': 'Done',
      'service_provider': 'Tailored Tails Pet Grooming Services',
      'notification_arrival': DateTime.now().subtract(const Duration(hours: 4)),
    },
    {
      'status': 'Done',
      'service_provider': 'Mane Attraction Pet Grooming',
      'notification_arrival':
          DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'status': 'Cancelled',
      'service_provider': 'Snip \'n Shine Pet Retreat',
      'notification_arrival': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'status': 'Done',
      'service_provider': 'Paw-sitively Polished Pet Parlor',
      'notification_arrival': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'status': 'Done',
      'service_provider': 'Grooming Glitz and Glam',
      'notification_arrival':
          DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'status': 'Done',
      'service_provider': 'Furry Finishers Pet Salon',
      'notification_arrival': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'status': 'Cancelled',
      'service_provider': 'Purrfect Paws Grooming Spa',
      'notification_arrival': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'status': 'Done',
      'service_provider': 'Paws and Claws Pet Station',
      'notification_arrival': DateTime.now().subtract(const Duration(hours: 6)),
    },
  ];

  // Track the tapped state for each card
  late List<bool> isTapped;

  @override
  void initState() {
    super.initState();
    // Initialize the isTapped list to false for all cards
    isTapped = List<bool>.filled(appointments.length, false);

    // Sort the appointments by notification arrival in descending order
    appointments.sort((a, b) =>
        b['notification_arrival'].compareTo(a['notification_arrival']));
  }

  // Function to check if the date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Function to compute time elapsed
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
    // Separate appointments into today and earlier
    List<Map<String, dynamic>> todayAppointments = appointments
        .where((appointment) => isToday(appointment['notification_arrival']))
        .toList();
    List<Map<String, dynamic>> earlierAppointments = appointments
        .where((appointment) => !isToday(appointment['notification_arrival']))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            // Using screenPadding() for responsive width
            width: screenPadding(context),
            child: Column(
              children: [
                const SizedBox(height: secondarySizedBox),
                Expanded(
                  // Remove this comment when backend is implemented in this screen
                  // child: PullToRefresh(
                  //   providersToRefresh: [

                  //   ],
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Today header and appointments
                      buildSectionHeader("Today"),
                      // Today Appointments
                      ...todayAppointments.map((appointment) {
                        int index = appointments.indexOf(appointment);
                        return reusableNotificationCard(index, appointment);
                      }),
                      const SizedBox(height: primarySizedBox),
                      // Earlier Header
                      buildSectionHeader("Earlier"),
                      const SizedBox(height: primarySizedBox),
                      // Earlier Appointments
                      ...earlierAppointments.map((appointment) {
                        int index = appointments.indexOf(appointment);
                        return reusableNotificationCard(index, appointment);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable card widget
  Widget reusableNotificationCard(int index, Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle the tap state for the specific card
          isTapped[index] = !isTapped[index];
        });
      },
      child: Card(
        // Change background color based on the tapped state of the specific card
        color: isTapped[index] ? Colors.white : lighterGreyColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  customTitleText(context, "Appointment "),
                  customTitleText(context, toLowercase(appointment['status'])),
                ],
              ),
              const SizedBox(height: primarySizedBox),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: "Your appointment with ",
                    style:
                        TextStyle(fontSize: regularText, color: Colors.black)),
                // Displaying service provider's name
                TextSpan(
                    text: '${appointment['service_provider']}',
                    style: const TextStyle(
                        fontSize: regularText, color: primaryColor)),
                const TextSpan(
                    text: " has been ",
                    style:
                        TextStyle(fontSize: regularText, color: Colors.black)),
                // Displaying appointment status
                TextSpan(
                    text: toLowercase(appointment['status']),
                    style: const TextStyle(
                        fontSize: regularText, color: primaryColor)),
                const TextSpan(
                    text: ".",
                    style:
                        TextStyle(fontSize: regularText, color: Colors.black)),
              ])),
              const SizedBox(height: primarySizedBox),
              // Displaying notification arrival time
              Text(
                timeElapsed(appointment['notification_arrival']),
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
