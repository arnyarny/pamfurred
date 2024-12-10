import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Create a navigator key for global navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Initialize the local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Function to initialize notifications
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('pamfurred');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      try {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialPage: 1),
          ),
        );
      } catch (e) {
        print("Error navigating on notification tap: $e");
      }
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://gfrbuvjfnlpfqkylbnxb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmcmJ1dmpmbmxwZnFreWxibnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgwMjM0NDgsImV4cCI6MjA0MzU5OTQ0OH0.JmDB012bA04pPoD64jqTTwZIPYowFl5jzIVql49bwx4',
    );
  } catch (e) {
    print("Supabase initialization failed: $e");
    return;
  }

  // Initialize local notifications
  await initializeNotifications();

  // Lock device orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appContextProvider.overrideWithValue(context),
      ],
      child: MaterialApp(
        navigatorKey:
            navigatorKey, // Attach navigator key for global navigation
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('he', ''), // Hebrew, no country code
          Locale.fromSubtags(languageCode: 'zh'), // Chinese
        ],
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
        home: const SplashScreen(), // Initial screen
      ),
    );
  }
}
