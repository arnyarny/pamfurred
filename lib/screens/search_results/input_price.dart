import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/search_results_provider.dart';

class PriceRangeInputScreen extends ConsumerWidget {
  final TextEditingController inputMinPriceController;
  final TextEditingController inputMaxPriceController;

  PriceRangeInputScreen({
    required this.inputMinPriceController,
    required this.inputMaxPriceController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minPrice = ref.watch(inputMinPriceProvider);
    final maxPrice = ref.watch(inputMaxPriceProvider);

    // Update the text controllers when the state changes
    inputMinPriceController.text = minPrice.toStringAsFixed(0);
    inputMaxPriceController.text = maxPrice.toStringAsFixed(0);

    return Scaffold(
      appBar: customAppBarWithTitle(context, 'Set price range'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price (₱)',
              style: TextStyle(fontSize: titleFont, fontWeight: boldWeight),
            ),
            const SizedBox(height: secondarySizedBox),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Min price field
                SizedBox(
                  height: 50,
                  width: 100,
                  child: TextFormField(
                    controller: inputMinPriceController,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Min price',
                      hintStyle:
                          TextStyle(fontSize: regularText, color: greyColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: .25)),
                    ),
                  ),
                ),
                const SizedBox(width: secondarySizedBox),
                const Text(
                  'to',
                  style: TextStyle(fontSize: regularText),
                ),
                const SizedBox(width: secondarySizedBox),
                // Max price field
                SizedBox(
                  height: 50,
                  width: 100,
                  child: TextFormField(
                    controller: inputMaxPriceController,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Max price',
                      hintStyle:
                          TextStyle(fontSize: regularText, color: greyColor),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: .25)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: tertiarySizedBox),
            // Set Price Button
            CustomWideButton(
              text: 'Set price',
              onPressed: () {
                final num minPrice =
                    num.tryParse(inputMinPriceController.text) ??
                        ref.watch(inputMinPriceProvider);
                final num maxPrice =
                    num.tryParse(inputMaxPriceController.text) ??
                        ref.watch(inputMaxPriceProvider);

                // Validate and update prices
                if (minPrice < maxPrice) {
                  ref.read(inputMinPriceProvider.notifier).state = minPrice;
                  ref.read(inputMaxPriceProvider.notifier).state = maxPrice;
                } else {
                  // Ensure that min price is always less than max price
                  ref.read(inputMinPriceProvider.notifier).state = maxPrice;
                  ref.read(inputMaxPriceProvider.notifier).state = maxPrice;
                }

                // Close the screen and return to the previous one
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
