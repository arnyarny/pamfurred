import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/screens/appointment/cart_screen.dart';

class CartIcon extends ConsumerWidget {
  final Color iconColor;
  final Color borderColor;
  final Color badgeColor;

  const CartIcon({
    super.key,
    required this.iconColor,
    required this.borderColor,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberOfItemsInCart = ref.watch(cartNotifierProvider).length;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(context, slideUpRoute(const CartScreen()));
          },
          icon: Icon(Icons.shopping_bag_outlined, color: iconColor),
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
              color: borderColor,
            ),
            child: Text(
              numberOfItemsInCart.toString(),
              style: TextStyle(
                  color: badgeColor,
                  fontSize: smallText,
                  fontWeight: boldWeight),
            ),
          ),
        ),
      ],
    );
  }
}
