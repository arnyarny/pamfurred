import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
// import 'package:pamfurred/providers/serviceprovider_provider.dart';
// import 'package:pamfurred/screens/profile.dart';
import 'package:pamfurred/screens/search_results.dart';
import 'package:pamfurred/screens/serviceprovider_profile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  bool isSelected = false;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final visibilityNotifier = ref.read(visibilityProvider.notifier);
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      visibilityNotifier.setVisible(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      visibilityNotifier.setVisible(true);
    }
  }

  void onItemTap(int index) {
    setState(() {
      selectedIndex = index;
      isSelected = !isSelected;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    const imageAssets = [
      'assets/vet_service.png',
      'assets/pet_grooming.png',
      'assets/pet_boarding.png',
      'assets/pamfurred_logo.png',
    ];
    for (var image in imageAssets) {
      precacheImage(AssetImage(image), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(visibilityProvider);
    const appBarHeight = 60.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        // Smooth height animation for AppBar visibility
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(appBarHeight),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isVisible ? appBarHeight : 0,
            curve: Curves.easeInOut,
            child: isVisible ? appBar(context) : null,
          ),
        ),

        // Body with scroll controller for detecting scroll direction
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is UserScrollNotification) {
              // Show or hide based on scroll direction
              if (scrollNotification.direction == ScrollDirection.reverse) {
                ref.read(visibilityProvider.notifier).setVisible(false);
              } else if (scrollNotification.direction ==
                  ScrollDirection.forward) {
                ref.read(visibilityProvider.notifier).setVisible(true);
              }
            }
            return true;
          },
          child: PullToRefresh(
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: screenPadding(context),
                    child: Column(
                      children: [
                        const SizedBox(height: secondarySizedBox),
                        _sectionHeader(context, "Upcoming appointments"),
                        const SizedBox(height: primarySizedBox),
                        _upcomingAppointmentCard(),
                        const SizedBox(height: primarySizedBox),
                        _viewAppointmentsButton(),
                        const SizedBox(height: primarySizedBox),
                        _sectionHeader(context, "I'm looking for"),
                        const SizedBox(height: primarySizedBox),
                        _serviceSelection(context),
                        const SizedBox(height: primarySizedBox),
                        _submitButton(),
                        const SizedBox(height: primarySizedBox),
                        _getRecos(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Row(children: [customTitleText(context, title)]);
  }

  Widget _upcomingAppointmentCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(secondaryBorderRadius),
      ),
      elevation: 1.5,
      color: lighterSecondaryColor,
      child: const SizedBox(
        width: double.infinity,
        height: 85,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'January 2, 2024, 9 am',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: regularText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: primarySizedBox),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Paws and Claws Pet Station',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: regularText,
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

  Widget _viewAppointmentsButton() {
    return customPaddedTextButton(
      text: "View appointments",
      onPressed: () {},
    );
  }

  Widget _serviceSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _serviceCard(
            context, 0, 'Veterinary service', 'assets/vet_service.png'),
        const SizedBox(width: primarySizedBox),
        Column(
          children: [
            _serviceCard(context, 1, 'Pet grooming', 'assets/pet_grooming.png',
                height: 171),
            const SizedBox(height: primarySizedBox),
            _serviceCard(context, 2, 'Pet boarding', 'assets/pet_boarding.png',
                height: 171.5),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard(
      BuildContext context, int index, String title, String assetImage,
      {double height = 350}) {
    return GestureDetector(
      onTap: () => onItemTap(index),
      child: Stack(
        children: [
          SizedBox(
            height: height,
            width: MediaQuery.of(context).size.width / 2 - 25,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(secondaryBorderRadius),
                ),
                key: ValueKey<int>(selectedIndex),
                elevation: 1.5,
                color: selectedIndex == index ? primaryColor : lightGreyColor,
                child: Stack(
                  children: [
                    Positioned(
                      top: 32,
                      left: 16,
                      width: 100,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: regularText,
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: -50,
                      child: Image.asset(
                        assetImage,
                        width: 230,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selectedIndex == index) _selectedServiceCategory(),
        ],
      ),
    );
  }

  Widget _selectedServiceCategory() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0.1,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Colors.white,
          size: 30.0,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          child: customPaddedTextButton(
              text: "Submit",
              onPressed: () {
                ref.read(selectedCategoryIndexProvider.notifier).state =
                    selectedIndex;
                Navigator.push(
                    context, crossFadeRoute(const SearchResultsScreen()));
              }),
        ),
      ],
    );
  }

  Widget _getRecos() {
    return Column(
      children: [
        const SizedBox(height: primarySizedBox),
        _recoSection("Pet grooming service providers", "pet grooming"),
        _recoSection("Pet boarding service providers", "pet boarding"),
        _recoSection("Veterinary service providers", "veterinary service"),
      ],
    );
  }

  Widget _recoSection(String header, String category) {
    return Column(
      children: [
        _sectionHeader(context, header),
        const SizedBox(height: secondarySizedBox),
        ServiceProvidersWidget(serviceCategory: category),
        const SizedBox(height: tertiarySizedBox),
      ],
    );
  }
}

class ServiceProvidersWidget extends ConsumerWidget {
  final String serviceCategory;

  const ServiceProvidersWidget({super.key, required this.serviceCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerData =
        ref.watch(serviceProviderFutureProvider(serviceCategory));

    return providerData.when(
        loading: () => const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (error, _) => SelectableText('Error: $error'),
        data: (serviceProviders) {
          if (serviceProviders.isEmpty) {
            return const SizedBox(
              height: 150,
              child: Center(child: Text('No service providers found')),
            );
          }

          return SizedBox(
            height: 225,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount:
                  serviceProviders.length > 10 ? 10 : serviceProviders.length,
              itemBuilder: (context, index) {
                final sp = serviceProviders[index];
                final id = sp['sp_id'];

                // Accessing fields based on your data structure
                final imageUrl = sp['image'] ??
                    'https://tinyurl.com/3tnt6yyy'; // Default image if null
                final name = sp['name'] ?? 'Unknown'; // Default name if null
                final rating =
                    sp['rating'].toString(); // Default rating if null
                final latitude = sp['latitude'] ?? 0.0; // Default latitude
                final longitude = sp['longitude'] ?? 0.0; // Default longitude
                final sentimentLabel = sp['sentiment_label'];

                print(imageUrl);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: primarySizedBox),
                  child: GestureDetector(
                    onTap: () {
                      print('Service Provider ID: $id');
                      ref.watch(allServicesProvider(sp['sp_id']));
                      ref.watch(allPackagesProvider(sp['sp_id']));
                      ref.read(selectedSpIndexProvider.notifier).state =
                          sp['sp_id'];
                      Navigator.push(context,
                          slideUpRoute(const ServiceproviderProfileScreen()));
                    },
                    child: SizedBox(
                      width: 250,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                        ),
                        elevation: 0,
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Positioned(
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: lightGreyColor,
                                      borderRadius: BorderRadius.circular(
                                          primaryBorderRadius),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        primaryBorderRadius),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: 150,
                                      fit: sp['image'] == null
                                          ? BoxFit.contain
                                          : BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const SizedBox(
                                            height: 150,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          );
                                        }
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return const SizedBox(
                                          width: double.infinity,
                                          height: 150,
                                          child:
                                              Center(child: Icon(Icons.error)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: secondarySizedBox),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: serviceProviderName(name),
                                ),
                                sentimentLabelTextWidget(
                                    sentimentLabel), // Ensure sentimentLabel exists
                              ],
                            ),
                            const SizedBox(height: secondarySizedBox),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ratingWidget(rating),
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.location,
                                        size: 19),
                                    Text(
                                        calculateDistance(latitude, longitude)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

Widget serviceProviderName(String name) {
  return Row(
    children: [
      Expanded(
        child: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
