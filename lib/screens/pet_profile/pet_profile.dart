import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/pet_profile/delete_pet_profile.dart';
import 'package:quickalert/models/quickalert_animtype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key});

  @override
  PetProfileScreenState createState() => PetProfileScreenState();
}

class PetProfileScreenState extends ConsumerState<PetProfileScreen> {
  bool _isExpanded = false;
  late DeletePetProfileService deletPetProfileService;

  void initState() {
    super.initState();
    deletPetProfileService = DeletePetProfileService();
  }

  @override
  Widget build(BuildContext context) {
    final petProfileId = ref.watch(selectedPetIdProvider);
    final asyncPet = ref.watch(fetchPetByIdProvider(petProfileId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      body: PullToRefresh(
        providersToRefresh: [fetchPetByIdProvider(petProfileId)],
        child: asyncPet.when(
          data: (pet) {
            if (pet == null) {
              return const Center(child: Text("No pet data available."));
            }

            const double descWidth = 331;
            return Center(
              child: SingleChildScrollView(
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
                                      child: CachedNetworkImage(
                                        imageUrl: pet['pet_image'] ?? '',
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
                          customTitleText(
                              context, capitalizeFirstLetter(pet['pet_name'])),
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
                                    petDesc(
                                        context,
                                        'assets/id-card.png',
                                        capitalizeFirstLetter(pet['pet_name']),
                                        "name"),
                                    const SizedBox(height: secondarySizedBox),
                                    petDesc(
                                        context,
                                        'assets/time.png',
                                        calculateAgeInMonthsOrWeeks(
                                                pet['pet_date_of_birth']) ??
                                            'N/A',
                                        "age"),
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
                                          capitalizeFirstLetter(
                                              pet['pet_breed']),
                                          "breed"),
                                      const SizedBox(height: secondarySizedBox),
                                      petDesc(
                                          context,
                                          'assets/categories.png',
                                          capitalizeFirstLetter(
                                              pet['pet_type']),
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
                                      style: const TextStyle(
                                          fontSize: regularText),
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
                            style: TextStyle(
                                color: pet['pet_desc'] == ''
                                    ? lightGreyColor
                                    : darkGreyColor,
                                fontSize: regularText),
                          ),
                        ),
                      ),
                      const SizedBox(height: quaternarySizedBox),
                      const SizedBox(height: quaternarySizedBox),
                      const SizedBox(height: quaternarySizedBox),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    secondaryBorderRadius),
                                color: primaryColor),
                            child: TextButton.icon(
                              label: Text(
                                'Delete pet profile',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                QuickAlert.show(
                                    context: context,
                                    animType: QuickAlertAnimType.slideInUp,
                                    type: QuickAlertType.warning,
                                    onConfirmBtnTap: () async {
                                      final result =
                                          await deletPetProfileService
                                              .deletePetProfile(
                                                  petProfileId:
                                                      pet['pet_profile_id'],
                                                  petProfileImage:
                                                      pet['pet_image'] ?? '');
                                      Navigator.pop(context);

                                      if (result != null) {
                                        final refreshed = ref.refresh(
                                            petProfileProvider(ref
                                                .watch(userIdProvider)
                                                .toString()));
                                        print(refreshed);

                                        Navigator.pushReplacement(
                                            context,
                                            crossFadeRoute(const MainScreen(
                                                initialPage: 3)));

                                        QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.success,
                                            title: 'Delete success',
                                            text:
                                                'The pet profile has been successfully deleted.');
                                        print(
                                            'Pet profile deleted successfully.');
                                      } else {
                                        print('Failed to delete pet profile.');
                                      }
                                    },
                                    showCancelBtn: true,
                                    cancelBtnText: 'No',
                                    confirmBtnText: 'Yes',
                                    confirmBtnColor: primaryColor,
                                    title: 'Delete pet profile?',
                                    text:
                                        'This will delete all the pet profile data.');
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: quaternarySizedBox),
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

  String? calculateAgeInMonthsOrWeeks(String? dateOfBirth) {
    if (dateOfBirth == null) return null;

    try {
      final dob = DateTime.parse(dateOfBirth); // Parse yyyy-MM-dd
      final now = DateTime.now();
      final ageInMonths = (now.year - dob.year) * 12 + now.month - dob.month;
      final ageInDays = now.difference(dob).inDays;

      // If the pet is less than 1 month old, calculate in weeks
      if (ageInMonths < 1) {
        final ageInWeeks = (ageInDays / 7).round();
        return '$ageInWeeks week${ageInWeeks > 1 ? 's' : ''} old';
      } else {
        return '$ageInMonths month${ageInMonths > 1 ? 's' : ''} old';
      }
    } catch (e) {
      return null; // Return null if parsing fails
    }
  }
}
