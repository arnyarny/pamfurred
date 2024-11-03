import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/header.dart';
// import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
import 'package:pamfurred/screens/login.dart';
import 'package:pamfurred/screens/pet_profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? profileData; // Store user data
  Map<String, dynamic>? mapUserDetails; // Store user data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the screen initializes
  }

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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

      final username = await Supabase.instance.client
          .from('pet_owner')
          .select()
          .eq('user_id', userId) // Query based on the current user's ID
          .single();

      final userDetails = await Supabase.instance.client
          .from('user')
          .select()
          .eq('user_id', userId) // Query based on the current user's ID
          .single();

      setState(() {
        profileData = username;
        mapUserDetails = userDetails;
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
    // Access the list of pet profiles
    final petProfileData = ref.watch(petProfileProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading spinner
            :
            // Remove this comment when backend is implemented in this screen
            // PullToRefresh(
            SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: screenPadding(context),
                    child: Column(children: [
                      const SizedBox(height: tertiarySizedBox),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildSectionHeader(profileData?['username'] ?? ''),
                          IconButton(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            iconSize: 25,
                            color: greyColor,
                          )
                        ],
                      ),
                      const SizedBox(height: primarySizedBox),
                      Card(
                        color: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                                width: .15, color: Colors.black)),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  customTitleText(context, "Pets"),
                                  const Icon(Icons.edit,
                                      size: 20, color: primaryColor)
                                ],
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: tertiarySizedBox,
                                    right: tertiarySizedBox),
                                child: SizedBox(
                                    height: 60,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: petProfileData.length +
                                          1, // Add 1 for the Add button
                                      itemBuilder: (context, index) {
                                        // Logic for pet profiles and "Add" button
                                        final petProfileImage = index <
                                                petProfileData.length
                                            ? petProfileData[index]['image'] ??
                                                ''
                                            : '';
                                        return index == petProfileData.length
                                            ? _buildAddPetButton(context)
                                            : _buildPetProfile(
                                                petProfileImage, index);
                                      },
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: primarySizedBox),
                      _buildDetailsCard(context, "Personal details"),
                      const SizedBox(height: primarySizedBox),
                      _buildAccountCard(context),
                    ]),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: tertiarySizedBox),
      child: const ClipOval(
        child: Material(
          color: lighterSecondaryColor, // Button color
          child:
              SizedBox(width: 45, child: Icon(Icons.add, color: primaryColor)),
        ),
      ),
    );
  }

  Widget _buildPetProfile(String imageUrl, int index) {
    return Container(
      padding: const EdgeInsets.only(
          left: secondarySizedBox,
          right: primarySizedBox,
          bottom: tertiarySizedBox),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            slideUpRoute(PetProfileScreen(petId: index + 1)),
          );
        },
        child: ClipOval(
          child: Image.network(
            imageUrl,
            height: 40,
            width: 45,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              return loadingProgress == null
                  ? child
                  : Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child:
                          Container(height: 40, width: 45, color: Colors.white),
                    );
            },
            errorBuilder: (context, error, stackTrace) {
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
              height: 364,
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
                    title: "Email address",
                    details:
                        Supabase.instance.client.auth.currentUser?.email ?? '',
                  ),
                  _detailsCard(
                    context: context,
                    title: "Address",
                    details:
                        "${mapUserDetails?['door_no'] ?? ''}, ${mapUserDetails?['street'] ?? ''}, ${mapUserDetails?['barangay'] ?? ''}, ${mapUserDetails?['city'] ?? ''}",
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
              customTitleText(context, "Account"),
            ]),
            const SizedBox(height: primarySizedBox),
            SizedBox(
              height: 155,
              child: Column(
                children: [
                  _detailsCard(
                    context: context,
                    title: "Username",
                    details: profileData?['username'] ?? '',
                  ),
                  const InkWell(
                    child: Card(
                      color: lightGreyColor,
                      elevation: 0,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Change password',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_outlined,
                                color: greyColor),
                          ],
                        ),
                      ),
                    ),
                  )
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
      onTap: details != null && details.isNotEmpty
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
                    customRegularWeightTitleText(context, title),
                    const SizedBox(height: 8),
                    Text(details ?? '',
                        style: const TextStyle(color: greyColor)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_outlined, color: greyColor),
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
            .from('user')
            .update({'email_address': newEmail}).eq(
                'user_id', userSession.user.id); // Use the session user ID
        _fetchUserData(); // Refresh user data
      }
    } else if (field == "Username") {
      final newUsername =
          await _showEditSingleFieldDialog(context, details, "Username");
      if (newUsername != null) {
        await Supabase.instance.client
            .from('pet_owner')
            .update({'username': newUsername}).eq(
                'user_id', userSession.user.id); // Use the session user ID
        _fetchUserData(); // Refresh user data
      }
    } else if (field == "Address") {
      final newAddressValues = await _showEditAddressDialog(context);
      if (newAddressValues != null) {
        await Supabase.instance.client
            .from('address') // Assuming you have an address table
            .update({
          'street': newAddressValues[0],
          'barangay': newAddressValues[1],
          'city': newAddressValues[2],
        }).eq('user_id', userSession.user.id); // Use the session user ID
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
    TextEditingController streetController =
        TextEditingController(text: profileData?['street'] ?? '');
    TextEditingController barangayController =
        TextEditingController(text: profileData?['barangay'] ?? '');
    TextEditingController cityController =
        TextEditingController(text: profileData?['city'] ?? '');

    return showDialog<List<String?>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
}
