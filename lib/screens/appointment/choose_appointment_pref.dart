import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/error_builder.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/user_id.dart';

class ChooseAppointmentPreferencesScreen extends ConsumerStatefulWidget {
  const ChooseAppointmentPreferencesScreen({super.key});

  @override
  ConsumerState<ChooseAppointmentPreferencesScreen> createState() =>
      ChooseAppointmentPreferencesScreenState();
}

class ChooseAppointmentPreferencesScreenState
    extends ConsumerState<ChooseAppointmentPreferencesScreen> {
  int? selectedTypeIndex;
  int? selectedCategoryIndex;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spIndexData = ref.watch(spIndexProvider);
      final packageServiceTypeOptions =
          (spIndexData?['unique_package_service_types'] as List<dynamic>)
              .cast<String>();
      final categoryOptions =
          (spIndexData?['unique_categories'] as List<dynamic>).cast<String>();

      // Retrieve previously selected options if available
      final selectedServiceType =
          ref.read(selectedAppointmentPackageServiceTypeProvider);
      final selectedCategory = ref.read(selectedAppointmentCategoryProvider);

      setState(() {
        // Check if there is a previously selected type; otherwise, select the first option
        selectedTypeIndex =
            packageServiceTypeOptions.indexOf(selectedServiceType);
        if (selectedTypeIndex == -1) {
          selectedTypeIndex =
              0; // Default to the first option if nothing is selected
          ref
              .read(selectedAppointmentPackageServiceTypeProvider.notifier)
              .state = packageServiceTypeOptions[0];
        }

        // Check if there is a previously selected category; otherwise, select the first option
        selectedCategoryIndex = categoryOptions.indexOf(selectedCategory);
        if (selectedCategoryIndex == -1) {
          selectedCategoryIndex =
              0; // Default to the first option if nothing is selected
          ref.read(selectedAppointmentCategoryProvider.notifier).state =
              categoryOptions[0];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final petProfileData =
        ref.watch(petProfileProvider(ref.watch(userIdProvider).toString()));
    final spIndexData = ref.watch(spIndexProvider);

    // Get the JSONB data
    final petTypeOptions =
        (spIndexData?['unique_pet_types'] as List<dynamic>).cast<String>();
    final packageServiceTypeOptions =
        (spIndexData?['unique_package_service_types'] as List<dynamic>)
            .cast<String>();
    final categoryOptions =
        (spIndexData?['unique_categories'] as List<dynamic>).cast<String>();

    // Retrieve the current selected pet ID
    String? selectedPetProfileId = ref.watch(selectedPetProfileIdProvider);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: tertiarySizedBox),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(tertiaryBorderRadius),
              topRight: Radius.circular(tertiaryBorderRadius)),
          color: lighterGreyColor,
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(tertiaryBorderRadius),
                  ),
                  color: greyColor,
                ),
                width: 50,
                height: 5,
              ),
            ),
            const SizedBox(height: secondarySizedBox),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: tertiarySizedBox),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a pet',
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: boldWeight,
                        ),
                      ),
                    ],
                  ),
                ),
                petProfileData.when(
                  data: (pets) {
                    final pet = pets
                        .where((pet) =>
                            petTypeOptions.contains(pet['pet_type'].toString()))
                        .toList();

                    // Set the first pet as selected by default if none is already selected
                    if (selectedPetProfileId == null && pet.isNotEmpty) {
                      Future.microtask(() {
                        final firstPet = pet.first;
                        ref.read(selectedPetProfileIdProvider.notifier).state =
                            firstPet['pet_profile_id'];
                        ref
                            .read(selectedAppointmentPetTypeIndexProvider
                                .notifier)
                            .state = firstPet['pet_profile_id'];
                        ref
                            .read(selectedAppointmentPetTypeProvider.notifier)
                            .state = firstPet['pet_type'];
                      });
                    }

                    return SizedBox(
                      height: pet.isNotEmpty ? 60 : 180,
                      child: pet.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: secondarySizedBox),
                                  Text(
                                      "No pets with matching pet types for this service provider found.",
                                      style: TextStyle(
                                          fontSize: smallText,
                                          color: darkGreyColor)),
                                  SizedBox(height: tertiarySizedBox),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: pet.length,
                              itemBuilder: (context, index) {
                                final petName =
                                    pet[index]['pet_name'] ?? 'Unknown';

                                final petProfileId =
                                    pet[index]['pet_profile_id'];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // Update the selected pet ID in the provider
                                      ref
                                          .read(selectedPetProfileIdProvider
                                              .notifier)
                                          .state = petProfileId;
                                      ref
                                          .read(
                                              selectedAppointmentPetTypeIndexProvider
                                                  .notifier)
                                          .state = petProfileId;
                                      ref
                                          .read(
                                              selectedAppointmentPetTypeProvider
                                                  .notifier)
                                          .state = pet[index]['pet_type'];

                                      ref
                                          .read(
                                              selectedPetNameProvider.notifier)
                                          .state = petName;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: secondarySizedBox,
                                              horizontal: tertiarySizedBox),
                                          decoration: BoxDecoration(
                                            color: selectedPetProfileId ==
                                                    petProfileId
                                                ? darkGreyColor
                                                : lightGreyColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            petName,
                                            style: TextStyle(
                                              fontSize: regularText,
                                              fontWeight: regularWeight,
                                              color: selectedPetProfileId ==
                                                      petProfileId
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) {
                    print(error);
                    return const ErrorMessage();
                  },
                )
              ],
            ),
            const SizedBox(height: secondarySizedBox),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: tertiarySizedBox),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Service or package type',
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: boldWeight,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: packageServiceTypeOptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTypeIndex = index;
                            ref
                                .read(
                                    selectedAppointmentPackageServiceTypeProvider
                                        .notifier)
                                .state = packageServiceTypeOptions[index];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: secondarySizedBox,
                                    horizontal: tertiarySizedBox),
                                decoration: BoxDecoration(
                                  color: selectedTypeIndex == index
                                      ? darkGreyColor
                                      : lightGreyColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  packageServiceTypeOptions[index],
                                  style: TextStyle(
                                    fontSize: regularText,
                                    fontWeight: regularWeight,
                                    color: selectedTypeIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: secondarySizedBox),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: tertiarySizedBox),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: boldWeight,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryOptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                            ref
                                .read(selectedAppointmentCategoryProvider
                                    .notifier)
                                .state = categoryOptions[index];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: secondarySizedBox,
                                    horizontal: tertiarySizedBox),
                                decoration: BoxDecoration(
                                  color: selectedCategoryIndex == index
                                      ? darkGreyColor
                                      : lightGreyColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  capitalizeFirstLetter(categoryOptions[index]),
                                  style: TextStyle(
                                    fontSize: regularText,
                                    fontWeight: regularWeight,
                                    color: selectedCategoryIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: secondarySizedBox),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                primaryColor,
              )),
              onPressed: () {
                Navigator.pop(
                    context); // Close the modal when the button is pressed
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white, fontSize: regularText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
