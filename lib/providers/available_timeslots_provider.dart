import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider to fetch available timeslots
final availableTimeslotsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, selectedDate) async {
  final serviceProviderId = ref.watch(selectedSpIndexProvider);

  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('service_provider_availability')
      .select('availability_date, timeslots')
      .eq('sp_id', serviceProviderId)
      .eq('availability_date', selectedDate);

  return List<Map<String, dynamic>>.from(response);
});

final availableDatesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final serviceProviderId = ref.watch(selectedSpIndexProvider);

  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('service_provider_availability')
      .select('*')
      .eq('sp_id', serviceProviderId);

  // Map the response to include the 'availability_date' and 'is_fully_booked' fields
  return List<Map<String, dynamic>>.from(response.map((e) => {
        'availability_date': e['availability_date'],
        'is_fully_booked': e['is_fully_booked'],
      }));
});
