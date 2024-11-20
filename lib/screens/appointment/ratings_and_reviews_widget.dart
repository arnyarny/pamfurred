import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:rating_summary/rating_summary.dart';

class RatingsAndReviewsWidget extends ConsumerWidget {
  const RatingsAndReviewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample review data
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'Alice',
        'comment':
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
        'rating': 5,
        'date': '2024-11-20'
      },
      {
        'name': 'Bob',
        'comment': 'Satisfactory experience.',
        'rating': 4,
        'date': '2024-11-18'
      },
      {
        'name': 'Charlie',
        'comment': 'Could be better.',
        'rating': 3,
        'date': '2024-11-17'
      },
      {
        'name': 'Diana',
        'comment': 'Loved it! Highly recommend.',
        'rating': 5,
        'date': '2024-11-15'
      },
      {
        'name': 'Eve',
        'comment': 'Not what I expected.',
        'rating': 2,
        'date': '2024-11-14'
      },
      {'name': 'Frank', 'comment': null, 'rating': 4, 'date': '2024-11-13'},
      {
        'name': 'Grace',
        'comment': 'Good value for money.',
        'rating': 4,
        'date': '2024-11-12'
      },
      {'name': 'Hank', 'comment': null, 'rating': 3, 'date': '2024-11-11'},
      {
        'name': 'Ivy',
        'comment': 'Fantastic performance.',
        'rating': 5,
        'date': '2024-11-10'
      },
      {
        'name': 'Jack',
        'comment': 'Would buy again!',
        'rating': 5,
        'date': '2024-11-09'
      },
    ];

    return Column(
      children: [
        const RatingSummary(
          counter: 13,
          average: 3.846,
          showAverage: true,
          counterFiveStars: 5,
          counterFourStars: 4,
          counterThreeStars: 2,
          counterTwoStars: 1,
          counterOneStars: 1,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 120, // Adjust height for cards
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: tertiarySizedBox),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length > 10 ? 10 : reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                color: lighterGreyColor,
                margin: const EdgeInsets.symmetric(horizontal: primarySizedBox),
                child: Container(
                  width: 220, // Adjust card width
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reviewer's name
                      Text(
                        review['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),
                      // Comment (if available)
                      if (review['comment'] != null)
                        Text(
                          review['comment']!,
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

                      const SizedBox(height: 8),
                      // Star rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  review['rating'],
                                  (starIndex) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Text(
                                '(${review['rating']})',
                                style: const TextStyle(
                                    fontSize: smallText, color: darkGreyColor),
                              ),
                            ],
                          ),

                          // Date of the review
                          Text(
                            review['date']!,
                            style: const TextStyle(
                              color: darkGreyColor,
                              fontSize: 12,
                            ),
                          ),
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
  }
}
