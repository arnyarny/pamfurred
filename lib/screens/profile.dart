import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/pet_profile/pet_profile.dart';
import 'package:pamfurred/screens/pet_profile/add_pet_profile.dart';
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

      // TODO: Change database to use "user" table and store both the service_provider's and pet owner's table
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
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false; // Stop loading even on error
      });
      // Show a snackbar on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PullToRefresh(
          providersToRefresh: [
            petProfileProvider(userId),
          ],
          child: petProfileData.when(
            loading: () => const Center(
                child: CircularProgressIndicator()), // Show loading spinner
            error: (error, stackTrace) =>
                Center(child: Text('Error: $error')), // Show error message
            data: (data) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: primarySizedBox),
                  child: SizedBox(
                    width: screenPadding(context),
                    child: Column(
                      children: [
                        const SizedBox(height: tertiarySizedBox),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildProfileSectionHeader(
                              '${mapUserDetails?['first_name'] ?? ''} ${mapUserDetails?['last_name'] ?? ''}'
                                  .trim(),
                            ),
                            IconButton(
                              onPressed: () {
                                // Set visibility to false when loading
                                _logout();
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
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    customTitleText(context, "Pets"),
                                    data.isNotEmpty
                                        ? const Icon(Icons.edit,
                                            size: 20, color: primaryColor)
                                        : const SizedBox.shrink(),
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
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.pets,
                                                    size: 40,
                                                    color: primaryColor),
                                                const SizedBox(
                                                    height: secondarySizedBox),
                                                const Text("No pets yet! 🐾",
                                                    style: TextStyle(
                                                        fontSize: regularText,
                                                        color: darkGreyColor)),
                                                const SizedBox(
                                                    height: primarySizedBox),
                                                const Text(
                                                    "Add your first pet to get started!",
                                                    style: TextStyle(
                                                        fontSize: smallText,
                                                        color: darkGreyColor)),
                                                const SizedBox(
                                                    height: tertiarySizedBox),
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
                                                    height: tertiarySizedBox),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: data.length +
                                                1, // Add 1 for the Add button
                                            itemBuilder: (context, index) {
                                              final petProfileImage =
                                                  index < data.length
                                                      ? data[index]['pet_image']
                                                      // Temporary placeholder
                                                      : '';
                                              return index == data.length
                                                  ? _buildAddPetButton(context)
                                                  : _buildPetProfile(
                                                      petProfileImage,
                                                      data[index]
                                                          ['pet_profile_id']);
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
                        _buildAccountCard(context),
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
            imageUrl: imageUrl ??
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7nreJH6sPRQH2qk3IL_R4j0o1-amatTZn7Q&s',
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
              return const Icon(Icons.error);
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
              height: 275,
              child: Column(
                children: [
                  _detailsCard(
                    context: context,
                    title: "Name",
                    details:
                        "${mapUserDetails?['first_name'] ?? ''} ${mapUserDetails?['last_name'] ?? ''}",
                  ),
                  _detailsCard(
                    context: context,
                    title: "Phone number",
                    details: mapUserDetails?['phone_number'] ?? '',
                  ),
                  _detailsCard(
                    context: context,
                    title: "Address",
                    details:
                        "${mapUserAddress?['floor_unit_room'] != '' ? '${mapUserAddress?['floor_unit_room']}, ' : ''}"
                        "${mapUserAddress?['street'] != '' ? '${mapUserAddress?['street']}, ' : ''}"
                        "${mapUserAddress?['barangay'] != '' ? '${mapUserAddress?['barangay']}, ' : ''}"
                        "${mapUserAddress?['city'] ?? ''}",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
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
              customTitleText(context, "Credentials"),
            ]),
            const SizedBox(height: primarySizedBox),
            SizedBox(
              height: 155,
              child: Column(
                children: [
                  _detailsCard(
                    context: context,
                    title: "Email address",
                    details: mapPetOwnerDetails?['email'] ?? '',
                  ),
                  buildChangePasswordCard(),
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
    return InkWell(
      onTap: !isLoading && details != null && details.isNotEmpty
          ? () => _editDetails(context, title, details)
          : null,
      hoverColor: Colors.transparent,
      child: Card(
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
                        : Text(
                            details ?? '',
                            style: const TextStyle(
                              color: greyColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
      ),
    );
  }

  Future<void> _editDetails(
      BuildContext context, String field, String details) async {
    // Get the current session
    Session? userSession = Supabase.instance.client.auth.currentSession;

    if (userSession == null) {
      throw Exception("User not logged in");
    }

    if (field == "Name") {
      final newValues = await _showEditNameDialog(context, details);
      if (newValues != null) {
        await Supabase.instance.client.from('user').update({
          'first_name': newValues[0],
          'last_name': newValues[1],
        }).eq('user_id', userSession.user.id); // Use the session user ID
        _fetchUserData(); // Refresh user data
      }
    } else if (field == "Phone number") {
      final newPhone =
          await _showEditSingleFieldDialog(context, details, "Phone Number");
      if (newPhone != null) {
        await Supabase.instance.client
            .from('user')
            .update({'phone_number': newPhone}).eq(
                'user_id', userSession.user.id); // Use the session user ID
        _fetchUserData(); // Refresh user data
      }
    } else if (field == "Email address") {
      final newEmail =
          await _showEditSingleFieldDialog(context, details, "Email Address");
      if (newEmail != null) {
        await Supabase.instance.client
            .from('pet_owner')
            .update({'email': newEmail}).eq(
                'user_id', userSession.user.id); // Use the session user ID
        _fetchUserData(); // Refresh user data
      }
    } else if (field == "Address") {
      final newAddressValues = await _showEditAddressDialog(context);
      final userId = userSession.user.id; // Get user ID from session
      final userDetails = await Supabase.instance.client
          .from('user')
          .select()
          .eq('user_id', userId) // Query based on the current user's ID
          .single();

      final String addressId = userDetails['address_id'];
      if (newAddressValues != null) {
        await Supabase.instance.client
            .from('address') // Assuming you have an address table
            .update({
          'floor_unit_room': newAddressValues[0] ?? '',
          'street': newAddressValues[1] ?? '',
          'barangay': newAddressValues[2] ?? '',
          'city': newAddressValues[3] ?? '',
        }).eq('address_id', addressId); // Use the session user ID
        _fetchUserData(); // Refresh user data
      }
    }
  }

  Future<List<String?>?> _showEditNameDialog(
      BuildContext context, String currentValue) {
    TextEditingController firstNameController =
        TextEditingController(text: currentValue.split(" ")[0]);
    TextEditingController lastNameController = TextEditingController(
        text: currentValue.split(" ").length > 1
            ? currentValue.split(" ")[1]
            : '');

    return showDialog<List<String?>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "First Name")),
              TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Last Name")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pop([firstNameController.text, lastNameController.text]),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showEditSingleFieldDialog(
      BuildContext context, String currentValue, String title) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String?>?> _showEditAddressDialog(BuildContext context) {
    TextEditingController floorUnitRoomController =
        TextEditingController(text: mapUserAddress?['floor_unit_room'] ?? '');
    TextEditingController streetController =
        TextEditingController(text: mapUserAddress?['street'] ?? '');
    TextEditingController barangayController =
        TextEditingController(text: mapUserAddress?['barangay'] ?? '');
    TextEditingController cityController =
        TextEditingController(text: mapUserAddress?['city'] ?? '');

    return showDialog<List<String?>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: floorUnitRoomController,
                  decoration:
                      const InputDecoration(labelText: "Floor/Unit/Room")),
              TextField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: "Street")),
              TextField(
                  controller: barangayController,
                  decoration: const InputDecoration(labelText: "Barangay")),
              TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(context).pop([
                floorUnitRoomController.text,
                streetController.text,
                barangayController.text,
                cityController.text
              ]),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget buildChangePasswordCard() {
    return InkWell(
      onTap: isLoading ? null : () => (),
      child: Card(
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
                              width: 150,
                              height: 20,
                              color: Colors.grey,
                            ),
                          )
                        : const Text(
                            'Change password',
                            style: TextStyle(fontSize: 16),
                          ),
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
