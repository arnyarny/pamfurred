import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final String controllerKey;
  final Map<String, TextEditingController> controllers;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controllerKey,
    required this.controllers,
  });

  @override
  PasswordTextFieldState createState() => PasswordTextFieldState();
}

class PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscurePassword = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  // Persist ValueNotifier to track password strength
  final ValueNotifier<PasswordStrength?> _passNotifier =
      ValueNotifier<PasswordStrength?>(null);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _passNotifier.dispose(); // Dispose the notifier when the widget is disposed
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "${widget.label} ",
            style: const TextStyle(color: Colors.black, fontSize: regularText),
            children: const [
              TextSpan(text: "*", style: TextStyle(color: primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: secondarySizedBox),
        TextFormField(
          controller: widget.controllers[widget.controllerKey],
          obscureText: _obscurePassword,
          focusNode: _focusNode,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(secondaryBorderRadius),
            ),
            hintText: "Enter your password",
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          onChanged: (value) {
            // Update the password strength whenever the password is typed
            _passNotifier.value = PasswordStrength.calculate(text: value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "${widget.label} is required";
            }
            return null;
          },
        ),
        const SizedBox(height: secondarySizedBox),
        // Only show PasswordStrengthChecker if there's text or if focused
        if (_isFocused ||
            (widget.controllers[widget.controllerKey]?.text.isNotEmpty ??
                false))
          PasswordStrengthChecker(
            strength: _passNotifier, // Use the existing ValueNotifier
          ),
      ],
    );
  }
}
