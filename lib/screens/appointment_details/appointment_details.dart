import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/custom_appbar.dart';

class AppointmentDetails extends ConsumerStatefulWidget {
  const AppointmentDetails({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppointmentDetailsState();
}

class _AppointmentDetailsState extends ConsumerState<AppointmentDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBarWithTitle(context, 'Appointment Details'),
      body: const SingleChildScrollView(
        child: Text('Hello'),
      ),
    );
  }
}
