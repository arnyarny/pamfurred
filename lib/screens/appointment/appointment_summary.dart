import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:pamfurred/screens/appointment/successful_appointment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/globals.dart';

class AppointmentSummaryScreen extends ConsumerStatefulWidget {
  const AppointmentSummaryScreen({super.key});

  @override
  ConsumerState<AppointmentSummaryScreen> createState() =>
      AppointmentSummaryScreenState();
}

class AppointmentSummaryScreenState
    extends ConsumerState<AppointmentSummaryScreen> {
  Map<String, dynamic>? mapAppointmentDetails;
  bool isLoading = true;

  Future<String?> createAppointment({
    required String petOwnerId,
    // required String address,
    // required String date,
    // required String time,
    required num totalAmount,
    required String appointmentStatus,
    // required String appointmentType,
  }) async {
    final supabase = Supabase.instance.client;

    final petOwnerIdFromUserTable = await supabase
        .from('pet_owner')
        .select('pet_owner_id')
        .eq('user_id', petOwnerId)
        .single();

    final response = await supabase
        .from('appointment')
        .insert({
          'pet_owner_id': petOwnerIdFromUserTable['pet_owner_id'],
          // 'appointment_address': address,
          // 'appointment_date': date,
          // 'appointment_time': time,
          'total_amount': totalAmount,
          'appointment_status': appointmentStatus,
          // 'appointment_type': appointmentType,
        })
        .select('appointment_id')
        .single();

    final appointmentId = response['appointment_id'];
    print('Appointment created with ID: $appointmentId');
    return appointmentId;
  }

  Future<void> insertAppointmentItems(String appointmentId) async {
    final supabase = Supabase.instance.client;

    final cartProducts = ref.read(cartNotifierProvider);
    final services = cartProducts.whereType<Service>().toList();
    final packages = cartProducts.whereType<Package>().toList();

    final List<Map<String, dynamic>> appointmentItems = [];

    for (final service in services) {
      appointmentItems.add({
        'appointment_id': appointmentId,
        'service_id': service.id,
        'package_id': null,
      });
    }

    for (final package in packages) {
      appointmentItems.add({
        'appointment_id': appointmentId,
        'service_id': null,
        'package_id': package.id,
      });
    }

    final response =
        await supabase.from('appointment_item').insert(appointmentItems);

    print('Appointment items inserted successfully: $response');
  }

  @override
  Widget build(BuildContext context) {
    final sp = ref.watch(spIndexProvider);

    final cartProducts = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);

    final services = cartProducts.whereType<Service>().toList();
    final packages = cartProducts.whereType<Package>().toList();

    return Scaffold(
      appBar: customAppBarWithTitle(context, 'Appointment Summary'),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: screenPadding(context),
              child: Column(
                children: [
                  const SizedBox(height: tertiarySizedBox),
                  getAppointmentTitle(context, 'Service provider'),
                  const SizedBox(height: primarySizedBox),
                  getAppointmentDetail(context, sp!['name']),
                  const SizedBox(height: secondarySizedBox),
                  if (services.isNotEmpty)
                    getAppointmentTitle(context, 'Services'),
                  const SizedBox(height: primarySizedBox),
                  ...services.map((service) => _buildCartItem(service)),
                  const SizedBox(height: secondarySizedBox),
                  if (packages.isNotEmpty)
                    getAppointmentTitle(context, 'Packages'),
                  const SizedBox(height: primarySizedBox),
                  ...packages.map((package) => _buildCartItem(package)),
                  const SizedBox(height: secondarySizedBox),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      getAppointmentTotalTitle(context, 'Total'),
                      regularPrimaryColoredBoldTextWidget('₱$total')
                    ],
                  ),
                  const SizedBox(height: quaternarySizedBox),
                  Center(
                    child: TextButton(
                        onPressed: cartProducts.isEmpty
                            ? null
                            : () async {
                                final appointmentId = await createAppointment(
                                  petOwnerId: ref
                                      .read(userIdProvider)
                                      .toString(), // Pet owner ID
                                  // address: '123 Example St',
                                  // date: '2024-11-05',
                                  // time: '10:00 AM',
                                  totalAmount: total,
                                  appointmentStatus: 'upcoming',
                                  // appointmentType: 'standard',
                                );

                                if (appointmentId != null) {
                                  await insertAppointmentItems(
                                      appointmentId.toString());
                                  Navigator.push(
                                    context,
                                    crossFadeRoute(
                                        const SuccessfulAppointment()),
                                  );
                                }
                              },
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    secondaryBorderRadius),
                              ),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                              primaryColor,
                            )),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            'Confirm appointment',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: regularText,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAppointmentTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customTitleText(context, title),
        const SizedBox(width: primarySizedBox),
      ],
    );
  }

  getAppointmentTotalTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customTitleTextWithPrimaryColor(context, title),
        const SizedBox(width: primarySizedBox),
      ],
    );
  }

  getAppointmentDetail(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customRegularWeightTitleText(context, title),
        const SizedBox(width: primarySizedBox),
      ],
    );
  }
}

Widget _buildCartItem(dynamic item) {
  return Row(
    children: [
      Expanded(
        child: Text(
          item.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      getPrice('${item.price}'),
    ],
  );
}

getPrice(String s) {
  return Text(
    '₱$s',
    style: const TextStyle(fontWeight: FontWeight.bold),
  );
}
