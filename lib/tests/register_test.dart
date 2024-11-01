// import 'dart:async';
// import 'dart:io';

// import 'package:email_validator/email_validator.dart';
// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:pamfurred/components/custom_appbar.dart';
// import 'package:pamfurred/components/globals.dart';
// import 'package:pamfurred/components/screen_transitions.dart';
// import 'package:pamfurred/screens/otp_auth.dart';
// import 'package:pamfurred/screens/pin_location.dart';
// import 'package:path_provider/path_provider.dart';

// import '../components/custom_padded_button.dart';

// class RegisterScreenTest extends StatefulWidget {
//   const RegisterScreenTest({super.key});

//   @override
//   RegisterScreenTestState createState() => RegisterScreenTestState();
// }

// class RegisterScreenTestState extends State<RegisterScreenTest> {
//   final formKey = GlobalKey<FormState>();

//   int activeStepIndex = 0;
//   String pinnedLocationImage = '';

//   // TextEditingControllers
//   late Map<String, TextEditingController> controllers = {
//     'firstName': TextEditingController(),
//     'lastName': TextEditingController(),
//     'phoneNumber': TextEditingController(),
//     'doorNo': TextEditingController(),
//     'street': TextEditingController(),
//     'barangay': TextEditingController(),
//     'city': TextEditingController(),
//     'username': TextEditingController(),
//     'email': TextEditingController(),
//     'password': TextEditingController(),
//   };

//   bool _obscureText = true;

//   @override
//   void initState() {
//     super.initState();
//     loadLatestImage();
//   }

//   Future<void> loadLatestImage() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/pinned_location.png';
//     if (File(path).existsSync()) {
//       setState(() {
//         pinnedLocationImage = path;
//       });
//     }
//   }

