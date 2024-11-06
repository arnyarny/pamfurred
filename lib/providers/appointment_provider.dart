import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_data/mock_db.dart'; // Import mock database

// StateNotifier to manage appointment state
class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier() : super([]) {
    fetchAppointments();
  }

  get appointments => null;

  // Method to fetch all appointments from the mock_db
  void fetchAppointments() {
    final List<Map<String, dynamic>> appointmentMaps = data['appointments'];

    state = appointmentMaps.map((map) {
      return Appointment.fromMap(map);
    }).toList();
  }
}

// class for appointment model
class Appointment {
  final int appointmentId;
  final int userId;
  final int spID;
  final int petId;
  final int appointmentItemId;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final double totalAmount;

  Appointment({
    required this.appointmentId,
    required this.userId,
    required this.spID,
    required this.petId,
    required this.appointmentItemId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.totalAmount,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentId: map['appointment_id'],
      userId: map['user_id'],
      spID: map['sp_id'],
      petId: map['pet_id'],
      appointmentItemId: map['appointment_item_id'],
      appointmentDate: map['appointment_date'],
      appointmentTime: map['appointment_time'],
      status: map['status'],
      totalAmount: map['total_amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointment_id': appointmentId,
      'user_id': userId,
      'sp_id': spID,
      'pet_id': petId,
      'appointment_item_id': appointmentItemId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'status': status,
      'total_amount': totalAmount,
    };
  }
}

final appointmentIdProvider = StateProvider<String>((ref) => '');

// Provider for AppointmentNotifier
final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  return AppointmentNotifier();
});