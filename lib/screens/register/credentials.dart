import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/password_textfield.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/providers/register.dart';
import 'package:pamfurred/screens/otp_input.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CredentialsScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;

  const CredentialsScreen({super.key, required this.controllers});

  @override
  CredentialsScreenState createState() => CredentialsScreenState();
}

class CredentialsScreenState extends ConsumerState<CredentialsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    Future<void> registerUser() async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final email = widget.controllers['email']?.text.trim() ?? '';
      final password = widget.controllers['password']?.text ?? '';

      final firstName = ref.watch(firstNameProvider);
      final lastName = ref.watch(lastNameProvider);
      final phoneNumber = ref.watch(phoneNumberProvider);
      final floorUnitRoom = ref.watch(floorUnitRoomProvider);
      final street = ref.watch(streetProvider);
      final barangay = capitalizeFirstLetter(ref.watch(barangayProvider));
      final city = capitalizeFirstLetter(ref.watch(cityProvider));

      // Basic field validation
      if (email.isEmpty ||
          !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
              .hasMatch(email) ||
          password.length < 6) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Invalid input: Ensure all fields are filled and password must be secure.";
        });
        return;
      }

      try {
        // Supabase user registration
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'firstName': firstName,
            'lastName': lastName,
            'phone': phoneNumber,
          },
        );

        if (response.user != null) {
          final userId = response.user!.id;

          // Insert address information
          final addressResponse = await Supabase.instance.client
              .from('address')
              .insert({
                'floor_unit_room': floorUnitRoom,
                'street': street,
                'barangay': barangay,
                'city': city,
              })
              .select('address_id')
              .single();

          final String? addressId = addressResponse['address_id'];

          // Get the current time in UTC
          DateTime timestamp = DateTime.now().toUtc();

          if (addressId != null) {
            // Insert user details
            await Supabase.instance.client.from('user').insert({
              'user_id': userId,
              'phone_number': phoneNumber,
              'user_type': 'pet_owner',
              'first_name': firstName,
              'last_name': lastName,
              'address_id': addressId,
              'created_at': timestamp.toString(),
            });

            // Insert pet owner details
            await Supabase.instance.client.from('pet_owner').insert({
              'email': email,
              'pet_owner_id': userId,
            });

            if (context.mounted) {
              Navigator.push(context,
                  rightToLeftRoute(OtpVerificationScreen(email: email)));
            }
          } else {
            throw Exception("Address registration failed.");
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Error during registration: $e";
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionHeader("Credentials"),
              const SizedBox(height: secondaryBorderRadius),
              formDescription(context,
                  "Enter your email address and choose a password to create an account. This will allow you to log in securely and enable service providers to contact you regarding your appointments."),
              const SizedBox(height: secondarySizedBox),
              CustomTextField(
                  label: "Email address",
                  controllerKey: "email",
                  controllers: widget.controllers,
                  isEmail: true),
              const SizedBox(height: secondarySizedBox),
              PasswordTextField(
                label: "Password",
                controllerKey: "password",
                controllers: widget.controllers,
              ),
              const SizedBox(height: secondarySizedBox),
              if (_errorMessage != null) ...[
                Wrap(
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: secondarySizedBox),
              ],
              CustomWideButton(
                text: "Register",
                onPressed: _isLoading
                    ? null
                    : () {
                        registerUser();
                      },
                isLoading: _isLoading,
              ),
              const SizedBox(height: quaternarySizedBox),
              hasAnAccount(context)
            ],
          ),
        ),
      ),
    );
  }
}
