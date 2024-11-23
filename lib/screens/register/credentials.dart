import 'package:flutter/material.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
import 'package:pamfurred/components/password_textfield.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/text_field.dart';
import 'package:pamfurred/components/width_expanded_button.dart';
import 'package:pamfurred/screens/otp_input.dart';
import 'package:pamfurred/screens/register/intro_to_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CredentialsScreen extends StatefulWidget {
  final Map<String, TextEditingController> controllers;

  const CredentialsScreen({super.key, required this.controllers});

  @override
  CredentialsScreenState createState() => CredentialsScreenState();
}

class CredentialsScreenState extends State<CredentialsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = widget.controllers['email']?.text.trim() ?? '';
    final password = widget.controllers['password']?.text ?? '';
    final firstName = widget.controllers['firstName']?.text ?? '';
    final lastName = widget.controllers['lastName']?.text ?? '';
    final phoneNumber = widget.controllers['phoneNumber']?.text ?? '';
    final floorUnitRoom = widget.controllers['floorUnitRoom']?.text ?? '';
    final street = widget.controllers['street']?.text ?? '';
    final barangay = widget.controllers['barangay']?.text ?? '';
    final city = widget.controllers['city']?.text ?? '';

    // Basic field validation
    if (email.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email) ||
        password.length < 6) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Invalid input: Ensure all fields are filled and valid. Password must be at least 6 characters.";
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
          'phone_number': phoneNumber,
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

        if (addressId != null) {
          // Insert user details
          await Supabase.instance.client.from('user').insert({
            'user_id': userId,
            'phone_number': phoneNumber,
            'user_type': 'pet_owner',
            'first_name': firstName,
            'last_name': lastName,
            'address_id': addressId,
          });

          // Insert pet owner details
          await Supabase.instance.client.from('pet_owner').insert({
            'email': email,
            'pet_owner_id': userId,
          });

          if (mounted) {
            Navigator.push(
                context, rightToLeftRoute(OtpVerificationScreen(email: email)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionHeader("Credentials"),
              const SizedBox(height: secondaryBorderRadius),
              formDescription(context,
                  "Enter your email address and choose a password to create an account. This will allow you to log in securely and enable service providers to contact you regarding your appointments"),
              const SizedBox(height: secondarySizedBox),
              buildTextField("Email address", "email", widget.controllers,
                  isEmail: true),
              const SizedBox(height: secondarySizedBox),
              PasswordTextField(
                label: "Password",
                controllerKey: "password",
                controllers: widget.controllers,
              ),
              const SizedBox(height: secondarySizedBox),
              if (_errorMessage != null) ...[
                SizedBox(
                  height: 100,
                  child: Wrap(
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: secondarySizedBox),
              ],
              const SizedBox(height: tertiarySizedBox),
              CustomWideButton(
                text: "Register",
                onPressed: _isLoading
                    ? null
                    : () {
                        _registerUser();
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
