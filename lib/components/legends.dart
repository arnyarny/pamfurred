import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

Widget getLegendWidget(Color color, String text) {
  return Row(
    children: [
      Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color, // Accepts any Color now
        ),
      ),
      const SizedBox(width: secondarySizedBox),
      Text(
        text,
        style: const TextStyle(fontSize: smallText),
      ),
    ],
  );
}

// Available appointment dates
void showColorLegend(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // White background for a clean look
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // Rounded corners for elegance
        ),
        elevation: 8, // Adding some elevation to create a floating effect
        title: const Text(
          'Color Legend',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Dark title for contrast
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getLegendWidget(Colors.green, 'Available'),
              const SizedBox(height: 12), // Increased space between items
              getLegendWidget(Colors.grey, 'Not available'),
              const SizedBox(height: 12),
              getLegendWidget(Colors.red, 'Fully booked'),
              const SizedBox(height: 12),
              getLegendWidget(primaryColor, 'Date today'),
              const SizedBox(height: 12),
              getLegendWidget(secondaryColor, 'Date selected'),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Padding for spacing
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Correct property to set background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded button
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Button padding
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showTimeslotsColorLegend(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // White background for a clean look
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16), // Rounded corners for elegance
        ),
        elevation: 8, // Adding some elevation to create a floating effect
        title: const Text(
          'Color Legend',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Dark title for contrast
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getLegendWidget(Colors.grey, 'Past the current time of day'),
              const SizedBox(height: 12),
              getLegendWidget(Color.fromARGB(255, 255, 176, 170), 'Booked'),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Padding for spacing
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Correct property to set background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded button
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Button padding
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
