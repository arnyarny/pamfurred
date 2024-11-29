import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/appointment_summary.dart';
import 'package:table_calendar/table_calendar.dart';

class ChooseDateAndTimeScreen extends ConsumerWidget {
  const ChooseDateAndTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeslot = ref.watch(selectedTimeslotProvider);

    return Scaffold(
      appBar: customAppBarWithTitleAndWidget(context, 'Choose Date & Time', [
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Section
            const Text('Select a Date:', style: TextStyle(fontSize: titleFont)),
            const SizedBox(height: 8),
            TableCalendar(
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
                ref.read(selectedDateProvider.notifier).state =
                    DateFormat('yyyy-MM-dd').format(selectedDay);
                ref.read(selectedTimeslotProvider.notifier).state =
                    null; // Clear timeslot when date changes
              },
              // Styling of the day cells
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
            const SizedBox(height: 24),

            // Timeslot Selector Section
            const Text('Available Timeslots:',
                style: TextStyle(fontSize: titleFont)),
            const SizedBox(height: 8),
            if (selectedDate == null)
              const Text('Please select a date to see available timeslots.')
            else
              ref.watch(availableTimeslotsProvider(selectedDate)).when(
                  data: (timeslotData) {
                    final timeslotMap = <String, List<String>>{};
                    for (var slot in timeslotData) {
                      final date = slot['availability_date'];
                      final timeslots = List<String>.from(slot['timeslots']);
                      timeslotMap[date] = timeslots;
                    }

                    if (timeslotMap.containsKey(selectedDate)) {
                      final timeslots = timeslotMap[selectedDate]!;
                      return Wrap(
                        spacing: 8.0, // Space between chips
                        runSpacing: 8.0, // Space between rows of chips
                        children: timeslots.map((timeslot) {
                          return ChoiceChip(
                            label: Text(formatTime(timeslot)),
                            selected: selectedTimeslot == timeslot,
                            onSelected: (selected) {
                              ref
                                  .read(selectedTimeslotProvider.notifier)
                                  .state = selected ? timeslot : null;
                            },
                            selectedColor: secondaryColor,
                            checkmarkColor: lighterGreyColor,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                                color: selectedTimeslot == timeslot
                                    ? lighterGreyColor
                                    : Colors.black,
                                fontSize: regularText),
                          );
                        }).toList(),
                      );
                    } else {
                      return const Center(
                          child: Text('No available timeslots for this date.'));
                    }
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('Error: $error'))),
          ],
        ),
      ),
    );
  }
}
