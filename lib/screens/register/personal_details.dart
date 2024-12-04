import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/register.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:pamfurred/screens/register/phone_number.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;

  const PersonalInformationScreen({super.key, required this.controllers});

  @override
  PersonalInformationScreenState createState() =>
      PersonalInformationScreenState();
}

class PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    bool validateFields() {
      final firstName = widget.controllers['firstName']?.text.trim() ?? '';
      final lastName = widget.controllers['lastName']?.text.trim() ?? '';
      return firstName.isNotEmpty && lastName.isNotEmpty;
    }

    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader("Personal Information"),
            const SizedBox(height: secondaryBorderRadius),
            formDescription(context,
                "Please enter your first and last name to help us personalize your experience. This will ensure that we address you properly and tailor our services to your needs."),
            const SizedBox(height: tertiarySizedBox),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "First name",
                    controllerKey: "firstName",
                    controllers: widget.controllers
                  ),
                ),
                const SizedBox(width: primarySizedBox),
                Expanded(
                  child: CustomTextField(
                      label: "Last name",
                      controllerKey: "lastName",
                      controllers: widget.controllers),
                ),
              ],
            ),
            if (_showError) ...[
              const SizedBox(height: 8.0),
              const Text(
                "Please fill out all required fields.",
                style: TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: tertiarySizedBox),
            CustomWideButton(
              text: "Next",
              validator: validateFields,
              onValidationFailed: () {
                setState(() {
                  _showError = true;
                });
              },
              onPressed: () {
                setState(() {
                  _showError = false;
                  ref.read(firstNameProvider.notifier).state =
                      widget.controllers['firstName']!.text.trim();
                  ref.read(lastNameProvider.notifier).state =
                      widget.controllers['lastName']!.text.trim();
                });
                Navigator.push(
                    context,
                    rightToLeftRoute(PhoneNumberScreen(controllers: {
                      'phoneNumber': TextEditingController(),
                    })));
              },
            ),
            const SizedBox(height: quaternarySizedBox),
            hasAnAccount(context)
          ],
        ),
      ),
    );
  }
}
