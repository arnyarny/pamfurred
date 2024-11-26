import 'package:flutter/material.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:video_player/video_player.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/screens/register/personal_details.dart';

class StartYourJourneyScreen extends StatefulWidget {
  const StartYourJourneyScreen({super.key});

  @override
  StartYourJourneyScreenState createState() => StartYourJourneyScreenState();
}

class StartYourJourneyScreenState extends State<StartYourJourneyScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the video player controller with a network video URL
    _controller = VideoPlayerController.contentUri(
      Uri.parse('https://cdn-icons-mp4.flaticon.com/512/14444/14444017.mp4'),
    )..initialize().then((_) {
        // Ensure the first frame is shown
        setState(() {
          // Play the video and set it to loop
          _controller.setLooping(true);
          _controller.play();
        });
        // Start fading in the video after initialization
        _fadeController.forward();
      });

    // Initialize the fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Define the fade animation (fade in from 0 to 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Clean up the controller when done
    _fadeController.dispose(); // Clean up the fade controller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Video Player with FadeTransition
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
                  : const Center(
                      child: SizedBox(
                      height: 200,
                    )),
              const SizedBox(height: 20),

              // Description text
              const SizedBox(
                width: 315,
                child: Text(
                  'Join Pamfurred today and discover a new world of pampering for your furry friends! Register now to unlock exclusive benefits and stay ahead of the pack.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: regularText),
                ),
              ),
              const SizedBox(height: 30),

              // Register button
              SizedBox(
                width: 315,
                child: CustomWideButton(
                  text: "Register now",
                  onPressed: () {
                    Navigator.push(
                      context,
                      rightToLeftRoute(
                        PersonalInformationScreen(controllers: {
                          'firstName': TextEditingController(),
                          'lastName': TextEditingController(),
                        }),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: quaternarySizedBox),
              // Login button
              SizedBox(width: 315, child: hasAnAccount(context))
            ],
          ),
        ),
      ),
    );
  }
}

Widget hasAnAccount(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, slideUpRoute(const LoginScreen(), reverse: true));
        },
        child: const Text(
          "I already have an account",
          style: TextStyle(
              fontSize: regularText,
              color: primaryColor,
              fontWeight: regularWeight),
        ),
      ),
    ],
  );
}

Widget formDescription(BuildContext context, String text) {
  return Text(
    text,
    textAlign: TextAlign.justify,
    style: const TextStyle(fontSize: smallText, color: Colors.black),
  );
}
