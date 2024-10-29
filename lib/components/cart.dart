import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/cart_provider.dart';
// import 'package:pamfurred/screens/cart_screen.dart';
import 'package:pamfurred/screens/profile.dart';

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
              // Placeholder
              return const ProfileScreen();
              // return const CartScreen();
            }));
          },
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
        Positioned(
          top: 5,
          left: 5,
          child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
              ),
              child: Text(numberOfItemsInCart.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ))),
        ),
      ],
    );
  }
}
