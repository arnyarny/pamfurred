import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/error_builder.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/pull_to_refresh.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/sentiment_label.dart';
import 'package:pamfurred/math_functions/distance_calculator.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/service_filter_criteria.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/sp_profile_provider_packages.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/screens/appointment/serviceprovider_profile.dart';
import 'package:pamfurred/screens/home_screen.dart';
import 'package:shimmer/shimmer.dart';

class ServiceProvidersScreen extends ConsumerStatefulWidget {
  const ServiceProvidersScreen({super.key});

  @override
  ConsumerState<ServiceProvidersScreen> createState() =>
      _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState
    extends ConsumerState<ServiceProvidersScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedHomeScreenSpCategory =
        ref.watch(selectedHomeScreenSpCategoryProvider);
    return Scaffold(
      appBar: customAppBarWithTitle(
        context,
        selectedHomeScreenSpCategory == "veterinary service"
            ? "${capitalizeFirstLetter(selectedHomeScreenSpCategory)} providers"
            : "${capitalizeFirstLetter(selectedHomeScreenSpCategory)} service providers",
      ),
      backgroundColor: Colors.white,
      body: ServiceProvidersGridViewWidget(
        serviceCategory: selectedHomeScreenSpCategory,
      ),
    );
  }
}

class ServiceProvidersGridViewWidget extends ConsumerWidget {
  final String serviceCategory;

  const ServiceProvidersGridViewWidget(
      {super.key, required this.serviceCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerData =
        ref.watch(serviceProviderFutureProvider(serviceCategory));

    return providerData.when(
        loading: () => PullToRefresh(
          providersToRefresh: [
            serviceProviderFutureProvider(serviceCategory)
          ],
          child: MasonryGridView.builder(
            gridDelegate:
                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            mainAxisSpacing: primarySizedBox,
            crossAxisSpacing: primarySizedBox,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: secondarySizedBox),
                child: SizedBox(
                  width: double.infinity,
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
                        const SizedBox(height: 8.0),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 50,
                                  height: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 60,
                                  height: 15.0,
                                  color: Colors.white,
                                ),
                              ),
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

          return PullToRefresh(
            providersToRefresh: [
              serviceProviderFutureProvider(serviceCategory)
            ],
            child: MasonryGridView.builder(
              gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              // This causes the UI to stretch which we don't want
              mainAxisSpacing: primarySizedBox,
              crossAxisSpacing: primarySizedBox,
              itemCount:
                  serviceProviders.length > 10 ? 10 : serviceProviders.length,
              itemBuilder: (context, index) {
                final sp = serviceProviders[index];
                final imageUrl = sp['service_provider_image'] ??
                    'https://tinyurl.com/3tnt6yyy';
                final name =
                    capitalizeFirstLetter(sp['service_provider_name']);
                final rating =
                    (sp['average_rating'] as double).toStringAsFixed(1);
          
                final spLatitude = sp['latitude'];
                final spLongitude = sp['longitude'];
                double latitude =
                    double.tryParse(spLatitude.toString()) ?? 0.0;
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
                      width: double.infinity,
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
                                          ? BoxFit.cover
                                          : BoxFit.contain,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return SizedBox(
                                            height: 150,
                                            width: double.infinity,
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor:
                                                  Colors.grey[100]!,
                                              child: Container(
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return const SizedBox(
                                          width: double.infinity,
                                          height: 150,
                                          child: Center(
                                              child: Icon(Icons.error)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: secondarySizedBox),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: serviceProviderName(name),
                                ),
                              ],
                            ),
                            const SizedBox(height: secondarySizedBox),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 45,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 19, color: secondaryColor),
                                      Text(rating),
                                    ],
                                  ),
                                ),
                                sentimentLabelTextWidget(sentimentLabel),
                              ],
                            ),
                            const SizedBox(height: secondarySizedBox),
                            FutureBuilder<String?>(
                              future: getDistanceToTarget(
                                  userId, latitude, longitude),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return SizedBox(
                                    width: 85,
                                    height: 20,
                                    child: Text('Error: ${snapshot.error}',
                                        overflow: TextOverflow.ellipsis),
                                  );
                                } else if (snapshot.hasData) {
                                  return Row(
                                    children: [
                                      const Icon(CupertinoIcons.location,
                                          size: 19),
                                      SizedBox(
                                        width: snapshot.data == 'Nearby'
                                            ? 50
                                            : 85,
                                        height: 20,
                                        child: Text(
                                            snapshot.data ??
                                                'Distance not available',
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox(
                                    width: 85,
                                    height: 20,
                                    child: Text('',
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }
                              },
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
