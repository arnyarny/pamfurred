import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceProviderAvailableTimeslotsProvider =
    FutureProvider.family<List<String>, TimeslotParams>((ref, params) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('service_provider_availability')
      .select('timeslots')
      .eq('sp_id', params.spId)
      .eq('availability_date', params.selectedDate)
      .single();

  if (response.error != null) {
    throw Exception(response.error!.message);
  }

  final timeslots = (response.data['timeslots'] as List<dynamic>)
      .map((e) => e.toString())
      .toList();
  return timeslots;
});

class TimeslotParams {
  final String spId;
  final String selectedDate;

  TimeslotParams({required this.spId, required this.selectedDate});
}
