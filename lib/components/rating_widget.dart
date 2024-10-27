import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

Widget ratingWidget(String? rating) {
  // Check for invalid rating values and handle them
  if (rating == null || rating.isEmpty || rating == "N/A") {
    return const Row(
      children: [
        Icon(Icons.star_border, size: 19, color: secondaryColor),
        Text('N/A')
      ],
    );
  }

  // Convert the rating string to a double
  double ratingValue = double.tryParse(rating) ?? 0;

  // Calculate the number of filled stars
  int filledStars = ratingValue.floor();

  // Check for half-star condition (if rating has a decimal >= 0.5)
  bool hasHalfStar = (ratingValue - filledStars) >= 0.5;

  return Row(
    children: [
      // Generate filled star icons
      for (int i = 0; i < filledStars; i++)
        const Icon(Icons.star, size: 19, color: secondaryColor),

      // Optionally add a half star icon
      if (hasHalfStar)
        const Icon(Icons.star_half, size: 19, color: secondaryColor),

      // Generate empty star icons to make up a total of 5
      for (int i = 0; i < 5 - filledStars - (hasHalfStar ? 1 : 0); i++)
        const Icon(Icons.star_border, size: 19, color: secondaryColor),

      // Display the rating value as text beside the stars
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(rating),
      ),
    ],
  );
}
