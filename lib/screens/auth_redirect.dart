import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod package
import 'package:pamfurred/backend_logic_files/realtime_service.dart';
import 'package:pamfurred/components/connectivity_wrapper.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/available_timeslots_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/notifications_provider.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/search_results/methods/check_selected_category.dart';
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

  final supabase = Supabase.instance.client;

  final List<StreamSubscription> _streamSubscriptions =
      []; // Store subscriptions

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
    _listenToNotifications();
    _listenToServiceProviders();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToAVailableTimes(ref);
      _listenToPackages();
      _listenToServices();
      _listenToServiceProviderServiceTable();
      _listenToServiceProviderPackageTable();
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
    final subscription = supabase
        .from('appointment')
        .stream(primaryKey: ['appointment_id']).listen((event) {
      ref.invalidate(appointmentDetailsProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToSpAvailability() {
    final subscription = supabase
        .from('service_provider_availability')
        .stream(primaryKey: ['availability_id']).listen((event) {
      ref.invalidate(availableTimeslotsProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToNotifications() {
    final subscription = supabase
        .from('notification')
        .stream(primaryKey: ['notification_id']).listen((event) {
      ref.invalidate(notificationDetailsProvider);
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToAVailableTimes(WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final subscription = supabase
        .from('appointment')
        .stream(primaryKey: ['appointment_id'])
        .eq('appointment_date', selectedDate)
        .listen((event) {
          ref.invalidate(fetchAppointmentsPerDateProvider(selectedDate!));
        });

    _streamSubscriptions.add(subscription);
  }

  void _listenToServiceProviders() {
    // Listen to realtime changes in db
    final subscription = supabase.from('service_provider').stream(
        primaryKey: ['sp_id']).listen((List<Map<String, dynamic>> data) {
      ref.invalidate(serviceProviderFutureProvider('pet grooming'));
      final refreshPetGrooming =
          ref.refresh(serviceProviderFutureProvider('pet grooming'));
      print('Refresh provider: $refreshPetGrooming');

      ref.invalidate(serviceProviderFutureProvider('pet boarding'));
      final refreshPetBoarding =
          ref.refresh(serviceProviderFutureProvider('pet boarding'));
      print('Refresh provider: $refreshPetBoarding');

      ref.invalidate(serviceProviderFutureProvider('veterinary service'));
      final refreshVetServices =
          ref.refresh(serviceProviderFutureProvider('veterinary service'));
      print('Refresh provider: $refreshVetServices');
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToPackages() {
    // Define filter criteria
    final filterCriteria = PackageFilterCriteria(
      spId: null,
      petType: null,
      packageType: null,
      packageCategory: null,
      size: null,
    );

    // Listen to realtime changes in db
    final subscription = supabase.from('package').stream(
        primaryKey: ['package_id']).listen((List<Map<String, dynamic>> data) {
      ref.invalidate(allPackagesProvider(filterCriteria));
      final refreshPackages = ref.refresh(allPackagesProvider(filterCriteria));
      print('Refresh provider: $refreshPackages');
      ref.invalidate(serviceProviderFutureProvider('pet grooming'));
      final refreshPetGrooming =
          ref.refresh(serviceProviderFutureProvider('pet grooming'));
      print('Refresh provider: $refreshPetGrooming');

      ref.invalidate(serviceProviderFutureProvider('pet boarding'));
      final refreshPetBoarding =
          ref.refresh(serviceProviderFutureProvider('pet boarding'));
      print('Refresh provider: $refreshPetBoarding');

      ref.invalidate(serviceProviderFutureProvider('veterinary service'));
      final refreshVetServices =
          ref.refresh(serviceProviderFutureProvider('veterinary service'));
      print('Refresh provider: $refreshVetServices');

      final selectedIndex = ref.watch(selectedCategoryIndexProvider);

      ref.invalidate(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshCombined = ref.refresh(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshCombined');

      ref.invalidate(searchResultsServiceProviderPackages(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshSearchResultsPackages = ref.refresh(
          searchResultsServiceProviderPackages(
              checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshSearchResultsPackages');
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToServices() {
    // Define filter criteria
    final filterCriteria = ServiceFilterCriteria(
      spId: null,
      petType: null,
      serviceType: null,
      serviceCategory: null,
      size: null,
    );

    // Listen to realtime changes in db
    final subscription = supabase.from('service').stream(
        primaryKey: ['service_id']).listen((List<Map<String, dynamic>> data) {
      ref.invalidate(allServicesProvider(filterCriteria));
      final refreshservices = ref.refresh(allServicesProvider(filterCriteria));
      print('Refresh provider: $refreshservices');
      ref.invalidate(serviceProviderFutureProvider('pet grooming'));
      final refreshPetGrooming =
          ref.refresh(serviceProviderFutureProvider('pet grooming'));
      print('Refresh provider: $refreshPetGrooming');

      ref.invalidate(serviceProviderFutureProvider('pet boarding'));
      final refreshPetBoarding =
          ref.refresh(serviceProviderFutureProvider('pet boarding'));
      print('Refresh provider: $refreshPetBoarding');

      ref.invalidate(serviceProviderFutureProvider('veterinary service'));
      final refreshVetServices =
          ref.refresh(serviceProviderFutureProvider('veterinary service'));
      print('Refresh provider: $refreshVetServices');

      final selectedIndex = ref.watch(selectedCategoryIndexProvider);

      ref.invalidate(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshCombined = ref.refresh(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshCombined');

      ref.invalidate(searchResultsServiceProviderServices(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshServices = ref.refresh(searchResultsServiceProviderServices(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshServices');
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToServiceProviderServiceTable() {
    // Define filter criteria
    final filterCriteria = ServiceFilterCriteria(
      spId: null,
      petType: null,
      serviceType: null,
      serviceCategory: null,
      size: null,
    );

    // Listen to realtime changes in db
    final subscription = supabase
        .from('serviceprovider_service')
        .stream(primaryKey: ['serviceprovider_service_id']).listen(
            (List<Map<String, dynamic>> data) {
      ref.invalidate(allServicesProvider(filterCriteria));
      final refreshservices = ref.refresh(allServicesProvider(filterCriteria));
      print('Refresh provider: $refreshservices');
      ref.invalidate(serviceProviderFutureProvider('pet grooming'));
      final refreshPetGrooming =
          ref.refresh(serviceProviderFutureProvider('pet grooming'));
      print('Refresh provider: $refreshPetGrooming');

      ref.invalidate(serviceProviderFutureProvider('pet boarding'));
      final refreshPetBoarding =
          ref.refresh(serviceProviderFutureProvider('pet boarding'));
      print('Refresh provider: $refreshPetBoarding');

      ref.invalidate(serviceProviderFutureProvider('veterinary service'));
      final refreshVetServices =
          ref.refresh(serviceProviderFutureProvider('veterinary service'));
      print('Refresh provider: $refreshVetServices');

      final selectedIndex = ref.watch(selectedCategoryIndexProvider);

      ref.invalidate(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshCombined = ref.refresh(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshCombined');

      ref.invalidate(searchResultsServiceProviderServices(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshServices = ref.refresh(searchResultsServiceProviderServices(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshServices');
    });

    _streamSubscriptions.add(subscription);
  }

  void _listenToServiceProviderPackageTable() {
    // Define filter criteria
    final filterCriteria = PackageFilterCriteria(
      spId: null,
      petType: null,
      packageType: null,
      packageCategory: null,
      size: null,
    );

    // Listen to realtime changes in db
    final subscription = supabase
        .from('serviceprovider_package')
        .stream(primaryKey: ['serviceprovider_package_id']).listen(
            (List<Map<String, dynamic>> data) {
      ref.invalidate(allPackagesProvider(filterCriteria));
      final refreshservices = ref.refresh(allPackagesProvider(filterCriteria));
      print('Refresh provider: $refreshservices');
      ref.invalidate(serviceProviderFutureProvider('pet grooming'));
      final refreshPetGrooming =
          ref.refresh(serviceProviderFutureProvider('pet grooming'));
      print('Refresh provider: $refreshPetGrooming');

      ref.invalidate(serviceProviderFutureProvider('pet boarding'));
      final refreshPetBoarding =
          ref.refresh(serviceProviderFutureProvider('pet boarding'));
      print('Refresh provider: $refreshPetBoarding');

      ref.invalidate(serviceProviderFutureProvider('veterinary service'));
      final refreshVetServices =
          ref.refresh(serviceProviderFutureProvider('veterinary service'));
      print('Refresh provider: $refreshVetServices');

      final selectedIndex = ref.watch(selectedCategoryIndexProvider);

      ref.invalidate(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshCombined = ref.refresh(combinedSearchResultsProvider(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshCombined');

      ref.invalidate(searchResultsServiceProviderPackages(
          checkSelectedServiceCategory(selectedIndex)));
      final refreshPackages = ref.refresh(searchResultsServiceProviderPackages(
          checkSelectedServiceCategory(selectedIndex)));
      print('Refresh provider: $refreshPackages');
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
