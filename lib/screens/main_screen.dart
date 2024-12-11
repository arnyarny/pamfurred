import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/backend_logic_files/realtime_service.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/screens/home_screen.dart';
import 'package:pamfurred/screens/appointment_details/appointments.dart';
import 'package:pamfurred/screens/notifications.dart';
import 'package:pamfurred/screens/profile.dart';
import '../components/bottom_navbar.dart';

class MainScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const MainScreen({super.key, this.initialPage = 0});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  late RealtimeService realtimeService;

  @override
  void initState() {
    super.initState();
    // If there is an active session, start listening to appointments
    final realtimeService = RealtimeService();
    realtimeService.listenToAppointments(); // Start listening to notifications
    print("LISTEN TO APPOINTMENTS LET'S GO!");

    _pageController = PageController(initialPage: widget.initialPage);
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance
        .removeObserver(this); // Remove observer when disposing
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart listener on resume
      print("App resumed, restarting real-time listener...");
      realtimeService.listenToAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(visibilityProvider);
    final currentIndex = ref.watch(bottomNavBarIndexProvider);

    // Ensure animations don't conflict
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != currentIndex) {
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    final List<Widget> screens = [
      const HomeScreen(),
      const AppointmentsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
        },
        children: screens,
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? 60.0 : 0,
        curve: Curves.easeInOut,
        child: isVisible
            ? CustomBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(bottomNavBarIndexProvider.notifier).state = index;
                },
              )
            : null,
      ),
    );
  }
}
