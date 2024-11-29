import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/confetti.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/screens/main_screen.dart';

import '../../components/globals.dart';

class SuccessfulRegistration extends ConsumerStatefulWidget {
  const SuccessfulRegistration({super.key});

  @override
  ConsumerState<SuccessfulRegistration> createState() =>
      _SuccessfulRegistrationState();
}

class _SuccessfulRegistrationState
    extends ConsumerState<SuccessfulRegistration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const ConfettiDisplay(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Positioned(
                  child: Image.asset(
                    'assets/pamfurred_logo.png',
                    width: 325,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: tertiarySizedBox),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Positioned(
                  child: Image.asset(
                    'assets/success.png',
                    width: 275,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: tertiarySizedBox),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Positioned(
                    child: Text(
                  'Your account has been successfully created!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: regularText,
                  ),
                )),
              ],
            ),
            const SizedBox(height: tertiarySizedBox),
            Center(
              child: SizedBox(
                  width: 150,
                  height: primaryTextFieldHeight,
                  child: TextButton(
                    onPressed: () {
                      ref.read(bottomNavBarIndexProvider.notifier).state =
                          0; // Switch to Home page
                      Navigator.push(
                          context, crossFadeRoute(const MainScreen()));
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        primaryColor,
                      ),
                    ),
                    child: const Text(
                      "Start",
                      style:
                          TextStyle(color: Colors.white, fontSize: regularText),
                    ),
                  )),
            ),
          ])
        ],
      ),
    );
  }
}
