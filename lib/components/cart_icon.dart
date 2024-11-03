import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/screens/cart_screen.dart';

class CartIcon extends ConsumerWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberOfItemsInCart = ref.watch(cartNotifierProvider).length;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const CartScreen();
            }));
          },
          icon: const Icon(Icons.shopping_bag_outlined,
              color: lighterSecondaryColor), // Set icon color
        ),
        Positioned(
          top: 5,
          right: 1,
          child: Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0.1,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Text(
              numberOfItemsInCart.toString(),
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: smallText,
                  fontWeight: boldWeight),
            ),
          ),
        ),
      ],
    );
  }
}
