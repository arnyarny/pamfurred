import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/capitalize_first_letter.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/screens/appointment/choose_date_and_time.dart';
import 'package:pamfurred/screens/appointment/select_address.dart';
// import 'package:pamfurred/screens/select_address.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool showCoupon = true;

  @override
  Widget build(BuildContext context) {
    // Watch cart products and total price from the providers
    final cartProducts = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);

    // Separate services and packages from the cart
    final services = cartProducts.whereType<Service>().toList();
    final packages = cartProducts.whereType<Package>().toList();

    const double buttonHeight = 50;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBarWithTitle(
        context,
        "Your Cart",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          width: double.infinity,
          height: 124,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(secondaryBorderRadius),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Row: Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: boldWeight,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '₱$total',
                    style: const TextStyle(
                      fontSize: titleFont,
                      fontWeight: boldWeight,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: secondarySizedBox),

              // Second Row: Order Now button
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(secondaryBorderRadius),
                    ),
                  ),
                  onPressed: cartProducts.isEmpty
                      ? null
                      : () {
                          if (ref.watch(
                                  selectedAppointmentPackageServiceTypeProvider) ==
                              'Home Service') {
                            Navigator.push(
                                context,
                                slideUpRoute(
                                    const SelectAppointmentAddressScreen()));
                          } else {
                            Navigator.push(context,
                                slideUpRoute(const ChooseDateAndTimeScreen()));
                          }
                        },
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: regularText,
                      fontWeight: regularWeight,
                      color: cartProducts.isEmpty
                          ? disabledButtonTextColor
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 150),
        child: cartProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/empty_cart.png', width: 250),
                    const SizedBox(height: 20),
                    const Text(
                      'Your cart is empty. Pick some services or packages now!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: regularText,
                        color: darkGreyColor,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                          label: const Text('Clear Cart'),
                          onPressed: () {
                            ref.read(cartNotifierProvider.notifier).clearCart();
                          },
                          icon: const Icon(
                            Icons.delete,
                          ))
                    ],
                  ),
                  // Services Section
                  if (services.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: primarySizedBox),
                      child: Text(
                        'Services',
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: boldWeight,
                        ),
                      ),
                    ),
                  if (services.isNotEmpty)
                    ...services.map((service) => _buildCartItem(service)),

                  // Packages Section
                  if (packages.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: primarySizedBox),
                      child: Text(
                        'Packages',
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: boldWeight,
                        ),
                      ),
                    ),
                  if (packages.isNotEmpty)
                    ...packages.map((package) => _buildCartItem(package)),
                ],
              ),
      ),
    );
  }

  Widget _buildCartItem(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(primaryBorderRadius),
            child: CachedNetworkImage(
              imageUrl: item.image,
              width: 90,
              height: 85,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                // Shimmer effect while loading
                return Shimmer.fromColors(
                  baseColor: lightGreyColor,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 90,
                    height: 85,
                    color: lightGreyColor,
                  ),
                );
              },
              errorWidget: (context, url, error) {
                // Error widget
                return Container(
                  width: 90,
                  height: 85,
                  color: lightGreyColor,
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              capitalizeFirstLetter(item.name),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            '₱${item.price}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
