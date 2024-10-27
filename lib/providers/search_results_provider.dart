import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final searchResultsServiceProviders =
    FutureProvider.family<List<dynamic>, String>((ref, category) async {
  final supabase = Supabase.instance.client;

  final response = await supabase.rpc('get_service_providers', params: {
    'service_category_param': category,
  });

  return response as List<dynamic>;
});
