import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/user_details.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditName extends ConsumerStatefulWidget {
  const EditName({super.key});

  @override
  EditNameState createState() => EditNameState();
}

class EditNameState extends ConsumerState<EditName> {
  bool showError = false;
  bool isLoading = false;
  Map<String, String> errorMessages = {}; // To store specific error messages

  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {
      'firstName': TextEditingController(),
      'lastName': TextEditingController(),
    };
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // Individual validators
  bool validateFields() {
    final firstName = controllers['firstName']?.text.trim() ?? '';
    final lastName = controllers['lastName']?.text.trim() ?? '';

    if (firstName.isEmpty) {
      errorMessages['firstName'] = "First name cannot be empty.";
      return false;
    }
    errorMessages.remove('firstName');

    if (lastName.isEmpty) {
      errorMessages['lastName'] = "Last name cannot be empty.";
      return false;
    }
    errorMessages.remove('lastName');

    return true;
  }

  bool validateSameName() {
    final firstName = controllers['firstName']?.text.trim() ?? '';
    final lastName = controllers['lastName']?.text.trim() ?? '';
    final dbFirstName = ref.read(userFirstNameProvider);
    final dbLastName = ref.read(userLastNameProvider);

    if (firstName == dbFirstName && lastName == dbLastName) {
      errorMessages['nameChange'] =
          "First and last names cannot be the same as the current values.";
      return false;
    }
    errorMessages.remove('nameChange');

    return true;
  }

  // Combined validator
  bool combinedValidator() {
    bool isFieldsValid = validateFields();
    bool isNameDifferent = validateSameName();
    setState(() {}); // Update the UI to reflect new error messages
    return isFieldsValid && isNameDifferent;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: customAppBarWithTitle(context, 'Change name'),
          backgroundColor: Colors.white,
          body: Padding(
            padding: primaryPadding,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionHeader("Full name"),
                  const SizedBox(height: secondaryBorderRadius),
                  formDescription(
                    context,
                    "Easily update your first and last name to keep your profile accurate and personalized. Enter your new details below and confirm the changes.",
                  ),
                  const SizedBox(height: tertiarySizedBox),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "First name",
                          controllerKey: "firstName",
                          controllers: controllers,
                          defaultValue: ref.read(userFirstNameProvider),
                          errorText:
                              errorMessages['firstName'], // Display error
                        ),
                      ),
                      const SizedBox(width: primarySizedBox),
                      Expanded(
                        child: CustomTextField(
                          label: "Last name",
                          controllerKey: "lastName",
                          controllers: controllers,
                          defaultValue: ref.read(userLastNameProvider),
                          errorText: errorMessages['lastName'], // Display error
                        ),
                      ),
                    ],
                  ),
                  if (errorMessages['nameChange'] != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      errorMessages['nameChange']!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: tertiarySizedBox),
                  CustomWideButton(
                    text: "Submit",
                    validator: combinedValidator,
                    onValidationFailed: () {
                      setState(() {
                        showError = true;
                      });
                    },
                    onPressed: () async {
                      setState(() {
                        showError = false;
                        isLoading = true;
                      });

                      await Supabase.instance.client.from('pet_owner').update({
                        'first_name': ref
                            .read(userFirstNameProvider.notifier)
                            .state = controllers['firstName']!.text.trim(),
                        'last_name': ref
                            .read(userLastNameProvider.notifier)
                            .state = controllers['lastName']!.text.trim(),
                      }).eq('pet_owner_id', ref.watch(userIdProvider));

                      isLoading = false;

                      Navigator.push(
                        context,
                        rightToLeftRoute(const MainScreen(
                          initialPage: 3,
                        )),
                      );
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
