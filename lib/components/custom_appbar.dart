import 'package:flutter/material.dart';

// 1) appBar
// Primarily for homescreen
AppBar appBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    leadingWidth: 190,
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
      child: SizedBox(
        child: Image.asset(
          'assets/pamfurred_logo.png',
          fit: BoxFit.fill,
        ),
      ),
    ),
    actions: const [
      Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 15, 10),
        child: Icon(Icons.settings, size: 30),
      ),
    ],
  );
}

// 2) customAppBar
// This is for other screens but homescreen
AppBar customAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    toolbarHeight: 60,
    leading: Padding(
      padding: const EdgeInsets.all(10.0),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          // Custom action on back button press
          Navigator.pop(context);
        },
      ),
    ),
  );
}

// 3) customAppBar with Title
// This is for other screens but homescreen
AppBar customAppBarWithTitle(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    toolbarHeight: 70,
    title: Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(title),
    ),
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          // Custom action on back button press
          Navigator.pop(context);
        },
      ),
    ),
  );
}
