import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/providers/ratings_and_reviews_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:rating_summary/rating_summary.dart';

class RatingsAndReviewsWidget extends ConsumerWidget {
  const RatingsAndReviewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spId =
        ref.watch(selectedSpIndexProvider); // Use watch instead of read

    // Watch the provider and automatically rebuild when data changes
    final ratingsSummaryWithReviews =
        ref.watch(ratingsSummaryWithReviewsProvider(spId));

    return ratingsSummaryWithReviews.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error fetching ratings: $error'),
      ),
      data: (data) {
        if (data == null || data.isEmpty) {
          return const Center(child: Text('No ratings available.'));
        }

        // Extract rating summary details and reviews
        final ratingSummary = data.first; // First entry contains summary
        final reviews = data.skip(1).where((review) {
          // Filter out feedbacks that don't have a review comment
          return review['review'] != null;
        }).toList(); // Only keep feedbacks that have reviews

        if (reviews.isEmpty) {
          return const Center(child: Text('No reviews available.'));
        }

        return Column(
          children: [
            // Rating summary widget
            RatingSummary(
              counter: ratingSummary['count_1'] +
                  ratingSummary['count_2'] +
                  ratingSummary['count_3'] +
                  ratingSummary['count_4'] +
                  ratingSummary['count_5'],
              average: ratingSummary['average_rating'],
              showAverage: true,
              counterFiveStars: ratingSummary['count_5'],
              counterFourStars: ratingSummary['count_4'],
              counterThreeStars: ratingSummary['count_3'],
              counterTwoStars: ratingSummary['count_2'],
              counterOneStars: ratingSummary['count_1'],
            ),
            const SizedBox(height: 20),

            // Reviews section
            SizedBox(
              height: 120, // Adjust height for cards
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: tertiarySizedBox),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: reviews.length > 10 ? 10 : reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    color: lighterGreyColor,
                    margin:
                        const EdgeInsets.symmetric(horizontal: primarySizedBox),
                    child: Container(
                      width: 220, // Adjust card width
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reviewer's name
                          Text(
                            (review['first_name'] ?? '') +
                                ' ' +
                                (review['last_name'] ?? ''),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),
                          // Comment (if available)
                          if (review['review'] != null)
                            Text(
                              review['review'],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            const Text(
                              'No comment provided.',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: greyColor,
                              ),
                            ),

                          const SizedBox(height: primarySizedBox),
                          // Star rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ratingWidget(review['rating'].toString()),
                                ],
                              ),
                              Row(
                                children: [
                                  // Date of the review
                                  Text(
                                    review['review_date'],
                                    style: const TextStyle(
                                      color: greyColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
