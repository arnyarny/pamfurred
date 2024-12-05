import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/appointment_summary.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class ChooseDateAndTimeScreen extends ConsumerWidget {
  const ChooseDateAndTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeslot = ref.watch(selectedTimeslotProvider);

    return Scaffold(
      appBar: customAppBarWithTitleAndWidget(context, 'Select Date & Time', [
        TextButton(
          style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(secondaryBorderRadius),
                ),
              ),
              backgroundColor: WidgetStateProperty.all<Color>(
                  selectedDate != null && selectedTimeslot != null
                      ? primaryColor
                      : lighterGreyColor)),
          onPressed: selectedDate != null && selectedTimeslot != null
              ? () {
                  Navigator.push(context,
                      rightToLeftRoute(const AppointmentSummaryScreen()));
                }
              : null,
          child: Text(
            "Next",
            style: TextStyle(
              color: selectedDate != null && selectedTimeslot != null
                  ? Colors.white
                  : disabledButtonTextColor,
            ),
          ),
        ),
      ]),
      backgroundColor: Colors.white,
      body: PullToRefresh(
        providersToRefresh: [
          availableDatesProvider,
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: getScreenWidth(context),
            height: getScreenHeight(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select a date:',
                        style: TextStyle(fontSize: titleFont)),
                    IconButton(
                      icon: const Icon(Icons.help_outline_outlined, size: 25),
                      onPressed: () => _showColorLegend(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TableCalendar(
                  pageAnimationCurve:
                      Curves.bounceOut, // Bouncy effect for page animations
                  formatAnimationCurve: Curves.bounceOut,
                  pageAnimationDuration: const Duration(
                      milliseconds: 500), // Slightly longer for emphasis
                  formatAnimationDuration:
                      const Duration(milliseconds: 500), // Same here
                  pageAnimationEnabled: false,
                  focusedDay: selectedDate != null
                      ? DateTime.parse(selectedDate)
                      : DateTime.now(),
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  selectedDayPredicate: (day) {
                    return selectedDate != null &&
                        DateFormat('yyyy-MM-dd').format(day) == selectedDate;
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    final formattedDate =
                        DateFormat('yyyy-MM-dd').format(selectedDay);

                    // Check if the date is available and not fully booked or has no timeslots
                    final availableDatesAsyncValue =
                        ref.read(availableDatesProvider);
                    availableDatesAsyncValue.when(
                      data: (availableDates) {
                        final availability = availableDates.firstWhere(
                          (availability) =>
                              availability['availability_date'] ==
                              formattedDate,
                          orElse: () => {'is_fully_booked': false},
                        );

                        if (availability['is_fully_booked'] == false) {
                          ref
                              .read(availableTimeslotsProvider(formattedDate))
                              .when(
                                data: (timeslotData) {
                                  if (timeslotData.isNotEmpty) {
                                    ref
                                        .read(selectedDateProvider.notifier)
                                        .state = formattedDate;
                                    ref
                                        .read(selectedTimeslotProvider.notifier)
                                        .state = null;
                                  }
                                },
                                loading: () {}, // Handle loading if needed
                                error: (error,
                                    stackTrace) {}, // Handle error if needed
                              );
                        }
                      },
                      loading: () {}, // Handle loading if needed
                      error: (error, stackTrace) {}, // Handle error if needed
                    );
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final formattedDate =
                          DateFormat('yyyy-MM-dd').format(date);

                      final availableDatesAsyncValue =
                          ref.watch(availableDatesProvider);
                      final availableTimeslotsAsyncValue =
                          ref.watch(availableTimeslotsProvider(formattedDate));

                      return availableDatesAsyncValue.when(
                        data: (availableDates) {
                          final availability = availableDates.firstWhere(
                            (availability) =>
                                availability['availability_date'] ==
                                formattedDate,
                            orElse: () => {'is_fully_booked': false},
                          );

                          return availableTimeslotsAsyncValue.when(
                            data: (timeslotData) {
                              if (availability['is_fully_booked'] == true) {
                                // Fully booked dates are red
                                return Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              } else if (timeslotData.isEmpty) {
                                // Dates without timeslots are greyed out
                                return Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              } else {
                                // Available dates are green
                                return Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${date.day}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                            },
                            loading: () => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            error: (error, stackTrace) => Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.error_outline,
                                  size: 40,
                                  color: Colors.grey,
                                )),
                          );
                        },
                        loading: () => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        error: (error, stackTrace) => const Text('Error'),
                      );
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.arrow_left,
                      color: Colors.black,
                    ),
                    rightChevronIcon: Icon(
                      Icons.arrow_right,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: quaternarySizedBox),

                // Timeslot Selector Section
                const Text('Select time:',
                    style: TextStyle(fontSize: titleFont)),
                const SizedBox(height: 8),
                if (selectedDate == null)
                  const Text('Please select a date to see available timeslots.')
                else
                  ref.watch(availableTimeslotsProvider(selectedDate)).when(
                        data: (timeslotData) {
                          // Watch appointments for the selected date
                          final appointmentsAsyncValue = ref.watch(
                              fetchAppointmentsPerDateProvider(selectedDate));

                          return appointmentsAsyncValue.when(
                            data: (appointments) {
                              final bookedTimeslots = appointments
                                  .where((appointment) =>
                                      appointment['appointment_status'] !=
                                      'Cancelled')
                                  .map((appointment) =>
                                      appointment['appointment_time'])
                                  .toSet();

                              final timeslotMap = <String, List<String>>{};
                              for (var slot in timeslotData) {
                                final date = slot['availability_date'];
                                final timeslots =
                                    List<String>.from(slot['timeslots']);
                                timeslotMap[date] = timeslots;
                              }

                              if (timeslotMap.containsKey(selectedDate)) {
                                final timeslots = timeslotMap[selectedDate]!;

                                return Column(
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: timeslots.map((timeslot) {
                                        final isBooked =
                                            bookedTimeslots.contains(timeslot);
                                        return ChoiceChip(
                                          label: Text(formatTime(timeslot)),
                                          selected:
                                              selectedTimeslot == timeslot,
                                          onSelected: isBooked
                                              ? null // Disable selection for booked slots
                                              : (selected) {
                                                  ref
                                                          .read(
                                                              selectedTimeslotProvider
                                                                  .notifier)
                                                          .state =
                                                      selected
                                                          ? timeslot
                                                          : null;
                                                },
                                          selectedColor: secondaryColor,
                                          backgroundColor: isBooked
                                              ? Colors.grey
                                              : Colors.transparent,
                                          labelStyle: TextStyle(
                                              color: isBooked
                                                  ? disabledButtonTextColor
                                                  : (selectedTimeslot ==
                                                          timeslot
                                                      ? lighterGreyColor
                                                      : Colors.black),
                                              fontSize: regularText),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(
                                      height: secondarySizedBox,
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          width: primarySizedBox,
                                        ),
                                        Text(
                                          'Disabled timeslots are unavailable for booking.',
                                          style: TextStyle(
                                              fontSize: smallText,
                                              color: darkGreyColor),
                                        )
                                      ],
                                    )
                                  ],
                                );
                              } else {
                                return const Center(
                                    child: Text(
                                        'No available timeslots for this date.'));
                              }
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stackTrace) => const Center(
                                child: Icon(Icons.error, size: 30)),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) =>
                            const Center(child: Icon(Icons.error, size: 30)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getLegendWidget(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color, // Accepts any Color now
          ),
        ),
        const SizedBox(width: secondarySizedBox),
        Text(
          text,
          style: const TextStyle(fontSize: smallText),
        ),
      ],
    );
  }

  void _showColorLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // White background for a clean look
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16), // Rounded corners for elegance
          ),
          elevation: 8, // Adding some elevation to create a floating effect
          title: const Text(
            'Color Legend',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Dark title for contrast
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getLegendWidget(Colors.green, 'Available'),
                const SizedBox(height: 12), // Increased space between items
                getLegendWidget(Colors.grey, 'Not available'),
                const SizedBox(height: 12),
                getLegendWidget(Colors.red, 'Fully booked'),
                const SizedBox(height: 12),
                getLegendWidget(primaryColor, 'Date today'),
                const SizedBox(height: 12),
                getLegendWidget(secondaryColor, 'Date selected'),
              ],
            ),
          ),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 8.0), // Padding for spacing
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Correct property to set background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded button
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10), // Button padding
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
