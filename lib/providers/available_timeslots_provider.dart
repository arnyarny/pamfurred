import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Sample list of timeslots - replace with actual timeslot fetching logic.
final availableTimeslotsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, spId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('app')
      .select(
          'sp_id, image, name, rating, latitude, longitude, sentiment_label, category, user:user_id(user_type)')
      .eq('user.user_type', 'service_provider')
      .eq('service_provider.service_provider_id', spId);

  return response as List<dynamic>;
});
