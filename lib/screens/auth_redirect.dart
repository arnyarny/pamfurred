import 'package:flutter/material.dart'; // For Flutter UI components like Scaffold, Navigator, MaterialPageRoute, etc.
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For using Supabase in Flutter

class AuthRedirect extends StatefulWidget {
  const AuthRedirect({super.key});

  @override
  AuthRedirectState createState() => AuthRedirectState();
}

class AuthRedirectState extends State<AuthRedirect> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    print('Session: $session'); // Log the session to the terminal

    await Future.delayed(const Duration(seconds: 2)); // Add delay for debugging

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session != null) {
        // User is logged in, navigate to Home Screen
        Navigator.push(context, slideUpRoute(MainScreen()));
      } else {
        // User is not logged in, navigate to Login Screen
        Navigator.push(context, slideUpRoute(const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:
          Center(child: CircularProgressIndicator()), // While checking session
    );
  }
}
