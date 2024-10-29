import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceProviderFutureProvider =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('service_provider')
      .select(
          'image, name, rating, latitude, longitude, sentiment_label, category, user:user_id(user_type)')
      .contains('category', '["$category"]')
      .eq('user.user_type', 'service_provider');

  return response as List<dynamic>;
});
