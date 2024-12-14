import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/search_results_provider.dart';

class PriceRangeInputScreen extends ConsumerStatefulWidget {
  final TextEditingController inputMinPriceController;
  final TextEditingController inputMaxPriceController;

  PriceRangeInputScreen({
    required this.inputMinPriceController,
    required this.inputMaxPriceController,
  });

  @override
  ConsumerState<PriceRangeInputScreen> createState() =>
      _PriceRangeInputScreenState();
}

class _PriceRangeInputScreenState extends ConsumerState<PriceRangeInputScreen> {
  final FocusNode _focusNode = FocusNode(); // FocusNode for TextField

  String? minPriceError;
  String? maxPriceError;
  void validateAndSubmit() {
    final num? minPrice = num.tryParse(widget.inputMinPriceController.text);
    final num? maxPrice = num.tryParse(widget.inputMaxPriceController.text);

    setState(() {
      // Clear previous errors
      minPriceError = null;
      maxPriceError = null;

      // Consolidate error for invalid price range
      if (minPrice == null && maxPrice == null) {
        minPriceError = 'Enter a valid price range.';
      } else {
        if (minPrice == null) {
          minPriceError = 'Enter a valid minimum price.';
        } else if (maxPrice == null) {
          maxPriceError = 'Enter a valid maximum price.';
        } else if (minPrice >= maxPrice) {
          minPriceError = 'Minimum price must be less than maximum price.';
        }
      }
    });

    if (minPriceError == null && maxPriceError == null) {
      // Update providers if inputs are valid
      ref.read(inputMinPriceProvider.notifier).state = minPrice!;
      ref.read(inputMaxPriceProvider.notifier).state = maxPrice!;

      // Close the screen and return to the previous one
      Navigator.pop(context, {
        'inputMinPrice': minPrice,
        'inputMaxPrice': maxPrice,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Request focus on the text field as soon as the screen is loaded
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose the FocusNode when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minPrice = ref.watch(inputMinPriceProvider);
    final maxPrice = ref.watch(inputMaxPriceProvider);

    // Update the text controllers when the state changes
    widget.inputMinPriceController.text = minPrice.toStringAsFixed(0);
    widget.inputMaxPriceController.text = maxPrice.toStringAsFixed(0);

    return DecoratedBox(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: secondarySizedBox),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(tertiaryBorderRadius),
                  ),
                  color: greyColor,
                ),
                width: 50,
                height: 5,
              ),
            ),
            Column(
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
                    // Min price field with error widget
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: TextFormField(
                            controller: widget.inputMinPriceController,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.go,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintText: 'Min price',
                              hintStyle: TextStyle(
                                  fontSize: regularText, color: greyColor),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(width: .25)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: secondarySizedBox),
                    const Text(
                      'to',
                      style: TextStyle(fontSize: regularText),
                    ),
                    const SizedBox(width: secondarySizedBox),
                    // Max price field with error widget
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: TextFormField(
                            controller: widget.inputMaxPriceController,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.go,
                            decoration: const InputDecoration(
                              hintText: 'Max price',
                              hintStyle: TextStyle(
                                  fontSize: regularText, color: greyColor),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(width: .25)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (minPriceError != null && maxPriceError != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: tertiarySizedBox),
                    child: Center(
                      child: Text(
                        minPriceError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
                if (minPriceError != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: tertiarySizedBox),
                    child: Center(
                      child: Text(
                        minPriceError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
                if (maxPriceError != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: tertiarySizedBox),
                    child: Center(
                      child: Text(
                        maxPriceError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                ],
                // Clear Price Button
                const SizedBox(height: tertiarySizedBox),
                // Set Price Button
                CustomWideButton(
                  text: 'Set price',
                  onPressed: validateAndSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
