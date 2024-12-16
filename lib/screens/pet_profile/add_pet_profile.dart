import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/dropdown_decoration.dart';
import 'package:pamfurred/components/globals.dart';
import 'dart:developer';
import 'package:pamfurred/models/dropdown_contents/dog_breeds.dart';
import 'package:pamfurred/models/dropdown_contents/cat_breeds.dart';
import 'package:pamfurred/models/dropdown_contents/bunny_breeds.dart';
import 'package:pamfurred/models/dropdown_contents/pet_type.dart'; // Assuming PetType is in this file
import 'package:pamfurred/models/dropdown_contents/sex.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/providers/user_details.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
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

  File? _image; // Store the picked image file
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from the gallery
  Future<void> changeImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image =
            File(pickedFile.path); // Update the state with the selected image
      });
    }
  }

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
                  Center(
                    child: Stack(
                      alignment:
                          Alignment.center, // Center the overlay text or icon
                      children: [
                        Container(
                          width: 200, // Set width
                          height:
                              200, // Set height to the same value for a square
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors
                                .grey[300], // Placeholder background color
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!) as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null, // Only show the image decoration if _image is not null
                          ),
                          child: _image == null
                              ? const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null, // Show camera icon if _image is null
                        ),
                        Positioned(
                          bottom: 10,
                          right: 5,
                          child: Container(
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(100)),
                            child: IconButton(
                                onPressed: changeImage,
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                    child:
                        buildTextField('', 'description', TextInputType.text),
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
                        String petName = controllers['petName']!.text.trim();
                        double petWeight =
                            double.parse(controllers['petWeight']!.text);
                        String description =
                            controllers['description']!.text.isEmpty
                                ? 'No description provided.'
                                : controllers['description']!.text;
                        String? dateOfBirth = DateFormat('yyyy-MM-dd')
                            .format(selectedDateOfBirth!);
                        String sex = selectedSex.name;
                        String petType = selectedPetType.name;
                        String breed = selectedBreed ?? '';

                        // Upload image to Supabase storage
                        String imageUrl = '';
                        if (_image != null) {
                          imageUrl = await uploadImage(
                              _image!); // Get the image URL after uploading
                          print("Uploaded image URL: $imageUrl"); // Debug print
                        }

                        // Insert data into pet_profile table in Supabase
                        final userId = ref.watch(userIdProvider);

                        final response =
                            await supabase.from('pet_profile').insert({
                          'pet_owner_id': userId,
                          'pet_name': petName,
                          'pet_image': imageUrl,
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
                            final refreshed = ref.refresh(petProfileProvider(
                                ref.watch(userIdProvider).toString()));
                            print(refreshed);
                            Navigator.pop(context);
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: 'Success',
                                text:
                                    'The pet profile has been successfully added.');
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
        controllerKey == 'description'
            ? Text(
                "Description",
                style:
                    const TextStyle(color: Colors.black, fontSize: regularText),
              )
            : customRichText(label),
        const SizedBox(height: primarySizedBox),
        SizedBox(
          height: controllerKey == 'description' ? 87 : primaryTextFieldHeight,
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
              if (controllerKey == 'description' ||
                  controllerKey == 'dateOfBirth') {
                return null; // No validation for optional field
              }
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
                          capitalize(newValue.text); // Capitalize every word
                      return newValue.copyWith(text: newText);
                    }),
                  ]
                : controllerKey == 'description'
                    ? [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final newText = capitalizeFirstLetter(newValue
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

Future<String> uploadImage(File image) async {
  final filePath = '${image.uri.pathSegments.last}';
  final supabase = Supabase.instance.client;

  await supabase.storage.from('pet_profile').upload(filePath, image);
// If the upload is successful, get the public URL
  final publicUrl = supabase.storage.from('pet_profile').getPublicUrl(filePath);
  print("Generated public URL: $publicUrl");
  return publicUrl;
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
        decoration: getDropdownDecoration(),
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