//   List<Step> stepList() => [
//         Step(
//           state: activeStepIndex <= 0 ? StepState.editing : StepState.complete,
//           isActive: activeStepIndex >= 0,
//           title: const Text(''),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Name and contact",
//                 style: TextStyle(
//                   fontSize: headerText,
//                   fontWeight: mediumWeight,
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "First name ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['firstName'],
//                   // validator
//                   validator: (value) {
//                     return (value == null || value.isEmpty) ? 'Please enter first name' : null;
//                   },
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Last name ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['lastName'],
//                   // validator
//                   validator: (value) {
//                     return (value == null || value.isEmpty) ? 'Please enter last name' : null;
//                   },
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Phone number ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                   height: 65,
//                   child: IntlPhoneField(
//                     cursorColor: Colors.black,
//                     initialCountryCode: 'PH',
//                     controller: controllers['phoneNumber'],
//                     decoration: InputDecoration(
//                         contentPadding: const EdgeInsets.all(10.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             secondaryBorderRadius,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(color: secondaryColor),
//                             borderRadius:
//                                 BorderRadius.circular(secondaryBorderRadius))),
//                   )),
//               const SizedBox(height: secondarySizedBox),
//               const Text(
//                 "Address",
//                 style: TextStyle(
//                   fontSize: headerText,
//                   fontWeight: mediumWeight,
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               const Text(
//                 "Door no.",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: regularText,
//                 ),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['doorNo'],
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Street ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: regularText,
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['street'],
//                   keyboardType: TextInputType.streetAddress,
//                   // validator
//                   validator: (value) {
//                     return (value == null || value.isEmpty) ? 'Please enter street name' : null;
//                   },
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Barangay ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: regularText,
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['barangay'],
//                   // validator
//                   validator: (value) {
//                     return (value == null || value.isEmpty) ? 'Please enter barangay' : null;
//                   },
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "City ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: regularText,
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['city'],
//                   // validator
//                   validator: (value) {
//                     return (value == null || value.isEmpty) ? 'Please enter city' : null;
//                   },
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: tertiarySizedBox),
//               const Text(
//                 "Pin address",
//                 style: TextStyle(
//                   fontSize: headerText,
//                   fontWeight: mediumWeight,
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Pin exact address ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: regularText,
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               Center(
//                 child: Container(
//                   height: 170,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       width: 1.0,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   child: InkWell(
//                     onTap: () async {
//                       var result = await Navigator.of(context)
//                           .push(rightToLeftRoute(const PinAddress()));
//                       if (result != null) {
//                         setState(() {
//                           pinnedLocationImage = result;
//                         });
//                       }
//                     },
//                     child: Container(
//                       height: 150,
//                       decoration: BoxDecoration(
//                         image: pinnedLocationImage.isNotEmpty
//                             ? DecorationImage(
//                                 image: FileImage(File(pinnedLocationImage)),
//                                 fit: BoxFit.cover,
//                               )
//                             : null,
//                       ),
//                       child: pinnedLocationImage.isEmpty
//                           ? Center(
//                               child: Image.asset(
//                               'assets/pin_address.png',
//                               fit: BoxFit.cover,
//                             ))
//                           : null,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: tertiarySizedBox),
//             ],
//           ),
//         ),
//         Step(
//           state: activeStepIndex <= 1 ? StepState.editing : StepState.complete,
//           isActive: activeStepIndex >= 1,
//           title: const Text(''),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Credentials",
//                 style: TextStyle(
//                   fontSize: headerText,
//                   fontWeight: mediumWeight,
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Username ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: regularText,
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['username'],
//                   // validator
//                   validator: (value) {
//                     return (value == null || value.isEmpty) ? 'Please enter username' : null;
//                   },
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Email address ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: regularText,
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   keyboardType: TextInputType.emailAddress,
//                   controller: controllers['email'],
//                   // validator
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter email address';
//                     } else {
//                       return (!EmailValidator.validate(value))
//                           ? 'Invalid Email Address'
//                           : null;
//                     }
//                   },
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Password ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontSize: regularText,
//                     ),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['password'],
//                   // validator
//                   validator: (value) {
//                     return (value == null || value.isEmpty) ? 'Please enter password' : null;
//                   },
//                   obscureText: _obscureText,
//                   decoration: InputDecoration(
//                     contentPadding: const EdgeInsets.all(10.0),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(
//                         secondaryBorderRadius,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: secondaryColor),
//                         borderRadius:
//                             BorderRadius.circular(secondaryBorderRadius)),
//                     suffix: IconButton(
//                       icon: Padding(
//                           padding: const EdgeInsets.only(top: 5),
//                           child: Icon(
//                             _obscureText
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                             color: Colors.grey,
//                           )),
//                       onPressed: () {
//                         setState(() {
//                           _obscureText = !_obscureText;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: tertiarySizedBox),
//             ],
//           ),
//         ),
//         Step(
//           state: StepState.complete,
//           isActive: activeStepIndex >= 2,
//           title: const Text(''),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text('Name: ${controllers['firstName']?.text}'
//                   ' '
//                   '${controllers['lastName']?.text}'),
//               Text('Phone number: ${controllers['phoneNumber']?.text}'),
//               Text(
//                   'Address: ${controllers['doorNo']?.text},${controllers['street']?.text},${controllers['barangay']?.text},${controllers['city']?.text}'),
//               Text('Password: ${controllers['password']?.text}')
//             ],
//           ),
//         ),
//       ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: customAppBar(context),
//       body: Theme(
//         data: ThemeData(
//           canvasColor:
//               Colors.transparent, // Set the background color to transparent
//           colorScheme:
//               Theme.of(context).colorScheme.copyWith(primary: primaryColor),
//           splashColor: Colors.transparent,
//         ),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 30),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: secondarySizedBox),
//                     const Text(
//                       "Create an account",
//                       style: TextStyle(
//                         color: primaryColor,
//                         fontWeight: FontWeight.w900,
//                         fontSize: titleFont,
//                       ),
//                     ),
//                     const SizedBox(height: secondarySizedBox),
//                     RichText(
//                       text: const TextSpan(
//                         style: TextStyle(fontSize: regularText),
//                         children: [
//                           TextSpan(
//                             text: "Fields marked with (",
//                             style: TextStyle(
//                               color: greyColor,
//                             ),
//                           ),
//                           TextSpan(
//                             text: "*",
//                             style: TextStyle(
//                               color: primaryColor,
//                             ),
//                           ),
//                           TextSpan(
//                             text: ") are required.",
//                             style: TextStyle(
//                               color: greyColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: secondarySizedBox),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Form(
//                   key: formKey,
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   child: Stepper(
//                     elevation: 0,
//                     type: StepperType.horizontal,
//                     currentStep: activeStepIndex,
//                     steps: stepList(),
//                     onStepContinue: () {
//                       if (activeStepIndex < (stepList().length - 1)) {
//                         setState(() {
//                           activeStepIndex += 1;
//                         });
//                       } else {
//                         // Save to database
//                         print('Submitted');
//                       }
//                     },
//                     onStepCancel: () {
//                       if (activeStepIndex == 0) {
//                         return;
//                       }

//                       setState(() {
//                         activeStepIndex -= 1;
//                       });
//                     },
//                     controlsBuilder:
//                         (BuildContext context, ControlsDetails details) {
//                       final isLastStep =
//                           activeStepIndex == stepList().length - 1;
//                       return Row(
//                         children: [
//                           if (activeStepIndex > 0)
//                             Expanded(
//                               child: customPaddedOutlinedTextButton(
//                                 text: "Back",
//                                 onPressed: details.onStepCancel != null
//                                     ? details.onStepCancel!
//                                     : () {},
//                               ),
//                             ),
//                           const SizedBox(
//                             width: secondarySizedBox,
//                           ),
//                           Expanded(
//                             child: customPaddedTextButton(
//                               onPressed: () {
//                                 // Validate the form
//                                 var isFormValid =
//                                     formKey.currentState!.validate();
//                                 print(
//                                     'Form valid: $isFormValid'); // Debug print

//                                 if (isFormValid) {
//                                   if (isLastStep) {
//                                     // Save to database and navigate to HomeScreen
//                                     print(
//                                         'Navigating to OTPAuth'); // Debug print
//                                     Navigator.push(context,
//                                         rightToLeftRoute(const OTPAuth()));
//                                   } else {
//                                     // Continue to the next step
//                                     print(
//                                         'Continuing to next step'); // Debug print
//                                     details.onStepContinue?.call();
//                                   }
//                                 } else {
//                                   print('Form is not valid'); // Debug print
//                                 }
//                               },
//                               text: (isLastStep) ? "Register" : "Next",
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
