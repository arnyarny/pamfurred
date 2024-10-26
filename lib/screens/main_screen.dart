import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/screens/home_screen.dart';
import 'package:pamfurred/screens/appointments.dart';
import 'package:pamfurred/screens/notifications.dart';
import 'package:pamfurred/screens/profile.dart';
import '../components/bottom_navbar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  final double bottomNavHeight =
      60.0; // Define the height of the bottom nav bar

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(visibilityProvider);

    // Define screens without userId
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
        onPageChanged: onPageChanged,
        children: screens,
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? bottomNavHeight : 0,
        curve: Curves.easeInOut,
        child: isVisible
            ? CustomBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
      ),
    );
  }
}
