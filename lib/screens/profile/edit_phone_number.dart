import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/user_details.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPhoneNumber extends ConsumerStatefulWidget {
  const EditPhoneNumber({super.key});

  @override
  EditPhoneNumberState createState() => EditPhoneNumberState();
}

class EditPhoneNumberState extends ConsumerState<EditPhoneNumber> {
  bool _showError = false;
  bool isLoading = false;
  Map<String, String> errorMessages = {}; // To store specific error messages

  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();

    // Access the phone number value from the provider
    String initialPhoneNumber = ref.read(userPhoneNumberProvider);

    // Initialize the controller with the value from the provider
    controllers = {
      'phoneNumber': TextEditingController(text: initialPhoneNumber)
    };
  }

  bool _validatePhoneNumber() {
    final phoneNumber = controllers['phoneNumber']?.text.trim() ?? '';
    final currentPhoneNumber = ref.read(
        userPhoneNumberProvider); // Get the current phone number from the provider

    // Check if the phone number is empty
    if (phoneNumber.isEmpty) {
      errorMessages['phoneNumber'] = "Phone number cannot be empty.";
      return false;
    }
    errorMessages.remove('phoneNumber');

    // Check if the new phone number is the same as the current one
    if (phoneNumber == currentPhoneNumber) {
      errorMessages['phoneNumber'] =
          "Phone number cannot be the same as the current value.";
      return false;
    }
    errorMessages.remove('phoneNumber');

    // Remove all non-numeric characters (this includes spaces, symbols, and country code)
    final phoneDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure the phone number includes at least 12 digits excluding the country code
    if (phoneDigits.length >= 12) {
      // Extract the digits excluding the country code
      String phoneWithoutCountryCode =
          phoneDigits.substring(phoneDigits.length - 12);

      // Validate that the length of the phone number excluding the country code is exactly 12 digits
      if (phoneWithoutCountryCode.length != 12) {
        errorMessages['phoneNumber'] =
            "Phone number must have exactly 10 digits (excluding country code).";
        return false;
      }
    } else {
      errorMessages['phoneNumber'] =
          "Phone number must have at least 10 digits (excluding country code).";
      return false;
    }

    // If all checks pass, remove the error message
    errorMessages.remove('phoneNumber');
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    controllers['phoneNumber']
        ?.dispose(); // Don't forget to dispose the controller!
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: customAppBarWithTitle(context, 'Change phone number'),
          backgroundColor: Colors.white,
          body: Padding(
            padding: primaryPadding,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader("Phone number"),
                  const SizedBox(height: secondarySizedBox),
                  formDescription(context,
                      "Please provide your new phone number to update your contact details."),
                  const SizedBox(height: tertiarySizedBox),
                  RichText(
                    text: const TextSpan(
                      text: "Phone number ",
                      style:
                          TextStyle(color: Colors.black, fontSize: regularText),
                      children: [
                        TextSpan(
                            text: "*", style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: primarySizedBox),
                  SizedBox(
                    height: 65,
                    child: IntlPhoneField(
                      cursorColor: Colors.black,
                      initialCountryCode: 'PH',
                      invalidNumberMessage: null,
                      autovalidateMode: AutovalidateMode.disabled,
                      disableAutoFillHints: false,
                      initialValue: controllers['phoneNumber']?.text,
                      onChanged: (phone) {
                        controllers['phoneNumber']?.text = phone.completeNumber;
                        setState(() {
                          // Trigger state update when phone number changes
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                        ),
                      ),
                    ),
                  ),
                  if (_showError) ...[
                    const SizedBox(height: 8.0),
                    // Check if the errorMessages map contains an error for 'phoneNumber'
                    if (errorMessages.containsKey('phoneNumber'))
                      Text(
                        errorMessages[
                            'phoneNumber']!, // Display the error message from the map
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                  const SizedBox(height: secondarySizedBox),
                  CustomWideButton(
                    text: "Submit",
                    onPressed: () async {
                      // Validate using the custom validator
                      if (_validatePhoneNumber()) {
                        setState(() {
                          _showError = false;
                          isLoading = true;
                          ref.read(userPhoneNumberProvider.notifier).state =
                              controllers['phoneNumber']!.text.trim();
                        });
                        await Supabase.instance.client.from('user').update({
                          'phone_number':
                              controllers['phoneNumber']!.text.trim()
                        }).eq('user_id', ref.watch(userIdProvider));

                        isLoading = false;

                        Navigator.push(
                            context,
                            rightToLeftRoute(const MainScreen(
                              initialPage: 3,
                            )));
                      } else {
                        setState(() {
                          _showError = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black54, // Semi-transparent background
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
