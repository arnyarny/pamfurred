import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/firebase_options.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pamfurred',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme:
            Theme.of(context).colorScheme.copyWith(primary: primaryColor),
        splashFactory: NoSplash.splashFactory, // Disable splash colors
      ),
      // Redirect to HomeScreen() if the user is already logged in
      // home: const LoginScreen(),
      home: const LoginScreen(),
    );
  }
}
