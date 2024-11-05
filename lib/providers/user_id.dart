import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userIdProvider = StateProvider<String?>((ref) {
  final userSession = Supabase.instance.client.auth.currentSession;

  return userSession?.user.id; // Returns the pet owner user ID
});
