import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';

// Sample list of timeslots - replace with actual timeslot fetching logic.
final availableTimeslotsProvider = Provider<List<String>>((ref) {
  return [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM'
  ];
});

// Provider to manage selected date and time.
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeslotProvider = StateProvider<String?>((ref) => null);

class ChooseDateAndTimeScreen extends ConsumerWidget {
  const ChooseDateAndTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeslot = ref.watch(selectedTimeslotProvider);
    final timeslots = ref.watch(availableTimeslotsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBarWithTitle(context, 'Choose Date and Time'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            const Text(
              'Select a Date:',
              style: TextStyle(fontSize: titleFont),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('MMMM dd, yyyy').format(selectedDate)
                      : 'No date selected',
                  style: const TextStyle(
                      fontSize: regularText,
                      fontWeight: regularWeight,
                      color: darkGreyColor),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (pickedDate != null) {
                      ref.read(selectedDateProvider.notifier).state =
                          pickedDate;
                      ref.read(selectedTimeslotProvider.notifier).state =
                          null; // Clear timeslot when date changes
                    }
                  },
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        primaryColor,
                      )),
                  child: const Text(
                    "Choose Date",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: regularText,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Timeslot Selector
            const Text(
              'Available Timeslots:',
              style: TextStyle(fontSize: titleFont),
            ),
            const SizedBox(height: 8),
            if (selectedDate == null)
              const Text('Please select a date to view available timeslots.')
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: timeslots.map((timeslot) {
                  final isSelected = timeslot == selectedTimeslot;
                  return ChoiceChip(
                    label: Text(timeslot),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    onSelected: (_) {
                      ref.read(selectedTimeslotProvider.notifier).state =
                          timeslot;
                    },
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            const Spacer(),

            // Confirm Button
            Center(
              child: ElevatedButton(
                onPressed: selectedDate != null && selectedTimeslot != null
                    ? () {
                        // Perform action with selected date and timeslot.
                        // Example: navigate to the next screen or save the data.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Selected Date: ${DateFormat('MMMM dd, yyyy').format(selectedDate)}\n'
                                'Selected Time: $selectedTimeslot'),
                          ),
                        );
                      }
                    : null,
                style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(secondaryBorderRadius),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                      primaryColor,
                    )),
                child: const Text(
                  "Confirm Selection",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: regularText,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
