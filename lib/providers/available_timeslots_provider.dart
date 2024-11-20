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

final availableDatesProvider = FutureProvider<List<String>>((ref) async {
  final serviceProviderId = ref.watch(selectedSpIndexProvider);

  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('service_provider_availability')
      .select('availability_date')
      .eq('sp_id', serviceProviderId);

  // Extract and return the list of dates
  return List<String>.from(response.map((e) => e['availability_date']));
});
