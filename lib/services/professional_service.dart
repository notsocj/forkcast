import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as UserModel;

class ProfessionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current professional user
  Future<UserModel.User?> getCurrentProfessional() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        if (userData['role'] == 'professional') {
          return UserModel.User.fromFirestore(userDoc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current professional: $e');
      return null;
    }
  }

  /// Update professional profile
  Future<void> updateProfessionalProfile({
    required String fullName,
    required String phoneNumber,
    required String specialization,
    required String licenseNumber,
    required int yearsExperience,
    required double consultationFee,
    required String bio,
    required List<String> certifications,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'specialization': specialization,
        'license_number': licenseNumber,
        'years_experience': yearsExperience,
        'consultation_fee': consultationFee,
        'bio': bio,
        'certifications': certifications,
      });
    } catch (e) {
      throw Exception('Failed to update professional profile: $e');
    }
  }

  /// Get dashboard statistics for professional
  Future<Map<String, dynamic>> getDashboardStats() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      // Get today's consultations
      final todayConsultations = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: currentUser.uid)
          .where('consultation_date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('consultation_date', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      // Get this week's consultations
      final weeklyConsultations = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: currentUser.uid)
          .where('consultation_date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('consultation_date', isLessThan: Timestamp.fromDate(weekEnd))
          .get();

      // Get unique patients count
      final allConsultations = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: currentUser.uid)
          .get();

      final uniquePatients = allConsultations.docs
          .map((doc) => doc.data()['patient_id'])
          .toSet()
          .length;

      return {
        'todayConsultations': todayConsultations.docs.length,
        'weeklyConsultations': weeklyConsultations.docs.length,
        'totalPatients': uniquePatients,
        'rating': 5, // Placeholder - implement rating system later
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'todayConsultations': 0,
        'weeklyConsultations': 0,
        'totalPatients': 0,
        'rating': 0,
      };
    }
  }

  /// Get today's consultations for professional
  Future<List<Map<String, dynamic>>> getTodaysConsultations() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: currentUser.uid)
          .where('consultation_date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('consultation_date', isLessThan: Timestamp.fromDate(todayEnd))
          .orderBy('consultation_date', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting today\'s consultations: $e');
      return [];
    }
  }

  /// Get upcoming consultations
  Future<List<Map<String, dynamic>>> getUpcomingConsultations() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final querySnapshot = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: currentUser.uid)
          .where('consultation_date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .orderBy('consultation_date', descending: false)
          .get();

      List<Map<String, dynamic>> consultations = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final consultationData = {
          'id': doc.id,
          ...data,
        };
        
        // Fetch patient phone number from user document
        try {
          final patientId = data['patient_id'];
          if (patientId != null) {
            final patientDoc = await _firestore
                .collection('users')
                .doc(patientId)
                .get();
            
            if (patientDoc.exists) {
              final patientData = patientDoc.data();
              consultationData['patient_phone'] = patientData?['phone_number'] ?? '';
            }
          }
        } catch (e) {
          print('Error fetching patient phone number: $e');
          consultationData['patient_phone'] = '';
        }
        
        consultations.add(consultationData);
      }
      
      return consultations;
    } catch (e) {
      print('Error getting upcoming consultations: $e');
      return [];
    }
  }

  /// Get patient notes for professional (showing all consultations grouped by patient)
  Future<List<Map<String, dynamic>>> getPatientNotes({String? searchQuery}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      // Get all consultations for this professional
      final consultationsSnapshot = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: currentUser.uid)
          .orderBy('consultation_date', descending: true)
          .get();

      // Group consultations by patient
      Map<String, Map<String, dynamic>> patientConsultations = {};

      for (var doc in consultationsSnapshot.docs) {
        final data = doc.data();
        final patientId = data['patient_id'] as String;
        final patientName = data['patient_name'] as String? ?? 'Unknown Patient';

        if (!patientConsultations.containsKey(patientId)) {
          // Fetch patient details
          try {
            final patientDoc = await _firestore.collection('users').doc(patientId).get();
            final patientData = patientDoc.data();
            
            patientConsultations[patientId] = {
              'patient_id': patientId,
              'patient_name': patientName,
              'patient_phone': patientData?['phone_number'] ?? '',
              'health_conditions': patientData?['health_conditions'] ?? [],
              'consultations': [],
              'consultation_count': 0,
              'latest_consultation': null,
              'created_at': data['created_at'] ?? Timestamp.now(),
            };
          } catch (e) {
            print('Error fetching patient data: $e');
            patientConsultations[patientId] = {
              'patient_id': patientId,
              'patient_name': patientName,
              'patient_phone': '',
              'health_conditions': [],
              'consultations': [],
              'consultation_count': 0,
              'latest_consultation': null,
              'created_at': data['created_at'] ?? Timestamp.now(),
            };
          }
        }

        // Add consultation to patient's list
        patientConsultations[patientId]!['consultations'].add({
          'id': doc.id,
          'consultation_date': data['consultation_date'],
          'consultation_time': data['consultation_time'],
          'status': data['status'],
          'topic': data['topic'] ?? '',
          'reference_no': data['reference_no'] ?? '',
        });

        patientConsultations[patientId]!['consultation_count']++;
        
        // Update latest consultation
        if (patientConsultations[patientId]!['latest_consultation'] == null) {
          patientConsultations[patientId]!['latest_consultation'] = {
            'date': data['consultation_date'],
            'topic': data['topic'] ?? 'No topic specified',
          };
        }
      }

      // Convert to list
      var patientList = patientConsultations.values.toList();

      // Apply client-side search if query provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        patientList = patientList.where((patient) {
          final patientName = (patient['patient_name'] as String? ?? '').toLowerCase();
          return patientName.contains(query);
        }).toList();
      }

      return patientList;
    } catch (e) {
      print('Error getting patient notes: $e');
      return [];
    }
  }

  /// Add patient note
  Future<void> addPatientNote({
    required String patientId,
    required String patientName,
    required String noteText,
    required List<String> tags,
    required List<String> healthConditions,
    String? consultationId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      await _firestore.collection('patient_notes').add({
        'professional_id': currentUser.uid,
        'patient_id': patientId,
        'patient_name': patientName,
        'consultation_id': consultationId,
        'note_text': noteText,
        'tags': tags,
        'health_conditions': healthConditions,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add patient note: $e');
    }
  }

  /// Get consultation history for a specific patient
  Future<List<Map<String, dynamic>>> getPatientConsultationHistory(String patientId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      final consultationsSnapshot = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: currentUser.uid)
          .where('patient_id', isEqualTo: patientId)
          .orderBy('consultation_date', descending: true)
          .get();

      List<Map<String, dynamic>> consultations = [];

      for (var doc in consultationsSnapshot.docs) {
        final data = doc.data();
        
        // Get associated notes for this consultation
        final notesSnapshot = await _firestore
            .collection('patient_notes')
            .where('consultation_id', isEqualTo: doc.id)
            .get();

        consultations.add({
          'id': doc.id,
          'consultation_date': data['consultation_date'],
          'consultation_time': data['consultation_time'],
          'status': data['status'],
          'topic': data['topic'] ?? 'No topic specified',
          'reference_no': data['reference_no'] ?? '',
          'notes': notesSnapshot.docs.map((noteDoc) {
            final noteData = noteDoc.data();
            return {
              'id': noteDoc.id,
              'note_text': noteData['note_text'],
              'tags': noteData['tags'] ?? [],
              'created_at': noteData['created_at'],
            };
          }).toList(),
        });
      }

      return consultations;
    } catch (e) {
      print('Error getting patient consultation history: $e');
      return [];
    }
  }

  /// Get all notes for a specific patient
  Future<List<Map<String, dynamic>>> getPatientAllNotes(String patientId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      final notesSnapshot = await _firestore
          .collection('patient_notes')
          .where('professional_id', isEqualTo: currentUser.uid)
          .where('patient_id', isEqualTo: patientId)
          .orderBy('created_at', descending: true)
          .get();

      return notesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting patient notes: $e');
      return [];
    }
  }

  /// Get professional availability
  Future<Map<String, List<bool>>> getProfessionalAvailability() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return {};

    try {
      final querySnapshot = await _firestore
          .collection('professional_availability')
          .where('professional_id', isEqualTo: currentUser.uid)
          .get();

      final Map<String, List<bool>> availability = {
        'Monday': List.generate(11, (index) => false),
        'Tuesday': List.generate(11, (index) => false),
        'Wednesday': List.generate(11, (index) => false),
        'Thursday': List.generate(11, (index) => false),
        'Friday': List.generate(11, (index) => false),
        'Saturday': List.generate(11, (index) => false),
        'Sunday': List.generate(11, (index) => false),
      };

      final timeSlots = [
        '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
        '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
      ];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final dayOfWeek = data['day_of_week'] as String;
        final timeSlot = data['time_slot'] as String;
        final isAvailable = data['is_available'] as bool;

        if (availability.containsKey(dayOfWeek)) {
          final timeIndex = timeSlots.indexOf(timeSlot);
          if (timeIndex >= 0) {
            availability[dayOfWeek]![timeIndex] = isAvailable;
          }
        }
      }

      return availability;
    } catch (e) {
      print('Error getting professional availability: $e');
      return {};
    }
  }

  /// Save professional availability
  Future<void> saveProfessionalAvailability(Map<String, List<bool>> availability) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      final timeSlots = [
        '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
        '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
      ];

      // Delete existing availability
      final existingDocs = await _firestore
          .collection('professional_availability')
          .where('professional_id', isEqualTo: currentUser.uid)
          .get();

      final batch = _firestore.batch();

      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // Add new availability
      for (String day in availability.keys) {
        for (int i = 0; i < timeSlots.length && i < availability[day]!.length; i++) {
          final docRef = _firestore.collection('professional_availability').doc();
          batch.set(docRef, {
            'professional_id': currentUser.uid,
            'day_of_week': day,
            'time_slot': timeSlots[i],
            'is_available': availability[day]![i],
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to save availability: $e');
    }
  }

  /// Get special dates
  Future<Map<DateTime, bool>> getSpecialDates() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return {};

    try {
      final querySnapshot = await _firestore
          .collection('special_dates')
          .where('professional_id', isEqualTo: currentUser.uid)
          .get();

      final Map<DateTime, bool> specialDates = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp;
        final date = timestamp.toDate();
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final isAvailable = data['is_available'] as bool;

        specialDates[normalizedDate] = isAvailable;
      }

      return specialDates;
    } catch (e) {
      print('Error getting special dates: $e');
      return {};
    }
  }

  /// Add special date
  Future<void> addSpecialDate(DateTime date, bool isAvailable, String reason) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      await _firestore.collection('special_dates').add({
        'professional_id': currentUser.uid,
        'date': Timestamp.fromDate(normalizedDate),
        'is_available': isAvailable,
        'reason': reason,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add special date: $e');
    }
  }

  /// Update consultation status
  Future<void> updateConsultationStatus(String consultationId, String status) async {
    try {
      await _firestore.collection('consultations').doc(consultationId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update consultation status: $e');
    }
  }

  /// Get all professionals with their availability for teleconsultation
  Future<List<Map<String, dynamic>>> getAllProfessionalsWithAvailability() async {
    try {
      // Get all professional users
      final professionalsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'professional')
          .get();

      List<Map<String, dynamic>> professionalsWithAvailability = [];

      for (var doc in professionalsSnapshot.docs) {
        final professionalData = doc.data();
        final professionalId = doc.id;

        // Get availability for this professional
        final availabilitySnapshot = await _firestore
            .collection('professional_availability')
            .where('professional_id', isEqualTo: professionalId)
            .where('is_available', isEqualTo: true)
            .get();

        // Process availability data
        List<String> availableSlots = [];
        Map<String, List<String>> availabilityByDay = {};

        final timeSlots = [
          '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
          '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
        ];

        for (var availDoc in availabilitySnapshot.docs) {
          final availData = availDoc.data();
          final dayOfWeek = availData['day_of_week'] as String;
          final timeSlot = availData['time_slot'] as String;

          if (!availabilityByDay.containsKey(dayOfWeek)) {
            availabilityByDay[dayOfWeek] = [];
          }
          availabilityByDay[dayOfWeek]!.add(timeSlot);
          
          if (!availableSlots.contains(timeSlot)) {
            availableSlots.add(timeSlot);
          }
        }

        // Sort available slots - fix the IndexError by checking if slots exist
        availableSlots.sort((a, b) {
          int aIndex = timeSlots.indexOf(a);
          int bIndex = timeSlots.indexOf(b);
          if (aIndex == -1) aIndex = 999; // Put unknown slots at end
          if (bIndex == -1) bIndex = 999;
          return aIndex.compareTo(bIndex);
        });

        // Only add professionals that have valid data
        final fullName = professionalData['full_name'] as String?;
        final specialization = professionalData['specialization'] as String?;
        
        if (fullName != null && fullName.isNotEmpty && 
            specialization != null && specialization.isNotEmpty) {
          // Add sample availability if none exists in Firebase
          if (availableSlots.isEmpty) {
            availableSlots = ['9:00 AM', '10:00 AM', '2:00 PM', '3:00 PM'];
            availabilityByDay = {
              'Monday': ['9:00 AM', '10:00 AM'],
              'Tuesday': ['2:00 PM', '3:00 PM'],
              'Wednesday': ['9:00 AM', '10:00 AM'],
              'Thursday': ['2:00 PM', '3:00 PM'],
              'Friday': ['9:00 AM', '10:00 AM'],
            };
          }

          // Create professional data with availability
          professionalsWithAvailability.add({
            'id': professionalId,
            'name': fullName,
            'specialization': specialization,
            'phoneNumber': professionalData['phone_number'] ?? '',
            'consultationFee': professionalData['consultation_fee'] ?? 0,
            'rating': 4.8, // Default rating for now
            'avatar': _getInitials(fullName),
            'isAvailable': availableSlots.isNotEmpty,
            'availableSlots': availableSlots,
            'availabilityByDay': availabilityByDay,
            'bio': professionalData['bio'] ?? '',
            'yearsExperience': professionalData['years_experience'] ?? 0,
            'licenseNumber': professionalData['license_number'] ?? '',
            'isVerified': professionalData['is_verified'] ?? false,
          });
        }
      }

      print('Found ${professionalsWithAvailability.length} professionals with availability');
      return professionalsWithAvailability;
    } catch (e) {
      print('Error getting professionals with availability: $e');
      return [];
    }
  }

  /// Helper method to get initials from full name
  String _getInitials(String fullName) {
    List<String> nameParts = fullName.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'P';
  }

  /// Create sample availability for professionals (for testing)
  Future<void> createSampleAvailability(String professionalId) async {
    try {
      final batch = _firestore.batch();
      final timeSlots = ['9:00 AM', '10:00 AM', '11:00 AM', '2:00 PM', '3:00 PM', '4:00 PM'];
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
      
      for (String day in days) {
        for (String time in timeSlots) {
          // Create availability document
          final docRef = _firestore.collection('professional_availability').doc();
          batch.set(docRef, {
            'professional_id': professionalId,
            'day_of_week': day,
            'time_slot': time,
            'is_available': true,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
      
      await batch.commit();
      print('Sample availability created for professional: $professionalId');
    } catch (e) {
      print('Error creating sample availability: $e');
    }
  }
}