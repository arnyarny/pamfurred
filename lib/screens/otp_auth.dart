import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/screens/successful_registration.dart';
import '../components/globals.dart';

class OTPAuth extends StatefulWidget {
  const OTPAuth({super.key, required String email});

  @override
  State<OTPAuth> createState() => _OTPAuthState();
}

class _OTPAuthState extends State<OTPAuth> {
  String otp = '';
  Timer? timer;
  int countDown = 120;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countDown > 0) {
          countDown--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void resendOTP() {
    if (canResend) {
      setState(() {
        countDown = 120;
        canResend = false;
      });
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: primaryPadding,
          child: Column(
            children: [
              const SizedBox(height: secondarySizedBox),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Verify email",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: titleFont,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: tertiarySizedBox),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/mail.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: tertiarySizedBox),
              Center(
                child: SizedBox(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: regularText),
                      children: [
                        TextSpan(
                          text: "Enter the OTP sent to ",
                          style: TextStyle(
                              color: Colors.black, fontSize: regularText),
                        ),
                        TextSpan(
                          // Insert user's username here
                          text: "davidjacobs@gmail.com",
                          style: TextStyle(
                              fontSize: regularText,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: ".",
                          style: TextStyle(
                              color: Colors.black, fontSize: regularText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: tertiarySizedBox),
              OtpTextField(
                fieldWidth: 60,
                fieldHeight: 60,
                showFieldAsBox: true,
                borderColor: greyColor,
                borderRadius: BorderRadius.circular(primaryBorderRadius),
                focusedBorderColor: secondaryColor,
                numberOfFields: 4,
                textStyle: const TextStyle(fontSize: regularText),
              ),
              const SizedBox(height: tertiarySizedBox),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ('${(countDown ~/ 60).toString().padLeft(2, '0')}:${(countDown % 60).toString().padLeft(2, '0')}'),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: regularText),
                      children: [
                        const TextSpan(
                          text: "Didn't receive OTP? ",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "Resend",
                          style: const TextStyle(
                            color: primaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              resendOTP();
                            },
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: tertiarySizedBox),
              Center(
                child: SizedBox(
                    width: 150,
                    height: primaryTextFieldHeight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            rightToLeftRoute(const SuccessfulRegistration()));
                        // _getLocationPermission(context);
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
                        "Verify",
                        style: TextStyle(
                            color: Colors.white, fontSize: regularText),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Future<void> _getLocationPermission(BuildContext context) async {
//   // Request location permission
//   var status = await Permission.location.request();

//   if (status.isGranted) {
//     // Permission is granted, proceed to get location
//     _getCurrentLocation();
//   } else if (status.isDenied) {
//     // Permission denied, show error or informative message
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: const Text('Location Permission Required'),
//         content: const Text('Please grant location access to continue.'),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//     );
//   } else if (status.isPermanentlyDenied) {
//     // Permission permanently denied, open app settings
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: const Text('Location Permission Required'),
//         content: const Text('Please grant location access in app settings.'),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Open Settings'),
//             onPressed: () {
//               openAppSettings();
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// void _getCurrentLocation() async {
//   // Get current position
//   Position position = await Geolocator.getCurrentPosition(
//     desiredAccuracy: LocationAccuracy.high,
//   );

//   // Use the position data as needed
//   if (kDebugMode) {
//     print('Current location: ${position.latitude}, ${position.longitude}');
//   }
// }
