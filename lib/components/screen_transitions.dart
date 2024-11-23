import 'package:flutter/material.dart';

// 1) Slide in:
Route rightToLeftRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

// 2) Crossfade:
Route crossFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = 0.0;
      var end = 1.0;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route slideUpRoute(Widget page, {bool reverse = false}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the direction based on the 'reverse' flag
      final begin = reverse
          ? const Offset(0.0, -1.0)
          : const Offset(
              0.0, 1.0); // If reverse, slide up, otherwise slide down
      const end = Offset.zero; // Always ends at the final position (no offset)
      const curve = Curves.ease; // Smooth curve for the transition

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      // Return the SlideTransition with the defined offset animation
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
