import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final Function(int) onTap;
  final int currentIndex;

  const CustomBottomNavBar(
      {required this.onTap, required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    return Stack(
      children: [
        // Bottom Navigation Bar
        SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: isLoading ? null : onTap, // Disable onTap when loading
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home, size: 30),
              title: const Text("Home",
                  style: TextStyle(
                      fontSize: regularText, fontWeight: FontWeight.normal)),
              selectedColor: primaryColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.calendar_month, size: 30),
              title: const Text("Appointments",
                  style: TextStyle(
                      fontSize: regularText, fontWeight: FontWeight.normal)),
              selectedColor: primaryColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(CupertinoIcons.bell_fill, size: 30),
              title: const Text("Notifications",
                  style: TextStyle(
                      fontSize: regularText, fontWeight: FontWeight.normal)),
              selectedColor: primaryColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person, size: 30),
              title: const Text("Profile",
                  style: TextStyle(
                      fontSize: regularText, fontWeight: FontWeight.normal)),
              selectedColor: primaryColor,
            ),
          ],
        ),
        // Semi-transparent overlay when loading
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54, // Semi-transparent black
            ),
          ),
      ],
    );
  }
}
