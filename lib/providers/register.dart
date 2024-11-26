import 'package:flutter_riverpod/flutter_riverpod.dart';

// Personal Details
final firstNameProvider = StateProvider<String>((ref) => '');
final lastNameProvider = StateProvider<String>((ref) => '');

// Phone Number
final phoneNumberProvider = StateProvider<String>((ref) => '');

// Address
final floorUnitRoomProvider = StateProvider<String>((ref) => '');
final streetProvider = StateProvider<String>((ref) => '');
final barangayProvider = StateProvider<String>((ref) => '');
final cityProvider = StateProvider<String>((ref) => '');
