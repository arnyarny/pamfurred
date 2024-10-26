import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/screens/successful_registration.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import

import '../components/globals.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key});

  @override
  State<EmailAuth> createState() => EmailAuthState();
}

class EmailAuthState extends State<EmailAuth> {
  bool _isLoading = false;
  Timer? _timer;
  int _counter = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _checkEmailVerificationRepeatedly(); // Start checking email verification
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Start the timer for countdown to resend the verification email
  void _startTimer() {
    _counter = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // Resend the email verification link
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;

      if (user != null) {
        await Supabase.instance.client.auth.signInWithOtp(email: user.email!);
        setState(() {
          _counter = 60; // Restart the timer
          _startTimer();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email resent!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending verification email: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Check if the user's email has been authenticated
  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the current user has verified their email
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;

      if (user != null && user.emailConfirmedAt != null) {
        // If the email is verified, redirect to the SuccessfulRegistration screen
        Navigator.push(
            context, rightToLeftRoute(const SuccessfulRegistration()));
      } else {
        // If email not verified, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your email to proceed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying user: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Continuously check for email verification until success or timeout
  void _checkEmailVerificationRepeatedly() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;

      if (user == null || user.emailConfirmedAt == null) {
        // Email not verified, continue checking
        await _checkEmailVerification();
      } else {
        // Email verified, stop checking
        timer.cancel();
      }

      // If the counter reaches zero, stop checking
      if (_counter == 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: primaryPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please verify your email by clicking the link sent to your inbox.',
              style:
                  TextStyle(fontSize: regularText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: secondarySizedBox),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _checkEmailVerification, // Check email verification on press
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Check Verification',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: secondarySizedBox),
            Center(
              child: Text(
                'Resend verification email in $_counter seconds',
                style: const TextStyle(color: greyColor),
              ),
            ),
            const SizedBox(height: secondarySizedBox),
            Center(
              child: TextButton(
                onPressed: _counter == 0 ? _resendVerificationEmail : null,
                child: const Text(
                  'Resend Verification Email',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
