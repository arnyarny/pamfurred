import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
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
  int? selectedPetIndex;
  int? selectedTypeIndex;
  int? selectedCategoryIndex;

  @override
  void initState() {
    super.initState();

    // Delayed execution after widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Retrieve the service provider ID and options after the widget is built
      final spIndexData = ref.watch(spIndexProvider);

      // Initialize the default selections based on the provider data
      final petTypeOptions =
          (spIndexData?['unique_pet_types'] as List<dynamic>).cast<String>();
      final packageServiceTypeOptions =
          (spIndexData?['unique_package_service_types'] as List<dynamic>)
              .cast<String>();
      final categoryOptions =
          (spIndexData?['unique_categories'] as List<dynamic>).cast<String>();

      // Set default selected pet, type, and category if there is data available
      setState(() {
        selectedPetIndex = petTypeOptions.isNotEmpty ? 0 : null;
        selectedTypeIndex = packageServiceTypeOptions.isNotEmpty ? 0 : null;
        selectedCategoryIndex = categoryOptions.isNotEmpty ? 0 : null;
      });

      // Set the default values for appointment filters
      ref.read(selectedAppointmentPetTypeProvider.notifier).state =
          petTypeOptions.isNotEmpty && petTypeOptions[0].isNotEmpty
              ? petTypeOptions[0]
              : '';
      ref.read(selectedAppointmentPackageServiceTypeProvider.notifier).state =
          packageServiceTypeOptions.isNotEmpty && packageServiceTypeOptions[0].isNotEmpty
              ? packageServiceTypeOptions[0]
              : '';
      ref.read(selectedAppointmentCategoryProvider.notifier).state =
          categoryOptions.isNotEmpty && categoryOptions[0].isNotEmpty
              ? categoryOptions[0]
              : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenPaddingValue = screenPadding(context);

    final petProfileData =
        ref.watch(petProfileProvider(ref.watch(userIdProvider).toString()));

    // Retrieve the service provider ID
    final spIndexData = ref.watch(spIndexProvider);

    // Get the JSONB data
    final petTypeOptions =
        (spIndexData?['unique_pet_types'] as List<dynamic>).cast<String>();

    // Get the JSONB data
    final packageServiceTypeOptions =
        (spIndexData?['unique_package_service_types'] as List<dynamic>)
            .cast<String>();

    final categoryOptions =
        (spIndexData?['unique_categories'] as List<dynamic>).cast<String>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBarWithTitle(context, 'Appointment Filters'),
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenPaddingValue,
          child: Column(
            children: [
              const SizedBox(height: secondarySizedBox),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a pet',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: regularWeight,
                    ),
                  ),
                  petProfileData.when(
                    data: (pets) {
                      final pet = pets
                          .where((pet) => petTypeOptions
                              .contains(pet['pet_type'].toString()))
                          .toList();
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

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPetIndex = index;
                                        ref
                                            .read(
                                                selectedAppointmentPetTypeProvider
                                                    .notifier)
                                            .state = pet[index]['pet_type'];
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
                                              color: selectedPetIndex == index
                                                  ? primaryColor
                                                  : lightGreyColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              petName,
                                              style: TextStyle(
                                                fontSize: regularText,
                                                fontWeight: regularWeight,
                                                color: selectedPetIndex == index
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
                  const Text(
                    'Service or package type',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: regularWeight,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: secondarySizedBox,
                                      horizontal: tertiarySizedBox),
                                  decoration: BoxDecoration(
                                    color: selectedTypeIndex == index
                                        ? primaryColor
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
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: regularWeight,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: secondarySizedBox,
                                      horizontal: tertiarySizedBox),
                                  decoration: BoxDecoration(
                                    color: selectedCategoryIndex == index
                                        ? primaryColor
                                        : lightGreyColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    capitalizeFirstLetter(
                                        categoryOptions[index]),
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
            ],
          ),
        ),
      ),
    );
  }
}
