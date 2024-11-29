import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pamfurred/components/custom_padded_button.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/appointments_provider.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GiveFeedbackBottomSheet extends ConsumerStatefulWidget {
  const GiveFeedbackBottomSheet({super.key});

  @override
  GiveFeedbackBottomSheetState createState() => GiveFeedbackBottomSheetState();
}

class GiveFeedbackBottomSheetState
    extends ConsumerState<GiveFeedbackBottomSheet> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  String? _errorMessage;
  bool _isSubmitting = false; // To track submission state

  Future<void> submitFeedback() async {
    if (_rating == 0) {
      setState(() {
        _errorMessage = 'Please provide a star rating.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final petOwnerId = ref.read(userIdProvider);
      final spAppointmentId = ref.read(tappedSpAppointmentIdProvider);

      // Variable to get the selected appointment ID
      final appointmentId = ref.read(selectedAppointmentIdProvider);

      DateTime dateNow = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateNow);

      final supabase = Supabase.instance.client;

      // Insert the feedback into the database
      await supabase.from('feedback').insert({
        'pet_owner_id': petOwnerId,
        'sp_id': spAppointmentId,
        'review': _reviewController.text,
        'review_date': formattedDate,
        'compound_score': null,
        'rating': _rating,
        'appointment_id': appointmentId // Assign the selected appointment ID
      });

      // Update the is_reviewed field to true in the appointment table
      await supabase
          .from('appointment')
          .update({'is_reviewed': true}).eq('appointment_id', appointmentId);

      if (!mounted) return;

      Navigator.of(context).pop();

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Feedback Submitted!',
        text: 'Thank you for your feedback.',
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit feedback. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spDetails = ref.watch(appointmentSpIndexProvider);
    final spName = spDetails?['establishment_name'];

    return Padding(
      padding: const EdgeInsets.all(tertiarySizedBox),
      child: Container(
        padding: const EdgeInsets.only(top: secondarySizedBox),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(tertiaryBorderRadius),
              topRight: Radius.circular(tertiaryBorderRadius)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(tertiaryBorderRadius),
                  ),
                  color: greyColor,
                ),
                width: 50,
                height: 5,
              ),
            ),
            const SizedBox(height: tertiarySizedBox),
            Text(
              'Rate ${spName ?? 'the establishment'}',
              style: const TextStyle(fontSize: titleFont),
            ),
            const SizedBox(height: secondarySizedBox),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                      _errorMessage = null;
                    });
                  },
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: secondaryColor,
                    size: 40.0,
                  ),
                );
              }),
            ),
            const SizedBox(height: tertiarySizedBox),
            const Text(
              'Write a review',
              style: TextStyle(fontSize: titleFont),
            ),
            const SizedBox(height: secondarySizedBox),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Tell us about your experience',
                hintStyle: TextStyle(fontSize: regularText, color: greyColor),
                border: OutlineInputBorder(borderSide: BorderSide(width: .25)),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8.0),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
            const SizedBox(height: quaternarySizedBox),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 175,
                height: 50,
                child: customPaddedTextButton(
                  text: _isSubmitting
                      ? const SizedBox(
                          width: 27,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : 'Submit feedback',
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          await submitFeedback();
                        },
                ),
              ),
            ),
            const SizedBox(height: tertiarySizedBox),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
