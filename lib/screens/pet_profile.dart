import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key});

  @override
  PetProfileScreenState createState() => PetProfileScreenState();
}

class PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    
    final petProfileId = ref.watch(selectedPetIdProvider);
    final asyncPet = ref.watch(fetchPetByIdProvider(petProfileId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      body: asyncPet.when(
        data: (pet) {
          if (pet == null) {
            return const Center(child: Text("No pet data available."));
          }

          const double descWidth = 331;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: SizedBox(
                width: screenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: primarySizedBox),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          fit: StackFit.loose,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(0.1),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [primaryColor, Colors.transparent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.25, 0.9],
                                ),
                              ),
                              child: Card(
                                shape: const CircleBorder(),
                                elevation: 0,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(secondarySizedBox),
                                  child: ClipOval(
                                    child: Image.network(
                                      pet['pet_image'] ?? '',
                                      fit: BoxFit.cover,
                                      width: 151,
                                      height: 151,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 5,
                              right: 0,
                              child: SizedBox(
                                height: 32,
                                child: CircleAvatar(
                                  backgroundColor: primaryColor,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: tertiarySizedBox),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customTitleText(context, capitalizeFirstLetter(pet['pet_name'])),
                        const SizedBox(width: secondarySizedBox),
                      ],
                    ),
                    const SizedBox(height: tertiarySizedBox),
                    Center(
                      child: SizedBox(
                        width: descWidth + 25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customTitleText(context, 'Basic info'),
                            editIcon()
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: secondarySizedBox),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(secondarySizedBox),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  petDesc(context, 'assets/id-card.png',
                                      capitalizeFirstLetter(pet['pet_name']), "name"),
                                  const SizedBox(height: secondarySizedBox),
                                  petDesc(
                                      context,
                                      'assets/time.png',
                                      pet['pet_age']?.toString() ?? 'N/A',
                                      "mos. old"),
                                  const SizedBox(height: secondarySizedBox),
                                  petDesc(
                                      context,
                                      'assets/weight-scale.png',
                                      pet['pet_weight']?.toString() ?? 'N/A',
                                      "kg."),
                                  const SizedBox(height: secondarySizedBox),
                                ],
                              ),
                              if (_isExpanded) ...[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    petDesc(context, 'assets/gender.png',
                                        pet['pet_sex'] ?? 'N/A', "sex"),
                                    const SizedBox(height: secondarySizedBox),
                                    petDesc(
                                        context,
                                        'assets/breed.png',
                                        capitalizeFirstLetter(pet['pet_breed']),
                                        "breed"),
                                    const SizedBox(height: secondarySizedBox),
                                    petDesc(
                                        context,
                                        'assets/categories.png',
                                        capitalizeFirstLetter(pet['pet_type']),
                                        "category"),
                                  ],
                                ),
                              ],
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  child: Text(
                                    _isExpanded ? "See less" : "See more",
                                    style:
                                        const TextStyle(fontSize: regularText),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: descWidth + 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customTitleText(context, 'Description'),
                          editIcon()
                        ],
                      ),
                    ),
                    const SizedBox(height: tertiarySizedBox),
                    Center(
                      child: SizedBox(
                        width: descWidth,
                        child: Text(
                          pet['pet_desc'] ?? 'No description available.',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              color: darkGreyColor, fontSize: regularText),
                        ),
                      ),
                    ),
                    const SizedBox(height: quaternarySizedBox),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  subtitleText(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: darkGreyColor,
          fontSize: regularText,
          fontWeight: regularWeight),
    );
  }

  verticalDivider() {
    return Container(
      width: 1,
      height: 33,
      color: Colors.black,
      margin: const EdgeInsets.symmetric(horizontal: quaternarySizedBox),
    );
  }

  petDesc(
      BuildContext context, String image, String petDetail, String subtitle) {
    return Row(
      children: [
        Column(
          children: [Image.asset(image, height: 35)],
        ),
        const SizedBox(width: tertiarySizedBox),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                customBoldWeightRegularText(context, petDetail),
              ],
            ),
            Row(
              children: [
                subtitleText(subtitle),
              ],
            ),
          ],
        ),
      ],
    );
  }

  editIcon() {
    return const Icon(Icons.edit, size: 18, color: primaryColor);
  }
}
