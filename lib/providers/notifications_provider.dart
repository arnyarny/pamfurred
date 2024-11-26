import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

Future<Map<String, dynamic>> fetchNotificationDetails(String userId) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  // Call the RPC function with the userId parameter
  final response = await supabase
      .rpc('fetch_notification_details', params: {'user_id_param': userId});

  final dataList = List<Map<String, dynamic>>.from(response);

  return {'notifications': dataList};
}

// Create a provider for fetching notification details
final notificationDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  return await fetchNotificationDetails(userId);
});
