// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pamfurred/components/custom_appbar.dart';
// import 'package:pamfurred/components/globals.dart';
// import 'package:pamfurred/components/title_text.dart';
// import 'package:pamfurred/providers/pet_profile_provider.dart';

// class PetProfileScreen extends ConsumerStatefulWidget {
//   final int petId;

//   const PetProfileScreen({super.key, required this.petId});

//   @override
//   PetProfileScreenState createState() => PetProfileScreenState();
// }

// class PetProfileScreenState extends ConsumerState<PetProfileScreen> {
//   bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     final asyncPet = ref.watch(fetchPetByIdProvider(widget.petId));

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: customAppBar(context),
//       body: asyncPet.when(
//         data: (pet) {
//           const double descWidth = 331;
//           return SingleChildScrollView(
//             child: Center(
//               child: SizedBox(
//                 width: screenPadding(context),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: primarySizedBox),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Stack(
//                           fit: StackFit.loose,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(
//                                   0.1), // Space for the gradient border
//                               decoration: const BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: LinearGradient(
//                                   colors: [primaryColor, Colors.transparent],
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   stops: [0.25, 0.9],
//                                 ),
//                               ),
//                               child: Card(
//                                 shape: const CircleBorder(),
//                                 elevation: 0,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(
//                                       secondarySizedBox), // Space between image and card border
//                                   child: ClipOval(
//                                     child: Image.network(
//                                       pet['image'], // Replace with your image URL
//                                       fit: BoxFit.cover,
//                                       width: 151,
//                                       height: 151,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const Positioned(
//                                 bottom: 5,
//                                 right: 0,
//                                 child: SizedBox(
//                                   height: 32,
//                                   child: CircleAvatar(
//                                     backgroundColor: primaryColor,
//                                     child: Icon(
//                                       Icons.camera_alt,
//                                       size: 20,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ))
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: tertiarySizedBox),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         customTitleText(context, pet['pet_name']),
//                         const SizedBox(
//                           width: secondarySizedBox,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: tertiarySizedBox),
//                     Center(
//                       child: SizedBox(
//                         width: descWidth + 25,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             customTitleText(context, 'Basic info'),
//                             editIcon()
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: secondarySizedBox),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(secondarySizedBox),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   petDesc(context, 'assets/id-card.png',
//                                       pet['pet_name'], "name"),
//                                   const SizedBox(height: secondarySizedBox),
//                                   petDesc(context, 'assets/time.png',
//                                       pet['age'].toString(), "mos. old"),
//                                   const SizedBox(height: secondarySizedBox),
//                                   petDesc(context, 'assets/weight-scale.png',
//                                       pet['weight'].toString(), "kg."),
//                                   const SizedBox(height: secondarySizedBox),
//                                 ],
//                               ),
//                               if (_isExpanded) ...[
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     petDesc(context, 'assets/gender.png',
//                                         pet['sex'], "sex"),
//                                     const SizedBox(height: secondarySizedBox),
//                                     petDesc(context, 'assets/breed.png',
//                                         pet['breed'], "breed"),
//                                     const SizedBox(height: secondarySizedBox),
//                                     petDesc(context, 'assets/categories.png',
//                                         pet['pet_category'], "category"),
//                                   ],
//                                 ),
//                               ],
//                               Align(
//                                 alignment: Alignment.bottomCenter,
//                                 child: TextButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _isExpanded = !_isExpanded;
//                                     });
//                                   },
//                                   child: Text(
//                                     _isExpanded ? "See less" : "See more",
//                                     style:
//                                         const TextStyle(fontSize: regularText),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       width: descWidth + 25,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           customTitleText(context, 'Description'),
//                           editIcon()
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: tertiarySizedBox),
//                     Center(
//                       child: SizedBox(
//                         width: descWidth,
//                         child: Text(pet['pet_desc'],
//                             textAlign: TextAlign.justify,
//                             style: const TextStyle(
//                                 color: darkGreyColor, fontSize: regularText)),
//                       ),
//                     ),
//                     const SizedBox(height: quaternarySizedBox),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text("Error: $err")),
//       ),
//     );
//   }

//   subtitleText(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//           color: darkGreyColor,
//           fontSize: regularText,
//           fontWeight: regularWeight),
//     );
//   }

//   verticalDivider() {
//     return Container(
//       width: 1, // Width of the divider
//       height: 33, // Height of the divider
//       color: Colors.black, // Line color
//       margin: const EdgeInsets.symmetric(
//           horizontal:
//               quaternarySizedBox), // Space between divider and adjacent elements
//     );
//   }

//   petDesc(
//       BuildContext context, String image, String petDetail, String subtitle) {
//     return Row(
//       children: [
//         Column(
//           children: [Image.asset(image, height: 35)],
//         ),
//         const SizedBox(width: tertiarySizedBox),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 customBoldWeightRegularText(context, petDetail),
//               ],
//             ),
//             Row(
//               children: [
//                 subtitleText(subtitle),
//               ],
//             )
//           ],
//         ),
//       ],
//     );
//   }

//   editIcon() {
//     return const Icon(Icons.edit, size: 18, color: primaryColor);
//   }
// }
