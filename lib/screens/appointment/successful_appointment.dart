import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/main_screen.dart';
import '../../components/globals.dart';

class SuccessfulAppointment extends ConsumerStatefulWidget {
  const SuccessfulAppointment({super.key});

  @override
  ConsumerState<SuccessfulAppointment> createState() =>
      SuccessfulAppointmentState();
}

class SuccessfulAppointmentState extends ConsumerState<SuccessfulAppointment> {
  Map<String, dynamic>? mapAppointmentDetails;
  bool isLoading = true; // Loading state

  // Confetti controller for center explosion
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Initialize confetti controller for 2 seconds
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Play confetti explosively
    _confettiController.play();
  }

  @override
  void dispose() {
    // Dispose of the confetti controller
    _confettiController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final sp = ref.watch(spIndexProvider);

    // Watch cart products and total price from the providers
    final cartProducts = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);

    // Separate services and packages from the cart
    final services = cartProducts.whereType<Service>().toList();
    final packages = cartProducts.whereType<Package>().toList();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
              ),
            ),
            // Center confetti widget
            ConfettiWidget(
              numberOfParticles: 250,
              maximumSize: const Size(20, 10),
              confettiController: _confettiController,
              blastDirectionality:
                  BlastDirectionality.explosive, // Explosive effect
              shouldLoop: false,
              colors: const [
                Colors.yellow,
                Colors.red,
                primaryColor,
                secondaryColor,
                lighterSecondaryColor,
                lightRedColor
              ],
              maxBlastForce: 100, // Increase blast force for more explosion
              minBlastForce: 10, // Minimum blast force
              gravity: 0.5, // Control how quickly confetti falls
              child: Container(), // Placeholder for the widget
            ),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/pamfurred_logo.png',
                      width: 325,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(height: tertiarySizedBox),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/check.png',
                      width: 175,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(height: tertiarySizedBox),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customRegularWeightTitleText(context, 'Appointment ID:'),
                    const SizedBox(
                      width: primarySizedBox,
                    ),
                    customTitleText(context, '1234'),
                  ],
                ),
                const SizedBox(height: tertiarySizedBox),
                SizedBox(
                  width: screenPadding(context),
                  child: Column(
                    children: [
                      // Service provider name
                      getAppointmentTitle(context, 'Service provider'),
                      const SizedBox(height: primarySizedBox),
                      getAppointmentDetail(context, sp!['name']),

                      const SizedBox(height: secondarySizedBox),

                      const SizedBox(height: secondarySizedBox),

                      // Service type
                      if (services.isNotEmpty)
                        getAppointmentTitle(context, 'Services'),
                      const SizedBox(height: primarySizedBox),
                      ...services.map((service) => _buildCartItem(service)),

                      const SizedBox(height: secondarySizedBox),

                      if (packages.isNotEmpty)
                        getAppointmentTitle(context, 'Packages'),
                      const SizedBox(height: primarySizedBox),
                      ...packages.map((package) => _buildCartItem(package)),

                      const SizedBox(height: secondarySizedBox),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getAppointmentTotalTitle(context, 'Total'),
                          regularPrimaryColoredBoldTextWidget('₱$total')
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: tertiarySizedBox),
                Center(
                  child: customPaddedTextButton(
                      text: 'Return to dashboard',
                      onPressed: () {
                        // Clear the cart when this button is pressed
                        ref.read(cartNotifierProvider.notifier).clearCart();
                        Navigator.push(
                            context, crossFadeRoute(const MainScreen()));
                      }),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  getAppointmentTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customTitleText(context, title),
        const SizedBox(
          width: primarySizedBox,
        ),
      ],
    );
  }

  getAppointmentTotalTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customTitleTextWithPrimaryColor(context, title),
        const SizedBox(
          width: primarySizedBox,
        ),
      ],
    );
  }

  getAppointmentDetail(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customRegularWeightTitleText(context, title),
        const SizedBox(
          width: primarySizedBox,
        ),
      ],
    );
  }
}

Widget _buildCartItem(dynamic item) {
  return Row(
    children: [
      Expanded(
        child: Text(
          item.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      getPrice('${item.price}'),
    ],
  );
}

getPrice(String s) {
  return Text(
    '₱$s',
    style: const TextStyle(fontWeight: FontWeight.bold),
  );
}
