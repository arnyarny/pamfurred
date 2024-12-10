import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pamfurred/backend_logic_files/realtime_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod package
import 'package:pamfurred/components/connectivity_wrapper.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/notifications_provider.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/providers/ratings_and_reviews_provider.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRedirect extends ConsumerStatefulWidget {
  const AuthRedirect({super.key});

  @override
  AuthRedirectState createState() => AuthRedirectState();
}

class AuthRedirectState extends ConsumerState<AuthRedirect>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  late RealtimeService realtimeService;

  final List<StreamSubscription> _streamSubscriptions =
      []; // Store subscriptions

  final categories = ['pet grooming', 'pet boarding', 'veterinary service'];

  @override
  void initState() {
    super.initState();
    // Initialize fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Fade-out duration
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward(); // Start the fade-out animation

    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    realtimeService = RealtimeService();

    _checkSession();
    _listenToAppointments();
    _listenToSpAvailability();
    _listenToPetProfiles();
    _listenToNotifications();
    _listenToFeedback();
    _listenToServiceProviders(ref);
    _listenToServices;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAVailableTimes(ref);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart listener on resume
      print("App resumed, restarting real-time listener...");
      realtimeService.listenToAppointments();
    }
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    // print('Session: $session'); // Log the session to the terminal

    await Future.delayed(const Duration(seconds: 2)); // Add delay for debugging

    // If there is an active session, start listening to appointments
    final realtimeService = RealtimeService();
    realtimeService.listenToAppointments(); // Start listening to notifications
    print("LISTEN TO APPOINTMENTS LET'S GO!");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session != null) {
        ref.read(bottomNavBarIndexProvider.notifier).state =
            0; // Switch to Home page
        Navigator.push(context, slideUpRoute(const MainScreen()));
      } else {
        // User is not logged in, navigate to Login Screen
        Navigator.push(context, slideUpRoute(const LoginScreen()));
      }
    });
  }

  void _listenToAppointments() {
    final supabase = Supabase.instance.client;
    final subscription = supabase
        .from('appointment')
        .stream(primaryKey: ['appointment_id']).listen((event) {
      ref.invalidate(appointmentDetailsProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToSpAvailability() {
    final supabase = Supabase.instance.client;
    final subscription = supabase
        .from('service_provider_availability')
        .stream(primaryKey: ['availability_id']).listen((event) {
      ref.invalidate(availableTimeslotsProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToPetProfiles() {
    final supabase = Supabase.instance.client;
    final subscription = supabase
        .from('pet_profile')
        .stream(primaryKey: ['pet_profile_id']).listen((event) {
      ref.invalidate(petProfileProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToNotifications() {
    final supabase = Supabase.instance.client;
    final subscription = supabase
        .from('notification')
        .stream(primaryKey: ['notification_id']).listen((event) {
      ref.invalidate(notificationDetailsProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToAVailableTimes(WidgetRef ref) {
    final supabase = Supabase.instance.client;
    final selectedDate = ref.watch(selectedDateProvider);

    final subscription = supabase
        .from('appointment')
        .stream(primaryKey: ['appointment_id'])
        .eq('appointment_date', selectedDate)
        .eq('sp_id', ref.watch(selectedSpIndexProvider))
        .listen((event) {
          ref.invalidate(fetchAppointmentsPerDateProvider(selectedDate!));
        });

    _streamSubscriptions.add(subscription);
  }

  void _listenToFeedback() {
    final supabase = Supabase.instance.client;
    final subscription = supabase
        .from('feedback')
        .stream(primaryKey: ['feedback_id']).listen((event) {
      ref.invalidate(ratingsSummaryWithReviewsProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  // Not sure yet
  void _listenToServiceProviders(WidgetRef ref) {
    final supabase = Supabase.instance.client;

    // Listen for changes in the base view or table
    final subscription = supabase
        .from('service_provider_with_categories_and_sentiment_mv')
        .stream(primaryKey: ['sp_id']).listen((event) {
      // Invalidate all category providers when the view updates
      for (final category in categories) {
        ref.invalidate(serviceProviderFutureProvider(category));
      }
      // Invalidate the provider without category
      ref.invalidate(serviceProviderFutureProviderWithoutCategory);
    });

    // Add to subscriptions for cleanup
    _streamSubscriptions.add(subscription);
  }

  // Not sure yet
  void _listenToServices() {
    final supabase = Supabase.instance.client;
    final subscription = supabase
        .from('service')
        .stream(primaryKey: ['service_id']).listen((event) {
      ref.invalidate(searchResultsServiceProviderServices);
    });

    _streamSubscriptions.add(subscription);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose animation controller
    _controller.dispose();

    // Cancel all stream subscriptions
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: Scaffold(
        body: Center(
          child: FadeTransition(
            opacity: _animation,
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
