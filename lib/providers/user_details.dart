import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

// StreamProvider to listen for changes in the auth session
final userSessionProvider = StreamProvider<supabase_flutter.AuthState>((ref) {
  // Return the stream that listens for auth state changes
  return supabase_flutter.Supabase.instance.client.auth.onAuthStateChange;
});

// Provider to hold the user ID (if logged in)
final userIdProvider = Provider<String?>((ref) {
  // Get the current auth state from the userSessionProvider
  final authState = ref.watch(userSessionProvider);

  // If there's an authenticated session, return the user ID
  return authState.when(
    data: (session) => session.session?.user.id, // Accessing user from session
    loading: () => null, // If loading, return null
    error: (err, stack) => null, // If error, return null
  );
});

final userFirstNameProvider = StateProvider<String>((ref) => '');
final userLastNameProvider = StateProvider<String>((ref) => '');

final userPhoneNumberProvider = StateProvider<String>((ref) => '');