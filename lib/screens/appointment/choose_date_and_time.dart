import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/appointment_summary.dart';

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
            Text(
              selectedDate != null
                  ? DateFormat('MMMM dd, yyyy')
                      .format(DateTime.parse(selectedDate))
                  : 'No date selected',
              style: const TextStyle(fontSize: regularText),
            ),
            const SizedBox(height: 16),
            customPaddedTextButtonWIthSecondaryColor(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate != null
                      ? DateTime.parse(selectedDate)
                      : DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (pickedDate != null) {
                  ref.read(selectedDateProvider.notifier).state =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  ref.read(selectedTimeslotProvider.notifier).state =
                      null; // Clear timeslot when date changes
                }
              },
              text: "Choose Date",
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
                            child:
                                Text('No available timeslots for this date.'));
                      }
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        Center(child: Text('Error: $error')),
                  ),
          ],
        ),
      ),
    );
  }
}
