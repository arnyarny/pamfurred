import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/empty_list_widget.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/notifications_provider.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/components/connectivity_wrapper.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      NotificationsScreenState();
}

class NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // late List<bool> isTapped;

  @override
  void initState() {
    super.initState();
    // isTapped = [];
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(userIdProvider).toString();
    final notificationDetailsAsync =
        ref.watch(notificationDetailsProvider(userId));

    final notifications = notificationDetailsAsync.when(
      data: (data) {
        final fetchedNotifications =
            data['notifications'] as List<Map<String, dynamic>>? ?? [];
        final filteredNotifications = fetchedNotifications
            .where((notification) =>
                notification['appointment_notif_type'] != "Upcoming")
            .toList();
        // if (isTapped.length != filteredNotifications.length) {
        //   isTapped = List<bool>.filled(filteredNotifications.length, false);
        // }
        return filteredNotifications;
      },
      loading: () => [],
      error: (error, stackTrace) => [],
    );

    notifications.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    final todayNotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isToday(parsedDate);
      }
      return false;
    }).toList();

    final yesterdayNotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isYesterday(parsedDate);
      }
      return false;
    }).toList();

    final olderNotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return !isToday(parsedDate) && !isYesterday(parsedDate);
      }
      return false;
    }).toList();

    final hasNotifications = todayNotifications.isNotEmpty ||
        yesterdayNotifications.isNotEmpty ||
        olderNotifications.isNotEmpty;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: ConnectivityWrapper(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: !hasNotifications
                ? Center(
                    child: emptyListWidget(Icons.notifications_off,
                        'All caught up!', 'You have no new notifications.'))
                : Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: primarySizedBox),
                      child: SizedBox(
                        width: screenPadding(context),
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
                                    if (todayNotifications.isNotEmpty) ...[
                                      buildSectionHeader("Today"),
                                      ...todayNotifications.map((notification) {
                                        int index =
                                            notifications.indexOf(notification);
                                        return reusableNotificationCard(
                                            index, notification);
                                      }),
                                    ],
                                    const SizedBox(height: primarySizedBox),
                                    if (yesterdayNotifications.isNotEmpty) ...[
                                      buildSectionHeader("Yesterday"),
                                      ...yesterdayNotifications
                                          .map((notification) {
                                        int index =
                                            notifications.indexOf(notification);
                                        return reusableNotificationCard(
                                            index, notification);
                                      }),
                                    ],
                                    const SizedBox(height: primarySizedBox),
                                    if (olderNotifications.isNotEmpty) ...[
                                      buildSectionHeader("Earlier"),
                                      ...olderNotifications.map((notification) {
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
        ),
      ),
    );
  }

  Widget reusableNotificationCard(
      int index, Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () {
        setState(() {
          ref.read(selectedNotificationIdProvider.notifier).state =
              notification['notification_id'];
          // Navigator.push(
          //     context, slideUpRoute(const AppointmentDetailsScreen()));
          // isTapped[index] = !isTapped[index];
        });
      },
      child: Card(
        color:
            // isTapped[index] ? Colors.white :
            lighterGreyColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  customTitleText(context, "Appointment"),
                  customTitleText(
                    context,
                    toLowercase(notification['appointment_notif_type'] == "Done"
                        ? " completed"
                        : " ${notification['appointment_notif_type']}"),
                  ),
                ],
              ),
              const SizedBox(height: primarySizedBox),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: notification['appointment_notif_type'] == "Pending"
                          ? 'You have a pending appointment with'
                          : 'Your appointment with',
                      style:
                          TextStyle(fontSize: regularText, color: Colors.black),
                    ),
                    TextSpan(
                      text: ' ${notification['establishment_name']}',
                      style: const TextStyle(
                          fontSize: regularText, color: primaryColor),
                    ),
                    TextSpan(
                      text: notification['appointment_notif_type'] != "Pending"
                          ? ' has been '
                          : null,
                      style:
                          TextStyle(fontSize: regularText, color: Colors.black),
                    ),
                    TextSpan(
                      text: notification['appointment_notif_type'] == 'Done'
                          ? 'completed'
                          : notification['appointment_notif_type'] != "Pending"
                              ? toLowercase(
                                  notification['appointment_notif_type'])
                              : null,
                      style: const TextStyle(
                          fontSize: regularText, color: primaryColor),
                    ),
                    if (notification['appointment_notif_type'] ==
                        "Rescheduled") ...[
                      TextSpan(
                        text: ' on',
                        style: const TextStyle(
                            fontSize: regularText, color: Colors.black),
                      ),
                      TextSpan(
                        text:
                            ' ${secondaryFormatDate(notification['appointment_date'])}, ${formatTime(notification['appointment_time'])}',
                        style: const TextStyle(
                            fontSize: regularText, color: primaryColor),
                      )
                    ],
                    const TextSpan(
                      text: ".",
                      style:
                          TextStyle(fontSize: regularText, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: primarySizedBox),
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
