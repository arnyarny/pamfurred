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

// // Provider to fetch notification details by notification_id
// final notificationDetailsProvider =
//     FutureProvider.family<Map<String, dynamic>, String>(
//         (ref, notificationId) async {
//   final supabase = supabase_flutter.Supabase.instance.client;

//   // Fetch notification details based on notification_id
//   final response = await supabase
//       .from('notification') // Replace with your actual table name
//       .select('*')
//       .eq('notification_id', notificationId) // Filter by notification_id
//       .single(); // Since we're fetching a single notification

//   // Return the fetched notification details as a map
//   return response as Map<String, dynamic>;
// });

// Provider for managing the appointment notification_id
final notificationIdProvider = StateProvider<String>((ref) => '');

// Provider for managing the selected notification_id
final selectedNotificationIdProvider = StateProvider<String>((ref) => '');

// Provider to get the selected notification details
final selectedNotificationProvider = Provider<Map<String, dynamic>?>((ref) {
  final notificationId = ref.watch(selectedNotificationIdProvider);
  final notificationDetails =
      ref.watch(notificationDetailsProvider(notificationId));

  // Return the fetched notification details or null if not found
  return notificationDetails.when(
    data: (data) => data,
    loading: () => null, // Show loading state while fetching
    error: (error, stack) => null, // Handle error state
  );
});
