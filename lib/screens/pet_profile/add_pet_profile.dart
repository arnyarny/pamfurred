import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'dart:developer';
import 'package:pamfurred/models/dropdown_contents/dog_breeds.dart';
import 'package:pamfurred/models/dropdown_contents/cat_breeds.dart';
import 'package:pamfurred/models/dropdown_contents/bunny_breeds.dart';
import 'package:pamfurred/models/dropdown_contents/pet_type.dart'; // Assuming PetType is in this file
import 'package:pamfurred/models/dropdown_contents/sex.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import the Sex class

class AddPetProfileScreen extends ConsumerStatefulWidget {
  const AddPetProfileScreen({super.key});

  @override
  AddPetProfileScreenState createState() => AddPetProfileScreenState();
}

class AddPetProfileScreenState extends ConsumerState<AddPetProfileScreen> {
  PetType selectedPetType = petTypeList[0]; // Default type (Dog)
  Sex selectedSex = sexList[0]; // Default sex (Male)
  String? selectedBreed;
  DateTime? selectedDateOfBirth;
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final Map<String, TextEditingController> controllers = {
    'petName': TextEditingController(),
    'petWeight': TextEditingController(),
    'description': TextEditingController(), // Added description controller
  };

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarWithTitle(context, 'Add Pet Profile'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: SizedBox(
            width: screenPadding(context),
            child: Form(
              key: _formKey, // Attach the form key for validation
              child: Column(
                children: [
                  const Wrap(children: [
                    Text(
                      'Quickly add your pet’s details like name, weight, sex, breed, and type (Dog, Cat, or Bunny). Simply select the pet type, and choose a breed from the filtered list to complete the profile!',
                      style: TextStyle(fontSize: regularText, color: greyColor),
                    ),
                  ]),
                  const SizedBox(height: tertiarySizedBox),
                  // Pet Name Text Field
                  buildTextField('Pet Name', 'petName', TextInputType.text),
                  const SizedBox(height: tertiarySizedBox),
                  // Pet Weight Text Field
                  buildTextField(
                      'Pet Weight (kg)', 'petWeight', TextInputType.number),
                  const SizedBox(height: tertiarySizedBox),
                  // Description Text Field (Longer than other fields)
                  SizedBox(
                    height: 112,
                    child: buildTextField(
                        'Description', 'description', TextInputType.text),
                  ),
                  const SizedBox(height: tertiarySizedBox),
                  // Date of Birth Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      customRichText('Pet Date of Birth'),
                    ],
                  ),
                  const SizedBox(height: primarySizedBox),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: TextEditingController(
                            text: selectedDateOfBirth != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(selectedDateOfBirth!)
                                : ''),
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.calendar_month),
                          contentPadding: const EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(secondaryBorderRadius),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: secondaryColor),
                            borderRadius:
                                BorderRadius.circular(secondaryBorderRadius),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: tertiarySizedBox),
                  // Pet Sex Dropdown (Male or Female)
                  getTitleWithDropdown<Sex>(
                      context, 'Pet Sex', 'Select pet sex', sexList,
                      (Sex? selectedGender) {
                    setState(() {
                      selectedSex = selectedGender ??
                          sexList[0]; // Default to the first sex if null
                    });
                  }),
                  const SizedBox(height: 10),
                  // Pet Type Dropdown (Dog, Cat, Bunny)
                  getTitleWithDropdown<PetType>(
                      context, 'Pet Type', 'Select pet type', petTypeList,
                      (PetType? selectedType) {
                    setState(() {
                      selectedPetType = selectedType ??
                          petTypeList[0]; // Default to the first type if null
                      selectedBreed = null; // Reset breed when type changes
                    });
                  }),
                  const SizedBox(height: 10),
                  // Breed Dropdown (Conditional based on selected pet type)
                  if (selectedPetType.name == 'Dog')
                    getTitleWithDropdown<DogBreed>(
                        context, 'Dog Breed', 'Select dog breed', dogBreedList,
                        (value) {
                      setState(() {
                        selectedBreed = value?.toString();
                        log('Selected Dog Breed: $selectedBreed');
                      });
                    }),
                  if (selectedPetType.name == 'Cat')
                    getTitleWithDropdown<CatBreed>(
                        context, 'Cat Breed', 'Select cat breed', catBreedList,
                        (value) {
                      setState(() {
                        selectedBreed = value?.toString();
                        log('Selected Cat Breed: $selectedBreed');
                      });
                    }),
                  if (selectedPetType.name == 'Bunny')
                    getTitleWithDropdown<BunnyBreed>(context, 'Bunny Breed',
                        'Select bunny breed', bunnyBreedList, (value) {
                      setState(() {
                        selectedBreed = value?.toString();
                        log('Selected Bunny Breed: $selectedBreed');
                      });
                    }),
                  const SizedBox(height: tertiarySizedBox),

