import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';

// Provider to manage selected date
final selectedDateProvider = StateProvider<String?>((ref) => null);
// Provider to manage selected timeslot
final selectedTimeslotProvider = StateProvider<String?>((ref) => null);

class ChooseDateAndTimeScreen extends ConsumerWidget {
  const ChooseDateAndTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedTimeslot = ref.watch(selectedTimeslotProvider);
    final serviceProviderId = ref.watch(selectedSpIndexProvider);

    // Define parameters for timeslots provider
    TimeslotParams? timeslotParams;
    if (selectedDate != null && serviceProviderId.isNotEmpty) {
      timeslotParams = TimeslotParams(spId: serviceProviderId, selectedDate: selectedDate);
    }

    // Watch the provider to get available timeslots
    final timeslotsAsync = timeslotParams != null
        ? ref.watch(serviceProviderAvailableTimeslotsProvider(timeslotParams))
        : const AsyncValue.loading();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Date and Time')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Section
            const Text('Select a Date:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              selectedDate != null
                  ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(selectedDate))
                  : 'No date selected',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate != null ? DateTime.parse(selectedDate) : DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (pickedDate != null) {
                  ref.read(selectedDateProvider.notifier).state = DateFormat('yyyy-MM-dd').format(pickedDate);
                  ref.read(selectedTimeslotProvider.notifier).state = null; // Clear timeslot when date changes
                }
              },
              child: const Text("Choose Date"),
            ),
            const SizedBox(height: 24),

            // Timeslot Selector Section
            const Text('Available Timeslots:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            if (selectedDate == null) 
              const Text('Please select a date to see available timeslots.')
            else if (timeslotsAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (timeslotsAsync.hasError)
              Center(child: Text('Error: ${timeslotsAsync.error}'))
            else 
              Expanded(
                child: timeslotsAsync.when(
                  data: (timeslotData) {
                    final timeslots = (timeslotData.isNotEmpty
                        ? timeslotData[0]['timeslots'] as List<dynamic>
                        : []) as List<String>;

                    if (timeslots.isEmpty) {
                      return const Center(child: Text('No available timeslots for this date.'));
                    }

                    // ListView to display timeslots
                    return ListView.builder(
                      itemCount: timeslots.length,
                      itemBuilder: (context, index) {
                        final timeslot = timeslots[index];
                        return ListTile(
                          title: Text(timeslot),
                          onTap: () {
                            // Update selected timeslot
                            ref.read(selectedTimeslotProvider.notifier).state = timeslot;
                            // Show confirmation or perform an action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selected Time: $timeslot')),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),

            // Confirm Button
            Center(
              child: ElevatedButton(
                onPressed: selectedDate != null && selectedTimeslot != null
                    ? () {
                        // Perform action with selected date and timeslot.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Selected Date: $selectedDate\n'
                              'Selected Time: $selectedTimeslot',
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text("Confirm Selection"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
