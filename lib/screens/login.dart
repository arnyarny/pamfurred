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
  bool showErrors = false; // Flag to trigger validation messages

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
      ref.read(bottomNavBarIndexProvider.notifier).state =
          0; // Switch to Home page
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
          // Navigate to MainScreen if authentication is successful
          ref.read(bottomNavBarIndexProvider.notifier).state =
              0; // Switch to the Home screen (index 0)

          if (mounted) {
            Navigator.pushReplacement(
              context,
              crossFadeRoute(const MainScreen()), // Navigate to MainScreen
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    cursorColor:
                                        const Color.fromRGBO(74, 74, 74, 1),
                                    focusNode: emailFocusNode,
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    readOnly: isLoading,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      prefixIcon:
                                          const Icon(Icons.person, size: 19),
                                      labelText: emailFocusNode.hasFocus
                                          ? ''
                                          : 'Email address',
                                      labelStyle: const TextStyle(
                                          fontSize: regularText),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      filled: true,
                                      fillColor: const Color.fromRGBO(
                                          241, 241, 241, 1.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            secondaryBorderRadius),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    style:
                                        const TextStyle(fontSize: regularText),
                                  ),
                                  if (showErrors &&
                                      (emailController.text.isEmpty ||
                                          !EmailValidator.validate(
                                              emailController.text)))
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        emailController.text.isEmpty
                                            ? 'Please enter email address'
                                            : 'Invalid Email Address',
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Password field
                            SizedBox(
                              width: deviceWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    cursorColor:
                                        const Color.fromRGBO(74, 74, 74, 1),
                                    focusNode: passwordFocusNode,
                                    controller: passwordController,
                                    obscureText: obscureText,
                                    readOnly: isLoading,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.all(10.0),
                                      prefixIcon:
                                          const Icon(Icons.key, size: 19),
                                      labelText: passwordFocusNode.hasFocus
                                          ? ''
                                          : 'Password',
                                      labelStyle: const TextStyle(
                                          fontSize: regularText),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      filled: true,
                                      fillColor: const Color.fromRGBO(
                                          241, 241, 241, 1.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            secondaryBorderRadius),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    style:
                                        const TextStyle(fontSize: regularText),
                                  ),
                                  if (showErrors &&
                                      passwordController.text.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Please enter password',
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 12),
                                      ),
                                    ),
                                ],
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
                                        setState(() {
                                          showErrors =
                                              true; // Show errors when login is pressed
                                        });

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
                                            color: Colors.white),
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
