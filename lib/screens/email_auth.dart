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
  int _counter = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Start the timer for countdown to resend the confirmation email
  void _startTimer() {
    _counter = 30;
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

  // Check if the user's email is confirmed
  Future<void> _checkConfirmation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;

      if (user == null) {
        // User is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in.')),
        );
        return;
      }

      // Check if the user's email is confirmed
      if (user.emailConfirmedAt != null) {
        // Email is confirmed, navigate to the success screen
        Navigator.pushReplacement(
          context,
          rightToLeftRoute(const SuccessfulRegistration()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please confirm your email to proceed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking confirmation: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Resend the confirmation email
  Future<void> _resendConfirmation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;

      if (user != null) {
        // Resend confirmation email
        await Supabase.instance.client.auth.api
            .sendConfirmationEmail(user.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Confirmation email resent!')),
        );
        _startTimer(); // Restart the timer
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending confirmation email: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              'Please check your email for a confirmation link.',
              style:
                  TextStyle(fontSize: regularText, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: secondarySizedBox),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkConfirmation,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Check Confirmation',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: secondarySizedBox),
            Center(
              child: Text(
                'Resend confirmation email in $_counter seconds',
                style: const TextStyle(color: greyColor),
              ),
            ),
            const SizedBox(height: secondarySizedBox),
            Center(
              child: TextButton(
                onPressed: _counter == 0 ? _resendConfirmation : null,
                child: const Text(
                  'Resend Confirmation Email',
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

extension on GoTrueClient {
  get api =>
      null; // This might be unnecessary if you're already using Supabase's client
}
