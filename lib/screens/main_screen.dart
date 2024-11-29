import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/screens/home_screen.dart';
import 'package:pamfurred/screens/appointment_details/appointments.dart';
import 'package:pamfurred/screens/notifications.dart';
import 'package:pamfurred/screens/profile.dart';
import '../components/bottom_navbar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(visibilityProvider);
    final currentIndex = ref.watch(bottomNavBarIndexProvider);

    // Sync the PageController with the current index whenever it changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          currentIndex, // Animate to the correct page
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut, // Add a smooth animation curve
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
