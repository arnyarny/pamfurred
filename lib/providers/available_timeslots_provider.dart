import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceProviderAvailableTimeslotsProvider =
    FutureProvider.family<List<String>, TimeslotParams>((ref, params) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('service_provider_availability')
        .select('timeslots')
        .eq('sp_id', params.spId)
        .eq('availability_date', params.selectedDate)
        .single();


    final timeslots = response['timeslots'] as List<dynamic>?;
    if (timeslots == null || timeslots.isEmpty) {
      return [];
    }

    // Map timeslots to a List<String>
    return timeslots.map((e) => e.toString()).toList();
  } catch (e) {
    throw Exception('Error fetching available timeslots: $e');
  }
});

class TimeslotParams {
  final String spId;
  final String selectedDate;

  TimeslotParams({required this.spId, required this.selectedDate});
}
