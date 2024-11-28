import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/empty_list_widget.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/notifications_provider.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/screens/appointment_details/appointment_details.dart';

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
    final weeks = (days / 7).floor();
    final months = (days / 30).floor();
    final years = (days / 365).floor();

    String result;

    if (minutes < 1) {
      result = "Just now";
    } else if (minutes < 60) {
      result = "$minutes minute${minutes == 1 ? '' : 's'} ago";
    } else if (hours < 24) {
      result = "$hours hour${hours == 1 ? '' : 's'} ago";
    } else if (days < 7) {
      result = "$days day${days == 1 ? '' : 's'} ago";
    } else if (days < 30) {
      result = "$weeks week${weeks == 1 ? '' : 's'} ago";
    } else if (days < 365) {
      result = "$months month${months == 1 ? '' : 's'} ago";
    } else {
      result = "$years year${years == 1 ? '' : 's'} ago";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(userIdProvider).toString();
    final notificationDetailsAsync =
        ref.watch(notificationDetailsProvider(userId));

    final notifications = notificationDetailsAsync.when(
      data: (data) {
        final fetchednotifications =
            data['notifications'] as List<Map<String, dynamic>>? ?? [];
        if (isTapped.length != fetchednotifications.length) {
          // Ensure `isTapped` is updated whenever notifications length changes
          isTapped = List<bool>.filled(fetchednotifications.length, false);
        }
        return fetchednotifications;
      },
      loading: () => [],
      error: (error, stackTrace) => [],
    );

    // Sort the notifications by notification arrival in descending order
    notifications.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    // Separate notifications into "Today," "Yesterday," and "Older"
    List todaynotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isToday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();

    List yesterdaynotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isYesterday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();

    List oldernotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return !isToday(parsedDate) && !isYesterday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: notifications.isEmpty
            ? Center(
                child: emptyListWidget(Icons.notifications_off,
                    'All caught up!', 'You have no new notifications.'))
            : Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: primarySizedBox),
                  child: SizedBox(
                    width: screenPadding(context), // Responsive padding
                    child: Column(
                      children: [
                        const SizedBox(height: secondarySizedBox),
                        Expanded(
                          child: PullToRefresh(
                            providersToRefresh: [
                              notificationDetailsProvider(userId)
                            ],
                            child: ListView(
                              children: [
                                // Section for "Today" notifications
                                if (todaynotifications.isNotEmpty) ...[
                                  buildSectionHeader("Today"),
                                  ...todaynotifications.map((notification) {
                                    int index =
                                        notifications.indexOf(notification);
                                    return reusableNotificationCard(
                                        index, notification);
                                  }),
                                ],

                                const SizedBox(height: primarySizedBox),

                                // Section for "Yesterday" notifications
                                if (yesterdaynotifications.isNotEmpty) ...[
                                  buildSectionHeader("Yesterday"),
                                  ...yesterdaynotifications.map((notification) {
                                    int index =
                                        notifications.indexOf(notification);
                                    return reusableNotificationCard(
                                        index, notification);
                                  }),
                                ],

                                const SizedBox(height: primarySizedBox),

                                // Section for "Earlier" notifications
                                if (oldernotifications.isNotEmpty) ...[
                                  buildSectionHeader("Earlier"),
                                  ...oldernotifications.map((notification) {
                                    int index =
                                        notifications.indexOf(notification);
                                    return reusableNotificationCard(
                                        index, notification);
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
      ),
    );
  }

  // Reusable card widget for notifications
  Widget reusableNotificationCard(
      int index, Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () {
        setState(() {
          ref.read(selectedNotificationIdProvider.notifier).state =
              notification['notification_id'];
          Navigator.push(
              context, slideUpRoute(const AppointmentDetailsScreen()));
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
                  if (notification['appointment_notif_type'] == 'Upcoming') ...[
                    customTitleText(context, 'Upcoming '),
                    customTitleText(context, "appointment"),
                  ],
                  if (notification['appointment_notif_type'] != 'Upcoming') ...[
                    customTitleText(context, "Appointment"),
                    customTitleText(
                        context,
                        toLowercase(notification['appointment_notif_type'] ==
                                "Done"
                            ? " completed"
                            : " ${notification['appointment_notif_type']}")),
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
                        if (notification['appointment_notif_type'] ==
                            'Upcoming') {
                          return 'You have an';
                        } else {
                          return 'Your appointment with';
                        }
                      })(),
                      style: const TextStyle(
                          fontSize: regularText, color: Colors.black),
                    ),
                    if (notification['appointment_notif_type'] ==
                        'Upcoming') ...[
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
                            ' ${notification['establishment_name']}', // Null check for 'establishment_name'
                        style: const TextStyle(
                            fontSize: regularText, color: primaryColor),
                      ),
                    ],
                    if (notification['appointment_notif_type'] !=
                        'Upcoming') ...[
                      TextSpan(
                        text:
                            ' ${notification['establishment_name']}', // Null check for 'establishment_name'
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
                        text: notification['appointment_notif_type'] == 'Done'
                            ? 'completed'
                            : toLowercase(notification[
                                'appointment_notif_type']), // Null check for 'establishment_name'
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
                    notification['created_at'] ?? DateTime.now().toString())),
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
