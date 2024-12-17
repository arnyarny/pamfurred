import 'package:about/about.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/connectivity_wrapper.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/error_widget.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/providers/user_details.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/pet_profile/add_pet_profile.dart';
import 'package:pamfurred/screens/pet_profile/pet_profile.dart';
import 'package:pamfurred/screens/profile/edit_address.dart';
import 'package:pamfurred/screens/profile/edit_name.dart';
import 'package:pamfurred/screens/profile/edit_phone_number.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? mapPetOwnerDetails;
  Map<String, dynamic>? mapUserDetails;
  Map<String, dynamic>? mapUserAddress;
  bool isLoading = true;

  String? petId;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the screen initializes
  }

  void _logout() async {
    setState(() {
      // Clear the cart when logout is pressed
      ref.read(cartNotifierProvider.notifier).clearCart();

      isLoading = true;
      ref.read(visibilityProvider.notifier).setVisible(false);
    });

    await Supabase.instance.client.auth.signOut();

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      Navigator.push(context, crossFadeRoute(const LoginScreen()));
    }
  }

  // Function to fetch user data from Supabase
  Future<void> _fetchUserData() async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;

      if (userSession == null) {
        throw Exception("User not logged in");
      }

      // Use your session data to get user info (modify as needed based on how you manage user info)
      final userId = userSession.user.id; // Get user ID from session

      final petOwnerDetails = await Supabase.instance.client
          .from('pet_owner')
          .select()
          .eq('pet_owner_id', userId) // Query based on the current user's ID
          .single();

      final userDetails = await Supabase.instance.client
          .from('user')
          .select()
          .eq('user_id', userId) // Query based on the current user's ID
          .single();

      final String addressId = userDetails['address_id'];

      final addressDetails = await Supabase.instance.client
          .from('address')
          .select()
          .eq('address_id', addressId)
          .single();

      setState(() {
        mapPetOwnerDetails = petOwnerDetails;
        mapUserDetails = userDetails;
        mapUserAddress = addressDetails;
        isLoading = false;

        // Full name
        ref.read(userFirstNameProvider.notifier).state =
            mapPetOwnerDetails?['first_name'];
        ref.read(userLastNameProvider.notifier).state =
            mapPetOwnerDetails?['last_name'];

        // Phone number
        ref.read(userPhoneNumberProvider.notifier).state =
            mapUserDetails?['phone_number'];
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false; // Stop loading even on error
      });
    }
  }

  String convertToAsterisks(String text) {
    return '*' *
        text.length; // Create a string of asterisks with the same length
  }

  @override
  Widget build(BuildContext context) {
    // Access user ID
    final userId = ref.watch(userIdProvider);

    // If userId is null (loading or not logged in), show a loading spinner
    if (userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Access the list of pet profiles
    final petProfileData = ref.watch(petProfileProvider(userId));

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: ConnectivityWrapper(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: PullToRefresh(
              providersToRefresh: [
                petProfileProvider(userId),
              ],
              child: SizedBox(
                height: getScreenHeight(context),
                child: petProfileData.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator()), // Show loading spinner
                  error: (error, stackTrace) =>
                      Center(child: somethingWentWrong()), // Show error message
                  data: (data) => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: primarySizedBox),
                        child: SizedBox(
                          width: screenPadding(context),
                          child: Column(
                            children: [
                              const SizedBox(height: tertiarySizedBox),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildProfileSectionHeader(
                                    '${mapPetOwnerDetails?['first_name'] ?? ''} ${mapPetOwnerDetails?['last_name'] ?? ''}'
                                        .trim(),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Logout?',
                                          text:
                                              'Are you sure you want to logout?',
                                          animType:
                                              QuickAlertAnimType.slideInUp,
                                          showCancelBtn: true,
                                          confirmBtnColor: primaryColor,
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                            _logout();
                                          });
                                    },
                                    icon: const Icon(Icons.logout),
                                    iconSize: 25,
                                    color: greyColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: primarySizedBox),
                              Card(
                                color: Colors.white.withOpacity(0.9),
                                shadowColor: Colors.grey.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      width: 0.15, color: Colors.black),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 16, 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          customTitleText(context, "Pets")
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: tertiarySizedBox,
                                          right: tertiarySizedBox,
                                        ),
                                        child: SizedBox(
                                          height: data.isNotEmpty
                                              ? 60
                                              : 180, // Increased height for more space in empty state
                                          child: data.isEmpty
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(Icons.pets,
                                                          size: 40,
                                                          color: primaryColor),
                                                      const SizedBox(
                                                          height:
                                                              secondarySizedBox),
                                                      const Text(
                                                          "No pets yet! 🐾",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  regularText,
                                                              color:
                                                                  darkGreyColor)),
                                                      const SizedBox(
                                                          height:
                                                              primarySizedBox),
                                                      const Text(
                                                          "Add your first pet to get started!",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  smallText,
                                                              color:
                                                                  darkGreyColor)),
                                                      const SizedBox(
                                                          height:
                                                              tertiarySizedBox),
                                                      customPaddedTextButton(
                                                        text: 'Add Pet',
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              slideUpRoute(
                                                                  const AddPetProfileScreen()));
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height:
                                                              tertiarySizedBox),
                                                    ],
                                                  ),
                                                )
                                              : ListView.builder(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: data.length +
                                                      1, // Add 1 for the Add button
                                                  itemBuilder:
                                                      (context, index) {
                                                    final petProfileImage = index <
                                                            data.length
                                                        ? data[index]
                                                            ['pet_image']
                                                        // Temporary placeholder
                                                        : 'https://tinyurl.com/357z4usj';
                                                    return index == data.length
                                                        ? _buildAddPetButton(
                                                            context)
                                                        : _buildPetProfile(
                                                            petProfileImage,
                                                            data[index][
                                                                'pet_profile_id']);
                                                  },
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: primarySizedBox),
                              _buildDetailsCard(context, "Personal details"),
                              const SizedBox(height: primarySizedBox),
                              _buildAboutCard(context, "More information"),
                              const SizedBox(height: quaternarySizedBox),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: tertiarySizedBox),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, slideUpRoute(const AddPetProfileScreen()));
        },
        child: const ClipOval(
          child: Material(
            color: lighterSecondaryColor, // Button color
            child: SizedBox(
                width: 45, child: Icon(Icons.add, color: primaryColor)),
          ),
        ),
      ),
    );
  }

  Widget _buildPetProfile(String? imageUrl, String index) {
    return Container(
      padding: const EdgeInsets.only(
          left: secondarySizedBox,
          right: primarySizedBox,
          bottom: tertiarySizedBox),
      child: GestureDetector(
        onTap: () {
          ref.read(selectedPetIdProvider.notifier).state = index;
          Navigator.push(
            context,
            slideUpRoute(const PetProfileScreen()),
          );
        },
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl:
                imageUrl!.isEmpty ? 'https://tinyurl.com/357z4usj' : imageUrl,
            height: 40,
            width: 45,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              // Shimmer effect while loading
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 40,
                  width: 45,
                  color: Colors.white,
                ),
              );
            },
            errorWidget: (context, url, error) {
              // Error placeholder
              return Container(
                height: 47,
                color: mediumGreyColor,
                child: Center(
                  child: const Text(
                    '!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: boldWeight),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, String title) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(width: .15, color: Colors.black)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              customTitleText(context, title),
            ]),
            const SizedBox(height: secondarySizedBox),
            SizedBox(
              height: 300,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, rightToLeftRoute(const EditName()));
                    },
                    child: _detailsCard(
                      context: context,
                      title: "Name",
                      details:
                          "${mapPetOwnerDetails?['first_name'] ?? ''} ${mapPetOwnerDetails?['last_name'] ?? ''}",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, rightToLeftRoute(const EditPhoneNumber()));
                    },
                    child: _detailsCard(
                      context: context,
                      title: "Phone number",
                      details: mapUserDetails?['phone_number'] ?? '',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, rightToLeftRoute(const EditAddress()));
                    },
                    child: _detailsCard(
                      context: context,
                      title: "Address",
                      details:
                          "${mapUserAddress?['floor_unit_room'] != '' ? '${mapUserAddress?['floor_unit_room']}, ' : ''}"
                          "${mapUserAddress?['street'] != '' ? '${mapUserAddress?['street']}, ' : ''}"
                          "${mapUserAddress?['barangay'] != '' ? '${mapUserAddress?['barangay']}, ' : ''}"
                          "${mapUserAddress?['city'] ?? ''}",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, String title) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(width: .15, color: Colors.black)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              customTitleText(context, title),
            ]),
            const SizedBox(height: secondarySizedBox),
            SizedBox(
              height: 70,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showAboutPage(
                        context: context,
                        values: {
                          'version': '1.0',
                          'year': DateTime.now().year.toString(),
                        },
                        applicationLegalese:
                            'Copyright © Pamfurred, {{ year }}',
                        applicationDescription: const Text(
                          'Furfection right at your fingertips.',
                        ),
                        children: const <Widget>[
                          LicensesPageListTile(
                            icon: Icon(Icons.favorite),
                          ),
                        ],
                        applicationIcon: const SizedBox(
                          width: 100,
                          height: 100,
                          child: Image(
                            image: AssetImage('assets/pamfurred_logo.png'),
                          ),
                        ),
                      );
                    },
                    child: _aboutCard(
                      context: context,
                      details: "About Pamfurred",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard({
    required BuildContext context,
    required String title,
    required String? details,
  }) {
    return Card(
      color: lightGreyColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 100,
                            height: 20,
                            color: Colors.grey,
                          ),
                        )
                      : customRegularWeightTitleText(context, title),
                  const SizedBox(height: 8),
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.grey,
                          ),
                        )
                      : wrappedText(context, details ?? '', greyColor),
                ],
              ),
            ),
            isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(Icons.arrow_forward_ios_outlined,
                    color: greyColor),
          ],
        ),
      ),
    );
  }

  Widget _aboutCard({
    required BuildContext context,
    required String? details,
  }) {
    return Card(
      color: lightGreyColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.grey,
                          ),
                        )
                      : wrappedText(context, details ?? '', greyColor),
                ],
              ),
            ),
            isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(Icons.arrow_forward_ios_outlined,
                    color: greyColor),
          ],
        ),
      ),
    );
  }

  Widget buildProfileSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: secondarySizedBox),
        isLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 200, // Adjust width as needed
                  height: 24, // Matches the approximate height of the text
                  color: Colors.grey,
                ),
              )
            : Text(
                title,
                style: const TextStyle(
                  fontSize: headerText,
                  fontWeight: mediumWeight,
                  color: primaryColor,
                ),
              ),
      ],
    );
  }
}
