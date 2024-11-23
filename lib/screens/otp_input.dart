import 'dart:async'; // Import this to use Timer
import 'package:flutter/material.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/screens/successful_registration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false; // Track the state of resending OTP
  bool _canResendOtp =
      false; // Control the resend button state initially set to false
  int _remainingTime = 60; // Countdown timer for resend
  Timer? _timer; // Timer object

  @override
  void initState() {
    super.initState();
    // Start the countdown timer immediately when the screen is navigated to
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    final otp = _otpController.text.trim();

    try {
      // Call Supabase to verify the OTP
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.signup,
      );

      if (response.user != null) {
        // OTP verification successful
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verification successful')),
          );
        }

        // Navigate to the home screen or any other screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const SuccessfulRegistration()),
          );
        }
      } else {
        // Handle verification error
        if (mounted) {
          final error = response.error?.message ?? "Unknown error";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("OTP verification failed: $error")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> resendOTP() async {
    if (!_canResendOtp) return; // Prevent resending if not allowed

    setState(() {
      _isResending = true; // Set loading state for resending
      _canResendOtp = false; // Disable resend button
      _remainingTime = 60; // Reset timer
    });

    try {
      // Call Supabase to resend the OTP
      await Supabase.instance.client.auth.signInWithOtp(
        email: widget.email,
        // You can add a redirect URL or any other parameters here if needed
      );

      // If the call is successful, show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP has been resent to ${widget.email}")),
        );
      }

      // Start the countdown timer
      _startTimer();
    } catch (e) {
      // Handle any errors that occur during the resend request
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isResending = false; // Reset loading state for resending
      });
    }
  }

  void _startTimer() {
    // Disable the resend button initially and start the countdown
    setState(() {
      _canResendOtp = false; // Ensure the button is initially disabled
      _remainingTime = 60; // Set initial remaining time
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel(); // Stop the timer when it reaches 0
        setState(() {
          _canResendOtp = true; // Re-enable the resend button
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarWithTitle(context, "Verify email address"),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the OTP sent to ${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: regularText,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: tertiarySizedBox),
            _isLoading
                ? const CircularProgressIndicator()
                : customPaddedTextButton(
                    text: "Verify OTP", onPressed: verifyOTP),
            const SizedBox(height: secondarySizedBox),
            _isResending
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      TextButton(
                        onPressed: _canResendOtp
                            ? resendOTP
                            : null, // Disable button if necessary
                        child: Text(
                          _canResendOtp
                              ? "Resend OTP"
                              : "Resend in $_remainingTime s",
                          style: const TextStyle(fontSize: regularText),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}