                  // Submit Button
                  customPaddedTextButton(
                    text: 'Submit',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Gather the form data
                        String petName = controllers['petName']!.text;
                        double petWeight =
                            double.parse(controllers['petWeight']!.text);
                        String description = controllers['description']!.text;
                        String dateOfBirth = DateFormat('yyyy-MM-dd')
                            .format(selectedDateOfBirth!);
                        String sex = selectedSex.name;
                        String petType = selectedPetType.name;
                        String breed = selectedBreed ?? '';

                        // Insert data into pet_profile table in Supabase
                        final userId = ref.watch(userIdProvider);

                        final response =
                            await supabase.from('pet_profile').insert({
                          'pet_owner_id': userId,
                          'pet_name': petName,
                          'weight': petWeight,
                          'description': description,
                          'date_of_birth': dateOfBirth,
                          'sex': sex,
                          'pet_type': petType.toLowerCase(),
                          'breed': breed.toLowerCase(),
                        });

                        if (response == null) {
                          // Successfully inserted, you can show a success message or navigate
                          log('Pet profile added successfully');

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Pet profile added successfully!')),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: secondarySizedBox),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TextField building method with validation
  Widget buildTextField(
    String label,
    String controllerKey,
    TextInputType inputType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customRichText(label),
        const SizedBox(height: primarySizedBox),
        SizedBox(
          height: controllerKey == 'description' ? 90 : primaryTextFieldHeight,
          child: TextFormField(
            minLines: controllerKey == 'description' ? 3 : 1,
            maxLines: controllerKey == 'description' ? 10 : 1,
            controller: controllers[controllerKey],
            keyboardType: inputType,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(secondaryBorderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: secondaryColor),
                borderRadius: BorderRadius.circular(secondaryBorderRadius),
              ),
            ),
            // Validation
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              if (controllerKey == 'petName' &&
                  value.isNotEmpty &&
                  !RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) {
                return 'Pet name should contain only letters';
              }
              if (controllerKey == 'petWeight' &&
                  (double.tryParse(value) == null ||
                      double.parse(value) <= 0)) {
                return 'Enter a valid pet weight';
              }
              return null;
            },
            inputFormatters: controllerKey == 'petName'
                ? [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final newText =
                          _capitalize(newValue.text); // Capitalize every word
                      return newValue.copyWith(text: newText);
                    }),
                  ]
                : controllerKey == 'description'
                    ? [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final newText = _capitalizeFirstLetter(newValue
                              .text); // Capitalize only the first letter
                          return newValue.copyWith(text: newText);
                        }),
                      ]
                    : null,
          ),
        ),
      ],
    );
  }

  String _capitalize(String input) {
    return input
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  // Updated custom rich text method
  Widget customRichText(String label) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: "$label ",
          style: const TextStyle(color: Colors.black, fontSize: regularText),
        ),
        const TextSpan(
          text: "*",
          style: TextStyle(color: primaryColor),
        ),
      ]),
    );
  }

  // Function to show the DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDateOfBirth)
      // ignore: curly_braces_in_flow_control_structures
      setState(() {
        selectedDateOfBirth = picked;
      });
  }
}

String _capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

// Updated function signature with 5 parameters
getTitleWithDropdown<T extends CustomDropdownListFilter>(
  BuildContext context,
  String title,
  String hintText,
  List<T> list,
  ValueChanged<T?> onChanged,
) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          customRichText(title),
        ],
      ),
      const SizedBox(height: secondarySizedBox),
      CustomDropdown<T>.search(
        decoration: CustomDropdownDecoration(
          closedFillColor: lighterGreyColor,
          expandedFillColor: Colors.white,
          closedSuffixIcon: const Icon(Icons.arrow_drop_down),
          expandedSuffixIcon: const Icon(Icons.arrow_drop_up),
          closedBorder: Border.all(color: greyColor.withOpacity(.1), width: .8),
          closedBorderRadius: BorderRadius.circular(secondaryBorderRadius),
          closedErrorBorder: Border.all(color: Colors.red),
          closedErrorBorderRadius: BorderRadius.circular(secondaryBorderRadius),
          expandedBorder: Border.all(color: primaryColor, width: .15),
          expandedBorderRadius: BorderRadius.circular(secondaryBorderRadius),
          hintStyle: const TextStyle(color: greyColor, fontSize: regularText),
          noResultFoundStyle:
              const TextStyle(color: Colors.red, fontSize: regularText),
          errorStyle: const TextStyle(color: Colors.red, fontSize: regularText),
          listItemStyle:
              const TextStyle(color: Colors.black, fontSize: regularText),
          overlayScrollbarDecoration: const ScrollbarThemeData(
            thumbColor: WidgetStatePropertyAll(lightGreyColor),
          ),
        ),
        hintText: hintText,
        items: list,
        excludeSelected: false,
        onChanged: (value) {
          onChanged(value); // Pass the selected value to the callback
          log('Selected: $value');
          // setState(() {

          // });
        },
      ),
    ],
  );
}

Widget customRichText(String label) {
  return RichText(
    text: TextSpan(children: [
      TextSpan(
        text: "$label ",
        style: const TextStyle(color: Colors.black, fontSize: regularText),
      ),
      const TextSpan(
        text: "*",
        style: TextStyle(color: primaryColor),
      ),
    ]),
  );
}
