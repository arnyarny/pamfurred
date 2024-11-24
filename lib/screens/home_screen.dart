import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/error_builder.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/rating_widget.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:pamfurred/backend_logic_files/store_location.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/screens/location_permission.dart';
import 'package:pamfurred/screens/main_screen.dart';
import 'package:pamfurred/screens/search_results.dart';
import 'package:pamfurred/screens/appointment/serviceprovider_profile.dart';
import 'package:pamfurred/screens/service_providers.dart';
import 'package:shimmer/shimmer.dart';

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
    LocationService locationService = LocationService();
    locationService.determinePosition(context).then((position) {
      storeLocation(position.latitude, position.longitude, ref);
    }).catchError((error) {
      // Handle errors appropriately
      print(error);
    });
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

    return PopScope(
      canPop: false,
      child: SafeArea(
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
              providersToRefresh: [
                appointmentDetailsProvider,
                selectedCategoryIndexProvider,
                serviceProviderFutureProvider('pet grooming'),
                serviceProviderFutureProvider('pet boarding'),
                serviceProviderFutureProvider('veterinary service'),
              ],
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const SizedBox(height: secondarySizedBox),
                        SizedBox(
                            width: screenPadding(context),
                            child: _sectionHeader(
                                context, "Upcoming appointments")),
                        const SizedBox(height: primarySizedBox),
                        SizedBox(
                            width: screenPadding(context),
                            child: _upcomingAppointmentCard()),
                        const SizedBox(height: primarySizedBox),
                        _viewAppointmentsButton(),
                        const SizedBox(height: primarySizedBox),
                        SizedBox(
                            width: screenPadding(context),
                            child: _sectionHeader(context, "I'm looking for")),
                        const SizedBox(height: primarySizedBox),
                        _serviceSelection(context),
                        const SizedBox(height: primarySizedBox),
                        _submitButton(),
                        const SizedBox(height: primarySizedBox),
                        _getRecos(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Row(children: [customTitleText(context, title)]);
  }

  final appointmentDetailsProvider =
      FutureProvider<Map<String, dynamic>>((ref) async {
    final userId = ref.watch(userIdProvider).toString();
    return await fetchAppointmentDetails(userId);
  });

  Widget _upcomingAppointmentCard() {
    final appointmentDetails = ref.watch(appointmentDetailsProvider);
    return appointmentDetails.when(
        data: (data) {
          // Extract the list of appointments from the returned map
          final appointments =
              data['appointments'] as List<Map<String, dynamic>>;

          // Filter appointments to show only those with 'appointment_status' of 'Upcoming'
          final upcomingAppointments = appointments.where((appointment) {
            return appointment['appointment_status'] == 'Upcoming';
          }).toList();

          return upcomingAppointments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: secondarySizedBox),
                      Icon(Icons.event_busy, size: 40, color: primaryColor),
                      SizedBox(height: secondarySizedBox),
                      Text(
                        "No upcoming appointments yet!",
                        style: TextStyle(
                            fontSize: regularText, color: darkGreyColor),
                      ),
                      SizedBox(height: primarySizedBox),
                      Text(
                        "Browse service providers to book an appointment.",
                        style: TextStyle(fontSize: smallText, color: greyColor),
                      ),
                      SizedBox(height: primarySizedBox),
                    ],
                  ),
                )
              : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(secondaryBorderRadius),
                  ),
                  elevation: 1.5,
                  color: lighterSecondaryColor,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 115,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                    ),
                    items: upcomingAppointments.map((appointment) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: double.infinity,
                            height: 95,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  tertiarySizedBox,
                                  tertiarySizedBox,
                                  tertiarySizedBox,
                                  0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capitalizeFirstLetter(
                                        appointment['establishment_name']),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: regularText,
                                        fontWeight: boldWeight),
                                  ),
                                  const SizedBox(height: secondarySizedBox),
                                  Text(
                                      secondaryFormatDate(
                                          appointment['appointment_date'] ??
                                              'N/A'),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: regularText,
                                      )),
                                  const SizedBox(height: secondarySizedBox),
                                  Text(
                                    appointment['appointment_time'] == null
                                        ? 'N/A'
                                        : formatTime(
                                            appointment['appointment_time']),
                                    style: const TextStyle(
                                      color: darkGreyColor,
                                      fontSize: smallText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                );
        },
        loading: () => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: List.generate(1, (index) => shimmerPlaceholder())
                      .toList(),
                ),
              ),
            ),
        error: (error, _) {
          print(error);
          return const ErrorMessage();
        });
  }

  Widget shimmerPlaceholder() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(secondaryBorderRadius),
      ),
      child: Container(
        width: double.infinity,
        height: 115,
        padding: const EdgeInsets.fromLTRB(
            tertiarySizedBox, tertiarySizedBox, tertiarySizedBox, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 15,
              color: Colors.white,
            ),
            const SizedBox(height: secondarySizedBox),
            Container(
              width: 100,
              height: 15,
              color: Colors.white,
            ),
            const SizedBox(height: secondarySizedBox),
            Container(
              width: 70,
              height: 15,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewAppointmentsButton() {
    final appointmentDetails = ref.watch(appointmentDetailsProvider);
    return appointmentDetails.when(
        data: (data) {
          // Extract the list of appointments from the returned map
          final appointments =
              data['appointments'] as List<Map<String, dynamic>>;

          // Filter appointments to show only those with 'appointment_status' of 'Upcoming'
          final upcomingAppointments = appointments.where((appointment) {
            return appointment['appointment_status'] == 'Upcoming';
          }).toList();

          return upcomingAppointments.isEmpty
              ? const SizedBox.shrink()
              : customPaddedTextButton(
                  text: "View appointments",
                  onPressed: () {
                    mainScreenKey.currentState
                        ?.switchToPage(1); // Switch to Appointments page
                  },
                );
        },
        loading: () => const Center(child: SizedBox()),
        error: (error, _) {
          print(error);
          return const ErrorMessage();
        });
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
      onTap: () {
        onItemTap(index);
        ref.read(selectedCategoryIndexProvider.notifier).state = index;
      },
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
        SizedBox(
          width: screenPadding(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(context, header),
              GestureDetector(
                onTap: () {
                  ref
                      .read(selectedHomeScreenSpCategoryProvider.notifier)
                      .state = category;
                  Navigator.push(
                      context, slideUpRoute(const ServiceProvidersScreen()));
                },
                child: const Text('View more',
                    style: TextStyle(fontSize: smallText, color: primaryColor)),
              )
            ],
          ),
        ),
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
        loading: () => SizedBox(
              height: 225,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Display a few shimmer placeholders
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: secondarySizedBox),
                    child: SizedBox(
                      width: 250,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image placeholder
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      primaryBorderRadius),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:
                                    8.0), // Adjusted spacing for better alignment

                            // Service provider name shimmer
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                width: 120,
                                height: 15.0,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            // Row for rating, sentiment label, and distance
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Rating shimmer
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 50,
                                      height: 15.0,
                                      color: Colors.white,
                                    ),
                                  ),

                                  // Sentiment label shimmer
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 60,
                                      height: 15.0,
                                      color: Colors.white,
                                    ),
                                  ),

                                  // Distance shimmer
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.location,
                                          color: Colors.grey[400]!,
                                          size: 19,
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          width: 40,
                                          height: 15.0,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        error: (error, _) {
          print(error);
          return const ErrorMessage();
        },
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
              padding: const EdgeInsets.symmetric(horizontal: tertiarySizedBox),
              scrollDirection: Axis.horizontal,
              itemCount:
                  serviceProviders.length > 10 ? 10 : serviceProviders.length,
              itemBuilder: (context, index) {
                final sp = serviceProviders[index];

                final imageUrl = sp['service_provider_image'] ??
                    'https://tinyurl.com/3tnt6yyy'; // Default image if null
                final name = capitalizeFirstLetter(sp['service_provider_name']);
                final rating =
                    (sp['average_rating'] as double).toStringAsFixed(1);

                final spLatitude = sp['latitude'];
                final spLongitude = sp['longitude'];
                double latitude = double.tryParse(spLatitude.toString()) ?? 0.0;
                double longitude =
                    double.tryParse(spLongitude.toString()) ?? 0.0;
                final sentimentLabel = sp['sentiment_label'];

                String userId = ref.watch(userIdProvider).toString();
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: primarySizedBox),
                  child: GestureDetector(
                    onTap: () {
                      final spId = sp['sp_id']?.toString() ?? '';

                      if (spId.isEmpty) {
                        print('Error: Service Provider ID is missing.');
                        return;
                      }

                      // Only pass spId here
                      final serviceFilterCriteria =
                          ServiceFilterCriteria(spId: spId);
                      ref.watch(allServicesProvider(serviceFilterCriteria));

                      final packageFilterCriteria =
                          PackageFilterCriteria(spId: spId);
                      ref.watch(allPackagesProvider(packageFilterCriteria));

                      ref.read(selectedSpIndexProvider.notifier).state = spId;
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
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: double.infinity,
                                        height: 150,
                                        fit: sp['image'] == null
                                            ? BoxFit.fitWidth
                                            : BoxFit.contain,
                                        placeholder:
                                            (BuildContext context, String url) {
                                          // Shimmer effect while loading
                                          return SizedBox(
                                            height: 150,
                                            width: double.infinity,
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey[
                                                  300]!, // Shimmer base color
                                              highlightColor: Colors.grey[
                                                  100]!, // Shimmer highlight color
                                              child: Container(
                                                color: Colors
                                                    .white, // Placeholder color for shimmer effect
                                              ),
                                            ),
                                          );
                                        },
                                        errorWidget: (BuildContext context,
                                            String url, dynamic error) {
                                          // Error placeholder
                                          return const SizedBox(
                                            width: double.infinity,
                                            height: 150,
                                            child: Center(
                                              child: Icon(Icons.error),
                                            ),
                                          );
                                        },
                                        fadeInDuration:
                                            const Duration(milliseconds: 500),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 1000),
                                        alignment: Alignment.center,
                                        placeholderFadeInDuration:
                                            const Duration(milliseconds: 200),
                                      )),
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
                                    FutureBuilder<String?>(
                                      future: getDistanceToTarget(
                                          userId, latitude, longitude),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return SizedBox(
                                            width: 85,
                                            height: 20,
                                            child: Text(
                                                'Error: ${snapshot.error}',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ); // Display error message if there's an error
                                        } else if (snapshot.hasData) {
                                          // Check if the data is not null
                                          return Row(
                                            children: [
                                              const Icon(
                                                  CupertinoIcons.location,
                                                  size: 19),
                                              SizedBox(
                                                width: snapshot.data == 'Nearby'
                                                    ? 50
                                                    : 85,
                                                height: 20,
                                                child: Text(
                                                    snapshot.data ??
                                                        'Distance not available',
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ); // Display the calculated distance
                                        } else {
                                          return const SizedBox(
                                            width: 85,
                                            height: 20,
                                            child: Text('',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ); // Handle the case where there is no data
                                        }
                                      },
                                    ),
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
