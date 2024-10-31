import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/screens/auth_redirect.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Lock the app in portrait mode and initialize Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Load environment variables from .env file
  // await dotenv.load(fileName: ".env");

  try {
    await Supabase.initialize(
      url: 'https://gfrbuvjfnlpfqkylbnxb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmcmJ1dmpmbmxwZnFreWxibnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgwMjM0NDgsImV4cCI6MjA0MzU5OTQ0OH0.JmDB012bA04pPoD64jqTTwZIPYowFl5jzIVql49bwx4',
      // url: dotenv.env['SUPABASE_URL'] ?? '',
      // anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    print("Supabase initialization failed: $e");
    return; // You might want to handle the failure gracefully
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
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
        home: const AuthRedirect(),
      ),
    );
  }
}
