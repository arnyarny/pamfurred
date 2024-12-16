import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_floating_action_button.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/legends.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/appointment_summary.dart';
import 'package:pamfurred/screens/appointment/serviceprovider_profile.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class ChooseDateAndTimeScreen extends ConsumerStatefulWidget {
  const ChooseDateAndTimeScreen({super.key});

  @override
  ChooseDateAndTimeScreenState createState() => ChooseDateAndTimeScreenState();
}

class ChooseDateAndTimeScreenState
    extends ConsumerState<ChooseDateAndTimeScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeslot = ref.watch(selectedTimeslotProvider);

    return Scaffold(
      appBar: customAppBarWithTitleAndWidget(context, 'Select Date & Time', [
        customSmallPaddedTextButton(
          text: 'Cancel',
          backgroundColor: Colors.red,
          onPressed: () {
            QuickAlert.show(
                context: context,
                type: QuickAlertType.warning,
                animType: QuickAlertAnimType.slideInUp,
                confirmBtnColor: Colors.red,
                showCancelBtn: true,
                onConfirmBtnTap: () {
                  Navigator.push(
                      context,
                      crossFadeRoute(const MainScreen(
                        initialPage: 0,
                      )));

                  // Clear the cart when this button is pressed
                  ref.read(cartNotifierProvider.notifier).clearCart();
                  ref.read(willBookProvider.notifier).state = false;
                  // If willBook is false, reset the providers
                  resetProviders(ref);
                },
                title: 'Cancel appointment?',
                text:
                    'This will delete all your appointment preferences including all the services and packages currently in your cart.');
          },
        )
      ]),
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: customFloatingActionButton(
        context,
        buttonText: 'Next',
        isEnabled: selectedDate != null && selectedTimeslot != null,
        onPressed: () {
          Navigator.push(
            context,
            rightToLeftRoute(const AppointmentSummaryScreen()),
          );
        },
      ),
      body: PullToRefresh(
        providersToRefresh: [
          availableDatesProvider,
        ],
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: screenPadding(context),
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
                          icon:
                              const Icon(Icons.help_outline_outlined, size: 25),
                          onPressed: () => showColorLegend(context),
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
                            DateFormat('yyyy-MM-dd').format(day) ==
                                selectedDate;
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
                                  .read(
                                      availableTimeslotsProvider(formattedDate))
                                  .when(
                                    data: (timeslotData) {
                                      if (timeslotData.isNotEmpty) {
                                        ref
                                            .read(selectedDateProvider.notifier)
                                            .state = formattedDate;
                                        ref
                                            .read(selectedTimeslotProvider
                                                .notifier)
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
                          error:
                              (error, stackTrace) {}, // Handle error if needed
                        );
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, date, _) {
                          final formattedDate =
                              DateFormat('yyyy-MM-dd').format(date);

                          final availableDatesAsyncValue =
                              ref.watch(availableDatesProvider);
                          final availableTimeslotsAsyncValue = ref
                              .watch(availableTimeslotsProvider(formattedDate));

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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                                        style: const TextStyle(
                                            color: Colors.white),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select time:',
                            style: TextStyle(fontSize: titleFont)),
                        IconButton(
                          icon:
                              const Icon(Icons.help_outline_outlined, size: 25),
                          onPressed: () => showTimeslotsColorLegend(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedDate == null)
                      const Text(
                          'Please select a date to see available timeslots.')
                    else
                      ref.watch(availableTimeslotsProvider(selectedDate)).when(
                            data: (timeslotData) {
                              // Watch appointments for the selected date
                              final appointmentsAsyncValue = ref.watch(
                                  fetchAppointmentsPerDateProvider(
                                      selectedDate));

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
                                    final timeslots =
                                        timeslotMap[selectedDate]!;

                                    return Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: timeslots.map((timeslot) {
                                        // Determine if the timeslot is past the current time
                                        bool isPastTime = false;
                                        if (selectedDate ==
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now())) {
                                          final currentTime = TimeOfDay.now();
                                          final timeslotTime =
                                              TimeOfDay.fromDateTime(
                                            DateFormat('HH:mm').parse(timeslot),
                                          );

                                          // Check if the timeslot is earlier than the current time
                                          if (timeslotTime.hour <
                                                  currentTime.hour ||
                                              (timeslotTime.hour ==
                                                      currentTime.hour &&
                                                  timeslotTime.minute <=
                                                      currentTime.minute)) {
                                            isPastTime = true;
                                          }
                                        }

                                        final isBooked =
                                            bookedTimeslots.contains(timeslot);

                                        return ChoiceChip(
                                          label: Text(formatTime(timeslot)),
                                          selected:
                                              selectedTimeslot == timeslot,
                                          onSelected: (selected) {
                                            if (!isBooked && !isPastTime) {
                                              ref
                                                      .read(
                                                          selectedTimeslotProvider
                                                              .notifier)
                                                      .state =
                                                  selected ? timeslot : null;
                                            }
                                          },
                                          selectedColor: secondaryColor,
                                          backgroundColor: isBooked
                                              ? const Color.fromARGB(
                                                  255,
                                                  255,
                                                  176,
                                                  170) // Booked timeslots are red
                                              : isPastTime
                                                  ? lighterGreyColor // Past timeslots are lighter grey
                                                  : Colors
                                                      .transparent, // Available timeslots are transparent

                                          labelStyle: TextStyle(
                                            color: isBooked || isPastTime
                                                ? disabledButtonTextColor
                                                : (selectedTimeslot == timeslot
                                                    ? lighterGreyColor
                                                    : Colors.black),
                                            fontSize: regularText,
                                          ),
                                        );
                                      }).toList(),
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
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stackTrace) => const Center(
                                child: Icon(Icons.error, size: 30)),
                          ),
                    const SizedBox(height: 80)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
