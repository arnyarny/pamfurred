import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/screens/home_screen.dart';
import 'package:pamfurred/screens/appointments.dart';
import 'package:pamfurred/screens/notifications.dart';
import 'package:pamfurred/screens/profile.dart';
import '../components/bottom_navbar.dart';

// Global key to access MainScreenState from anywhere
final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

class MainScreen extends ConsumerStatefulWidget {
  MainScreen({Key? key}) : super(key: mainScreenKey); // Assign global key

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  // PageController to manage PageView
  final PageController _pageController = PageController();
  final double bottomNavHeight =
      60.0; // Define the height of the bottom nav bar

  // Current index is managed by Riverpod provider
  int get currentIndex => ref.watch(bottomNavBarIndexProvider);

  // Method to switch pages and update both the PageView and bottom nav index
  void switchToPage(int index) {
    ref.read(bottomNavBarIndexProvider.notifier).state = index; // Update index
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(visibilityProvider); // Bottom nav visibility

    // List of screens managed by the PageView
    final List<Widget> screens = [
      const HomeScreen(),
      const AppointmentsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          ref.read(bottomNavBarIndexProvider.notifier).state = index;
        },
        children: screens,
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? bottomNavHeight : 0,
        curve: Curves.easeInOut,
        child: isVisible
            ? CustomBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) => switchToPage(index),
              )
            : null,
      ),
    );
  }
}
