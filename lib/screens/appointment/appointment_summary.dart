import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';
import 'package:pamfurred/components/regular_text.dart';
import 'package:pamfurred/components/screen_transitions.dart';
import 'package:pamfurred/components/time_and_date_formatter.dart';
import 'package:pamfurred/components/title_text.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:pamfurred/models/services.dart';
import 'package:pamfurred/providers/cart_provider.dart';
import 'package:pamfurred/providers/global_providers.dart';
import 'package:pamfurred/providers/pet_profile_provider.dart';
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
  bool isLoading = false;
  Future<String?> createAppointment(
      {required String petOwnerId,
      String? address,
      required String petProfileId,
      required String date,
      required String time,
      required num totalAmount,
      required String appointmentStatus,
      required String appointmentType}) async {
    setState(() {
      isLoading =
          true; // Set loading to true before starting the appointment creation
    });
    final supabase = Supabase.instance.client;

    // Retrieve the service provider ID
    final sp = ref.watch(spIndexProvider);

    // Get the current time in UTC
    DateTime timestamp = DateTime.now().toUtc();

    final petOwnerIdFromUserTable = await supabase
        .from('pet_owner')
        .select('pet_owner_id')
        .eq('pet_owner_id', petOwnerId)
        .single();

    final response = await supabase
        .from('appointment')
        .insert({
          'pet_owner_id': petOwnerIdFromUserTable['pet_owner_id'],
          'sp_id': sp?['sp_id'],
          'pet_profile_id': petProfileId,
          'appointment_address': address,
          'appointment_date': date,
          'appointment_time': time,
          'total_amount': totalAmount,
          'appointment_status': appointmentStatus,
          'appointment_type': appointmentType,
          'created_at': timestamp.toString(),
        })
        .select('appointment_id')
        .single();

    final appointmentId = response['appointment_id'];
    print('Appointment created with ID: $appointmentId');
    ref.read(appointmentIdProvider.notifier).state = appointmentId.toString();

    setState(() {
      isLoading =
          false; // Set loading to false once the appointment creation is done
    });

    return appointmentId;
  }

// Function to fetch service provider name using the spId from the provider
  Future<String?> fetchServiceProviderName(WidgetRef ref) async {
    // Get the service provider ID (spId) from the provider
    final sp = ref.read(spIndexProvider); // Using ref to read the provider
    final spId = sp!['sp_id']; // Ensure spId is non-null

    final supabaseClient = Supabase.instance.client;

    // Query the service_provider table using the spId
    final response = await supabaseClient
        .from(
            'service_provider') // Assuming 'service_provider' is the table name
        .select(
            'name') // Assuming 'name' is the column with the provider's name
        .eq('sp_id', spId) // Use spId as the service provider ID
        .single(); // Fetch a single record

    // Return the service provider's name, or null if not found
    return response['name'];
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

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final sp = ref.watch(spIndexProvider);

    final cartProducts = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);

    final services = cartProducts.whereType<Service>().toList();
    final packages = cartProducts.whereType<Package>().toList();

    final servicePackageType =
        ref.watch(selectedAppointmentPackageServiceTypeProvider);

    final appointmentAddress = ref.watch(appointmentAddressProvider);

    final appointmentDate = ref.watch(selectedDateProvider);

    final appointmentTime = ref.watch(selectedTimeslotProvider);

    final appointmentPetId = ref.read(selectedAppointmentPetTypeIndexProvider);

    final asyncPet = ref.watch(fetchPetByIdProvider(appointmentPetId));

    final pet = asyncPet.value;

    return isLoading
        ? Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()))
        : Scaffold(
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
                        getAppointmentDetail(
                            context, sp!['service_provider_name']),
                        const SizedBox(height: secondarySizedBox),
                        if (services.isNotEmpty)
                          getAppointmentTitle(context, 'Services'),
                        const SizedBox(height: primarySizedBox),
                        ...services.map((service) => _buildCartItem(service)),
                        const SizedBox(height: primarySizedBox),
                        if (packages.isNotEmpty)
                          getAppointmentTitle(context, 'Packages'),
                        const SizedBox(height: primarySizedBox),
                        ...packages.map((package) => _buildCartItem(package)),
                        const SizedBox(height: secondarySizedBox),
                        getAppointmentTitle(context, 'Pet name'),
                        const SizedBox(height: primarySizedBox),
                        getAppointmentDetail(context, pet?['pet_name']),
                        const SizedBox(height: secondarySizedBox),
                        getAppointmentTitle(context, 'Appointment type'),
                        const SizedBox(height: primarySizedBox),
                        getAppointmentDetail(context, servicePackageType),
                        const SizedBox(height: secondarySizedBox),

                        // Conditional rendering for Home service or In-clinic
                        if (servicePackageType == 'Home service') ...[
                          getAppointmentTitle(context, 'Home address'),
                          getAppointmentAddressDetail(
                              context, appointmentAddress),
                        ] else if (servicePackageType == 'In-clinic') ...[
                          getAppointmentTitle(
                              context, 'Service provider address'),
                          const SizedBox(height: primarySizedBox),
                          getAppointmentAddressDetail(
                              context, sp['full_address']),
                        ],
                        const SizedBox(height: secondarySizedBox),
                        getAppointmentTitle(context, 'Date'),
                        const SizedBox(height: primarySizedBox),
                        getAppointmentDetail(context,
                            secondaryFormatDate(appointmentDate.toString())),
                        const SizedBox(height: secondarySizedBox),
                        getAppointmentTitle(context, 'Time'),
                        const SizedBox(height: primarySizedBox),
                        getAppointmentDetail(
                            context, formatTime(appointmentTime.toString())),
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
                                    final newAppointment =
                                        await createAppointment(
                                      petOwnerId: ref
                                          .read(userIdProvider)
                                          .toString(), // Pet owner ID
                                      totalAmount: total,
                                      appointmentStatus: 'Upcoming',
                                      date:
                                          formatDateToShort('$appointmentDate'),
                                      time: '$appointmentTime',
                                      appointmentType: servicePackageType,
                                      address: appointmentAddress,
                                      petProfileId: appointmentPetId,
                                    );

                              if (newAppointment != null) {
                                // Insert appointment items into the table
                                await insertAppointmentItems(
                                    newAppointment.toString());

                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          crossFadeRoute(
                                              const SuccessfulAppointment()),
                                        );
                                      }
                                    }
                                  },
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(primaryColor),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                'Confirm appointment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: regularText,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
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

  getAppointmentAddressDetail(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        customRegularWeightTitleTextForAddress(context, title),
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
