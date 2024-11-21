import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>?> fetchRatingsSummaryWithReviews(
    String spId) async {
  final SupabaseClient client = Supabase.instance.client;
  final response = await client
      .rpc('fetch_ratings_summary_with_reviews', params: {'sp_id_param': spId});

  return List<Map<String, dynamic>>.from(response ?? []);
}

final ratingsSummaryWithReviewsProvider =
    FutureProvider.family<List<Map<String, dynamic>>?, String>(
        (ref, spId) async {
  return await fetchRatingsSummaryWithReviews(spId);
});
