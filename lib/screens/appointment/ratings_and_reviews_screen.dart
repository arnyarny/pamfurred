import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/providers/ratings_and_reviews_provider.dart';
import 'package:pamfurred/providers/reviews_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:rating_summary/rating_summary.dart';

class RatingsAndReviewsScreen extends ConsumerStatefulWidget {
  const RatingsAndReviewsScreen({super.key});

  @override
  RatingsAndReviewsScreenState createState() => RatingsAndReviewsScreenState();
}

class RatingsAndReviewsScreenState
    extends ConsumerState<RatingsAndReviewsScreen> {
  // This map stores the expanded/collapsed state of each review based on its index
  Map<int, bool> expandedStates = {};

  @override
  Widget build(BuildContext context) {
    final spId =
        ref.watch(selectedSpIndexProvider); // Use watch instead of read

    // Watch the provider and automatically rebuild when data changes
    final ratingsSummaryWithReviews =
        ref.watch(ratingsSummaryWithReviewsProvider(spId));

    return Scaffold(
      appBar: customAppBarWithTitle(context, 'Ratings & Reviews'),
      body: ratingsSummaryWithReviews.when(
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

          return PullToRefresh(
            providersToRefresh: [reviewsProvider],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Rating summary widget
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RatingSummary(
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
                  ),
                  const SizedBox(height: secondarySizedBox),
                  // Reviews section - Vertical ListView
                  ListView.builder(
                    shrinkWrap:
                        true, // Make ListView take only as much space as needed
                    physics:
                        const BouncingScrollPhysics(), // Disable internal scrolling
                    padding: const EdgeInsets.fromLTRB(tertiarySizedBox, 0,
                        tertiarySizedBox, quaternarySizedBox),
                    itemCount: reviews.length > 10 ? 10 : reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      bool isExpanded = expandedStates[index] ?? false;

                      return GestureDetector(
                        onTap: () {
                          // Toggle the review visibility
                          setState(() {
                            expandedStates[index] = !isExpanded;
                          });
                        },
                        child: Card(
                          color: lighterGreyColor,
                          margin: const EdgeInsets.all(primarySizedBox),
                          child: Container(
                            padding: const EdgeInsets.all(secondarySizedBox),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Reviewer's name
                                Text(
                                  review['first_name'] +
                                      ' ' +
                                      review['last_name'],
                                  style: const TextStyle(
                                    fontWeight: boldWeight,
                                    fontSize: regularText,
                                  ),
                                ),
                                const SizedBox(height: secondarySizedBox),

                                // Review content with ellipsis and full review toggle
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: SizedBox(
                                    height: review['review'].length > 30 &&
                                            !isExpanded
                                        ? 30
                                        : null, // Apply height limit only for long reviews
                                    child: Text(
                                      review['review'],
                                      style:
                                          const TextStyle(fontSize: smallText),
                                      overflow: isExpanded ||
                                              review['review'].length <= 30
                                          ? TextOverflow.visible
                                          : TextOverflow
                                              .ellipsis, // No ellipsis for short texts
                                    ),
                                  ),
                                ),

                                const SizedBox(height: secondarySizedBox),

                                // Star rating
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        ratingWidget(
                                            review['rating'].toString()),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // Date of the review
                                        Text(
                                          review['review_date'],
                                          style: const TextStyle(
                                            color: greyColor,
                                            fontSize: smallText,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
