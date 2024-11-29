import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/screens/register/successful_registration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isResending = false;
  bool _canResendOtp = false;
  int _remainingTime = 60;
  Timer? _timer;
  List<TextEditingController?> _otpControllers = [];

  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _controller = VideoPlayerController.contentUri(
      Uri.parse('https://cdn-icons-mp4.flaticon.com/512/11237/11237480.mp4'),
    )..initialize().then((_) {
        setState(() {
          _controller.setLooping(true);
          _controller.play();
        });
        _fadeController.forward();
      });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();

    _controller.dispose();
    _fadeController.dispose();
  }

  Future<void> verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    final otp =
        _otpControllers.map((controller) => controller?.text.trim()).join();

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.signup,
      );

      if (response.user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const SuccessfulRegistration()),
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
    if (!_canResendOtp) return;

    setState(() {
      _isResending = true;
      _canResendOtp = false;
      _remainingTime = 60;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: widget.email,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP has been resent to ${widget.email}")),
        );
      }

      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void _startTimer() {
    setState(() {
      _canResendOtp = false;
      _remainingTime = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _canResendOtp = true;
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
            Column(
              children: [
                _controller.value.isInitialized
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: 200,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    : const Center(child: SizedBox(height: 200)),
              ],
            ),
            const SizedBox(height: quaternarySizedBox),
            Text(
              "Enter the OTP sent to ${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: regularText,
              ),
            ),
            const SizedBox(height: 20),
            OtpTextField(
              numberOfFields: 6, // Number of OTP fields
              fieldWidth: 45.0,
              fieldHeight: 50.0,
              textStyle: const TextStyle(fontSize: 20),
              onSubmit: (otp) {
                // Handling OTP on submit
                print("Submitted OTP: $otp");
              },
              onCodeChanged: (otp) {
                // Optional: Handle OTP change
              },
              handleControllers: (controllers) {
                _otpControllers = controllers;
              },
              showCursor: true,
              borderColor: lightGreyColor,
              enabledBorderColor: mediumGreyColor,
              focusedBorderColor: primaryColor,
              cursorColor: primaryColor,
              obscureText: false,
              showFieldAsBox: true,
              filled: true,
              fillColor: const Color(0xFFFFFFFF),
              contentPadding: const EdgeInsets.all(4),
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
                        onPressed: _canResendOtp ? resendOTP : null,
                        child: Text(
                          _canResendOtp
                              ? "Resend OTP"
                              : "Resend in ${_remainingTime}s",
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
