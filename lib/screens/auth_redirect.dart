import 'package:flutter/material.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/notifications_provider.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod package

class AuthRedirect extends ConsumerStatefulWidget {
  const AuthRedirect({super.key});

  @override
  AuthRedirectState createState() => AuthRedirectState();
}

class AuthRedirectState extends ConsumerState<AuthRedirect> {
  @override
  void initState() {
    super.initState();
    _checkSession();
    _listenToAppointments(); // Listen to appointment changes after initState
    _listenToSpAvailability(); // Listen to service provider availability changes after initState
    _listenToPetProfiles();
    _listenToNotifications();
  }

  // Listen for changes in the `appointments` table
  void _listenToAppointments() {
    final supabase = Supabase.instance.client;

    // Stream listens for changes in the appointments table
    supabase
        .from('appointment')
        .stream(primaryKey: ['appointment_id']).listen((event) {
      // Invalidate the provider when the data changes
      ref.invalidate(appointmentDetailsProvider);
    });
  }

  // Listen for changes in the `service_provider_availability` table
  void _listenToSpAvailability() {
    final supabase = Supabase.instance.client;

    // Stream listens for changes in the service_provider_availability table
    supabase
        .from('service_provider_availability')
        .stream(primaryKey: ['availability_id']).listen((event) {
      // Invalidate the provider when the data changes
      ref.invalidate(availableTimeslotsProvider);
    });
  }

  void _listenToPetProfiles() {
    final supabase = Supabase.instance.client;

    // Stream listens for changes in the service_provider_availability table
    supabase
        .from('pet_profile')
        .stream(primaryKey: ['pet_profile_id']).listen((event) {
      // Invalidate the provider when the data changes
      ref.invalidate(petProfileProvider);
    });
  }

  void _listenToNotifications() {
    final supabase = Supabase.instance.client;

    // Stream listens for changes in the service_provider_availability table
    supabase
        .from('notification')
        .stream(primaryKey: ['notification_id']).listen((event) {
      // Invalidate the provider when the data changes
      ref.invalidate(notificationDetailsProvider);
    });
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    // print('Session: $session'); // Log the session to the terminal

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
