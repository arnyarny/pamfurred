import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/globals.dart';

// Assuming you have a function to fetch appointment details from Supabase
Future<Map<String, dynamic>> fetchAppointmentDetails() async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase.rpc('get_appointment_details_with_services_and_packages');

  final dataList = List<Map<String, dynamic>>.from(response);
  if (dataList.isEmpty) {
    throw Exception('No appointment details found.');
  }

  return {'appointments': dataList};
}

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  AppointmentsScreenState createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, Color> statusColors = {
    'Upcoming': const Color.fromRGBO(255, 143, 0, 1),
    'Done': Colors.green,
    'Cancelled': const Color.fromRGBO(160, 62, 6, 1),
  };

  // Create a provider for fetching appointment details
  final appointmentDetailsProvider =
      FutureProvider<Map<String, dynamic>>((ref) async {
    return await fetchAppointmentDetails();
  });

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the appointment details provider for appointment data
    final appointmentAsyncValue = ref.watch(appointmentDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            _buildTab('Today'),
            _buildTab('Upcoming'),
            _buildTab('All'),
            _buildTab('Done'),
            _buildTab('Cancelled'),
          ],
          labelColor: tangerine,
          indicatorColor: tangerine,
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
        ),
      ),
      body: Center(
        child: appointmentAsyncValue.when(
          data: (appointmentData) {
            final appointmentList =
                appointmentData['appointments'] as List<Map<String, dynamic>>;

            return TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: List.generate(5, (index) {
                return _buildAppointmentList(index, appointmentList);
              }),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Text(text),
    );
  }

  Widget _buildAppointmentList(
      int tabIndex, List<Map<String, dynamic>> appointmentList) {
    // Filter appointments based on the selected tab index
    final filteredAppointments = appointmentList.where((appointment) {
      final dateFormat = DateFormat('MM/dd/yyyy'); // Define the date format
      DateTime appointmentDate;

      try {
        appointmentDate = dateFormat.parse(appointment['appointment_date']);
      } catch (e) {
        appointmentDate =
            DateTime.now(); // Fallback to the current date if parsing fails
      }

      switch (tabIndex) {
        case 0: // Today
          final today = DateTime.now();
          return appointmentDate.month == today.month &&
              appointmentDate.day == today.day &&
              appointmentDate.year == today.year;
        case 1: // Upcoming
          return appointment['appointment_status'] == 'Upcoming';
        case 2: // All
          return true; // No filter for "All"
        case 3: // Done
          return appointment['appointment_status'] == 'Done';
        case 4: // Cancelled
          return appointment['appointment_status'] == 'Cancelled';
        default:
          return false;
      }
    }).toList();

    // If no filtered appointments match, show a message
    if (filteredAppointments.isEmpty) {
      return const Center(child: Text('No Appointments Available'));
    }

    // Return a list of filtered appointments
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];

        return Card(
          color: Colors.white,
          elevation: 1.5,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: customBoldWeightRegularText(context,
                  '${appointment['user_id'] ?? 'N/A'}'), // Fallback if null
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: primarySizedBox),
                  Text(
                    appointment['appointment_date'] == null ? 'N/A' : formatDate(appointment['appointment_date']), // Fallback if null
                    style: const TextStyle(color: darkGreyColor),
                  ),
                  const SizedBox(height: primarySizedBox),
                  Text(
                    appointment['appointment_time'] == null
                        ? 'N/A'
                        : formatTime(appointment[
                            'appointment_time']), // Fallback if null
                    style: const TextStyle(color: greyColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    appointment['appointment_status'] ??
                        'Unknown', // Fallback if null
                    style: TextStyle(
                      color: statusColors[appointment['appointment_status']] ??
                          Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
