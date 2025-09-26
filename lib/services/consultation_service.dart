import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Book a new consultation
  Future<String> bookConsultation({
    required String professionalId,
    required DateTime consultationDate,
    required String consultationTime,
    required String topic,
    int duration = 60, // default 60 minutes
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to book consultation');
      }

      // Get user data for denormalized fields
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Generate unique reference number
      final referenceNo = _generateReferenceNumber();

      // Create consultation document
      final consultationRef = _firestore.collection('consultations').doc();
      
      await consultationRef.set({
        'patient_id': user.uid,
        'professional_id': professionalId,
        'consultation_date': Timestamp.fromDate(consultationDate),
        'consultation_time': consultationTime,
        'duration': duration,
        'topic': topic,
        'status': 'Scheduled',
        'reference_no': referenceNo,
        'notes': '',
        'patient_name': userData['full_name'] ?? 'Unknown Patient',
        'patient_age': _calculateAge(userData['birthdate']),
        'patient_contact': userData['email'] ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return consultationRef.id;
    } catch (e) {
      print('ConsultationService: Error booking consultation: $e');
      rethrow;
    }
  }

  // Get user's consultations
  Future<List<Map<String, dynamic>>> getUserConsultations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('consultations')
          .where('patient_id', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> consultations = [];
      
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id;
        
        // Get professional data for complete info
        try {
          final professionalDoc = await _firestore
              .collection('users')
              .doc(data['professional_id'])
              .get();
          
          if (professionalDoc.exists) {
            final professionalData = professionalDoc.data() ?? {};
            data['professional_name'] = professionalData['full_name'] ?? 'Unknown Professional';
            data['professional_specialization'] = professionalData['specialization'] ?? 'Specialist';
            data['professional_fee'] = professionalData['consultation_fee'] ?? 0;
          }
        } catch (e) {
          print('ConsultationService: Error fetching professional data: $e');
          data['professional_name'] = 'Unknown Professional';
          data['professional_specialization'] = 'Specialist';
        }
        
        // Format consultation date
        if (data['consultation_date'] is Timestamp) {
          final timestamp = data['consultation_date'] as Timestamp;
          data['formatted_date'] = _formatDate(timestamp.toDate());
        }
        
        consultations.add(data);
      }

      // Sort by consultation_date descending (client-side)
      consultations.sort((a, b) {
        final aDate = a['consultation_date'] as Timestamp?;
        final bDate = b['consultation_date'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return consultations;
    } catch (e) {
      print('ConsultationService: Error fetching user consultations: $e');
      return [];
    }
  }

  // Update consultation status
  Future<void> updateConsultationStatus(String consultationId, String status) async {
    try {
      await _firestore.collection('consultations').doc(consultationId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('ConsultationService: Error updating consultation status: $e');
      rethrow;
    }
  }

  // Cancel consultation
  Future<void> cancelConsultation(String consultationId, {String? reason}) async {
    try {
      final updateData = {
        'status': 'Cancelled',
        'updated_at': FieldValue.serverTimestamp(),
      };
      
      if (reason != null && reason.isNotEmpty) {
        updateData['notes'] = 'Cancelled: $reason';
      }

      await _firestore.collection('consultations').doc(consultationId).update(updateData);
    } catch (e) {
      print('ConsultationService: Error cancelling consultation: $e');
      rethrow;
    }
  }

  // Get professional's available time slots for a specific date
  Future<List<String>> getAvailableTimeSlots(String professionalId, DateTime date) async {
    try {
      // Get day of week for the selected date
      final dayOfWeek = _getDayOfWeek(date);
      
      // Get professional's availability for that day
      final availabilityQuery = await _firestore
          .collection('professional_availability')
          .where('professional_id', isEqualTo: professionalId)
          .where('day_of_week', isEqualTo: dayOfWeek)
          .where('is_available', isEqualTo: true)
          .get();

      List<String> availableSlots = [];
      for (var doc in availabilityQuery.docs) {
        availableSlots.add(doc.data()['time_slot']);
      }

      // Check for special dates (blocked or extra availability)
      final specialDateQuery = await _firestore
          .collection('special_dates')
          .where('professional_id', isEqualTo: professionalId)
          .where('date', isEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .get();

      for (var doc in specialDateQuery.docs) {
        final isAvailable = doc.data()['is_available'] as bool;
        if (!isAvailable) {
          // This date is blocked, return empty slots
          return [];
        }
      }

      // Remove time slots that are already booked for this date
      final bookedQuery = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: professionalId)
          .where('consultation_date', isEqualTo: Timestamp.fromDate(DateTime(date.year, date.month, date.day)))
          .where('status', whereIn: ['Scheduled', 'Confirmed', 'In Progress'])
          .get();

      for (var doc in bookedQuery.docs) {
        final bookedTime = doc.data()['consultation_time'];
        availableSlots.remove(bookedTime);
      }

      availableSlots.sort();
      return availableSlots;
    } catch (e) {
      print('ConsultationService: Error fetching available time slots: $e');
      // Return default time slots if there's an error
      return [
        '9:00 AM',
        '10:00 AM',
        '11:00 AM',
        '1:00 PM',
        '2:00 PM',
        '3:00 PM',
        '4:00 PM',
      ];
    }
  }

  // Private helper methods
  String _generateReferenceNumber() {
    final now = DateTime.now();
    return 'TC${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond.toString().padLeft(3, '0')}';
  }

  int? _calculateAge(dynamic birthdate) {
    if (birthdate == null) return null;
    
    DateTime birthDate;
    if (birthdate is Timestamp) {
      birthDate = birthdate.toDate();
    } else if (birthdate is DateTime) {
      birthDate = birthdate;
    } else {
      return null;
    }

    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }
}