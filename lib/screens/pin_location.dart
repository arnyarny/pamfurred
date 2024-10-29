import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PinAddress extends ConsumerStatefulWidget {
  const PinAddress({super.key});

  @override
  ConsumerState<PinAddress> createState() => PinAddressState();
}

class PinAddressState extends ConsumerState<PinAddress>
    with SingleTickerProviderStateMixin {
  String locationMessage = '';
  bool isLoading = true;
  LatLng? pinnedLocation;
  String? province;
  String? streetAddress;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    getLocation();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation =
        Tween<double>(begin: 0.9, end: 1.0).animate(animationController);
  }

  Future<void> getLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        ref.read(latProvider.notifier).state = position.latitude;
        ref.read(longProvider.notifier).state = position.longitude;
        ref.read(hasDetectedAddressProvider.notifier).state = true;
        isLoading = false;
      });
    } else {
      setState(() {
        locationMessage = status.isDenied
            ? 'Location permission denied'
            : 'Location permission permanently denied. Open settings to allow permission.';
        openAppSettings();
        isLoading = false;
      });
    }
  }

  void onTap(LatLng tappedPoint) async {
    setState(() {
      pinnedLocation = tappedPoint;
      ref.read(latProvider.notifier).state = tappedPoint.latitude;
      ref.read(longProvider.notifier).state = tappedPoint.longitude;
      ref.read(hasDetectedAddressProvider.notifier).state = true;
      locationMessage =
          'Pinned Location: Latitude: ${tappedPoint.latitude}, Longitude: ${tappedPoint.longitude}';
      animationController.forward(from: 0.0); // Reset animation
    });
    await fetchAddress(tappedPoint);
  }

  Future<void> fetchAddress(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        ref.read(latProvider.notifier).state = location.latitude,
        ref.read(longProvider.notifier).state = location.longitude,
      );
      ref.read(cityProvider.notifier).state = placemarks[0].locality ?? '';
      ref.read(provinceProvider.notifier).state =
          placemarks[0].administrativeArea ?? '';
      ref.read(streetProvider.notifier).state = placemarks[0].street ?? '';
    } catch (e) {
      ("Error retrieving address: $e");
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final latitude = ref.watch(latProvider);
    final longitude = ref.watch(longProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pin Address"),
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              // Custom action on back button press
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: primaryColor),
            onPressed: () async {
              fetchAddress(LatLng(latitude, longitude));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : latitude != 0.0 && longitude != 0.0
              ? FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude, longitude),
                    initialZoom: 13.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, point) => onTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    if (pinnedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                              point: pinnedLocation!,
                              child: ScaleTransition(
                                scale: animation,
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  size: 40,
                                  color: primaryColor,
                                ),
                              )),
                        ],
                      ),
                  ],
                )
              : Center(child: Text(locationMessage)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: getLocation,
        child: const Icon(
          Icons.location_searching,
          color: Colors.white,
        ),
      ),
    );
  }
}
