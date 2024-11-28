import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/globals.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscureText = true;
  bool isLoading = false;

  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    checkIfUserIsLoggedIn(); // Check if user is already logged in
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/pamfurred_logo.png'), context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

// Method to check if user is already logged in
  Future<void> checkIfUserIsLoggedIn() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Access the Riverpod provider to switch to the home screen (index 1)
      ref.read(bottomNavBarIndexProvider.notifier).state = 0;

      // Animate to the home screen (index 0) using the PageController
      final pageController = ref.read(pageControllerProvider);
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // User is already logged in
      Navigator.push(context, slideUpRoute(const MainScreen()));
    } else {
      // If there's no session, stay on the login screen and display a message or widget
      setState(() {
        // Display a message or trigger a state update to notify the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No session found, please log in')),
        );
      });
    }
  }

  Future<void> authenticateUser(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(), // Trim whitespace from email input
        password: password.trim(),
      );

      if (response.user != null) {
        // Check if email is verified
        final isEmailVerified = response.user!.emailConfirmedAt != null;

        if (isEmailVerified) {
          // Access the Riverpod provider to switch to the home screen (index 1)
          ref.read(bottomNavBarIndexProvider.notifier).state = 0;

          // Animate to the home screen (index 0) using the PageController
          final pageController = ref.read(pageControllerProvider);
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              crossFadeRoute(const MainScreen()),
            );
          }
        } else {
          // Email not verified - show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Account is not verified by admin.')),
            );
          }
        }
      } else {
        // Handle login failure
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = deviceWidthDivideOnePointFive(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/pamfurred_logo.png',
                              width: deviceWidth + 20,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 24),
                            // Email address field
                            SizedBox(
                              width: deviceWidth,
                              height: 50,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email address';
                                  } else if (!EmailValidator.validate(value)) {
                                    return 'Invalid Email Address';
                                  }
                                  return null;
                                },
                                cursorColor:
                                    const Color.fromRGBO(74, 74, 74, 1),
                                focusNode: emailFocusNode,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                readOnly:
                                    isLoading, // Disable input when loading
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10.0),
                                  prefixIcon:
                                      const Icon(Icons.person, size: 19),
                                  labelText: emailFocusNode.hasFocus
                                      ? ''
                                      : 'Email address',
                                  labelStyle:
                                      const TextStyle(fontSize: regularText),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  filled: true,
                                  fillColor:
                                      const Color.fromRGBO(241, 241, 241, 1.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        secondaryBorderRadius),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(fontSize: regularText),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Password field
                            SizedBox(
                              width: deviceWidth,
                              height: 50,
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor:
                                    const Color.fromRGBO(74, 74, 74, 1),
                                focusNode: passwordFocusNode,
                                controller: passwordController,
                                obscureText: obscureText,
                                validator: (value) {
                                  return (value == null || value.isEmpty)
                                      ? 'Please enter password'
                                      : null;
                                },
                                readOnly:
                                    isLoading, // Disable input when loading
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10.0),
                                  prefixIcon: Transform.rotate(
                                    angle: 40,
                                    child: const Icon(Icons.key, size: 19),
                                  ),
                                  labelText: passwordFocusNode.hasFocus
                                      ? ''
                                      : 'Password',
                                  labelStyle:
                                      const TextStyle(fontSize: regularText),
                                  suffix: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: (() {
                                          setState(() {
                                            obscureText = !obscureText;
                                          });
                                        }),
                                        child: Icon(
                                          obscureText
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 19,
                                        ),
                                      )
                                    ],
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  filled: true,
                                  fillColor:
                                      const Color.fromRGBO(241, 241, 241, 1.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        secondaryBorderRadius),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(fontSize: regularText),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: deviceWidth,
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    fontSize: regularText,
                                    color: secondaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: secondaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: deviceWidth,
                              height: 50,
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (formKey.currentState!.validate()) {
                                          await authenticateUser(
                                            emailController.text,
                                            passwordController.text,
                                          );
                                        }
                                      },
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          secondaryBorderRadius),
                                    ),
                                  ),
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          primaryColor),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: regularText,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: deviceWidth,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(fontSize: regularText),
                                  children: [
                                    const TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: "Register",
                                      style:
                                          const TextStyle(color: primaryColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            slideUpRoute(
                                              const StartYourJourneyScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
