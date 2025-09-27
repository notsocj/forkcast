import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for admin consultation management functionality
/// Handles professional verification, booking approvals, and consultation oversight
class ConsultationManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all professionals for admin management
  static Future<List<Map<String, dynamic>>> getAllProfessionals({
    String? status, // null for all, 'verified', 'pending', 'suspended'
    String? searchTerm,
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('users')
        .where('role', isEqualTo: 'professional')
        .orderBy('created_at', descending: true);

    final querySnapshot = await query.limit(limit).get();

    List<Map<String, dynamic>> professionals = [];

    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      // Apply status filter if provided
      if (status != null) {
        final isVerified = data['is_verified'] ?? false;
        final accountStatus = data['account_status'] ?? 'active';
        
        String currentStatus = accountStatus == 'suspended' ? 'suspended' :
                              isVerified ? 'verified' : 'pending';
        
        if (currentStatus != status) continue;
      }

      // Apply search filter if provided
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final fullName = (data['full_name'] ?? '').toString().toLowerCase();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final specialization = (data['specialization'] ?? '').toString().toLowerCase();
        
        if (!fullName.contains(searchTerm.toLowerCase()) &&
            !email.contains(searchTerm.toLowerCase()) &&
            !specialization.contains(searchTerm.toLowerCase())) {
          continue;
        }
      }

      // Get consultation statistics for this professional
      final consultationStats = await _getProfessionalConsultationStats(doc.id);
      data.addAll(consultationStats);

      professionals.add(data);
    }

    return professionals;
  }

  /// Get consultation statistics for a specific professional
  static Future<Map<String, dynamic>> _getProfessionalConsultationStats(String professionalId) async {
    try {
      // Get total consultations
      final totalConsultationsQuery = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: professionalId)
          .get();

      // Get completed consultations
      final completedConsultationsQuery = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: professionalId)
          .where('status', isEqualTo: 'Completed')
          .get();

      // Get pending consultations
      final pendingConsultationsQuery = await _firestore
          .collection('consultations')
          .where('professional_id', isEqualTo: professionalId)
          .where('status', whereIn: ['Scheduled', 'Confirmed'])
          .get();

      // Calculate average rating (simplified - in real app would be from reviews)
      double averageRating = 4.0 + (totalConsultationsQuery.docs.length * 0.1);
      if (averageRating > 5.0) averageRating = 5.0;

      return {
        'total_consultations': totalConsultationsQuery.docs.length,
        'completed_consultations': completedConsultationsQuery.docs.length,
        'pending_consultations': pendingConsultationsQuery.docs.length,
        'average_rating': double.parse(averageRating.toStringAsFixed(1)),
      };
    } catch (e) {
      print('Error getting professional stats: $e');
      return {
        'total_consultations': 0,
        'completed_consultations': 0,
        'pending_consultations': 0,
        'average_rating': 0.0,
      };
    }
  }

  /// Get professional management statistics
  static Future<Map<String, dynamic>> getProfessionalStats() async {
    try {
      // Get all professionals
      final allProfessionalsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'professional')
          .get();

      // Get verified professionals
      final verifiedProfessionalsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'professional')
          .where('is_verified', isEqualTo: true)
          .get();

      // Get pending professionals
      final pendingProfessionalsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'professional')
          .where('is_verified', isEqualTo: false)
          .get();

      // Get active consultations this week
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final activeConsultationsQuery = await _firestore
          .collection('consultations')
          .where('consultation_date', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      return {
        'totalProfessionals': allProfessionalsQuery.docs.length,
        'verifiedProfessionals': verifiedProfessionalsQuery.docs.length,
        'pendingProfessionals': pendingProfessionalsQuery.docs.length,
        'activeConsultations': activeConsultationsQuery.docs.length,
      };
    } catch (e) {
      print('Error getting professional stats: $e');
      return {
        'totalProfessionals': 0,
        'verifiedProfessionals': 0,
        'pendingProfessionals': 0,
        'activeConsultations': 0,
      };
    }
  }

  /// Update professional verification status
  static Future<void> updateProfessionalVerification({
    required String professionalId,
    required bool isVerified,
    String? adminNotes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify admin role
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    if (userData?['role'] != 'admin') {
      throw Exception('Unauthorized: Admin access required');
    }

    // Update professional verification status
    await _firestore.collection('users').doc(professionalId).update({
      'is_verified': isVerified,
      'verified_at': isVerified ? FieldValue.serverTimestamp() : null,
      'verified_by': isVerified ? user.uid : null,
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Log verification action
    await _logVerificationAction(
      professionalId: professionalId,
      action: isVerified ? 'verify' : 'unverify',
      adminNotes: adminNotes,
    );
  }

  /// Update professional account status
  static Future<void> updateProfessionalStatus({
    required String professionalId,
    required String status, // 'active', 'suspended', 'deleted'
    String? reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify admin role
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    if (userData?['role'] != 'admin') {
      throw Exception('Unauthorized: Admin access required');
    }

    final updateData = {
      'account_status': status,
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (status == 'suspended') {
      updateData['suspended_at'] = FieldValue.serverTimestamp();
      updateData['suspended_by'] = user.uid;
      updateData['suspension_reason'] = reason ?? 'Administrative action';
    } else if (status == 'deleted') {
      updateData['deleted_at'] = FieldValue.serverTimestamp();
      updateData['deleted_by'] = user.uid;
    }

    await _firestore.collection('users').doc(professionalId).update(updateData);

    // Log status change action
    await _logVerificationAction(
      professionalId: professionalId,
      action: 'status_change',
      adminNotes: 'Status changed to $status: ${reason ?? 'No reason provided'}',
    );
  }

  /// Get all consultation bookings for admin review
  static Future<List<Map<String, dynamic>>> getConsultationBookings({
    String? status, // null for all, 'Scheduled', 'Confirmed', 'Cancelled', etc.
    String? searchTerm, // search by patient name, professional name, or topic
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('consultations')
        .orderBy('consultation_date', descending: false);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final querySnapshot = await query.limit(limit).get();

    List<Map<String, dynamic>> bookings = [];

    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      // Get patient and professional details
      final patientId = data['patient_id'];
      final professionalId = data['professional_id'];

      if (patientId != null) {
        final patientDoc = await _firestore.collection('users').doc(patientId).get();
        if (patientDoc.exists) {
          final patientData = patientDoc.data()!;
          data['patient_data'] = patientData;
          data['patient_name'] = patientData['full_name'];
        }
      }

      if (professionalId != null) {
        final professionalDoc = await _firestore.collection('users').doc(professionalId).get();
        if (professionalDoc.exists) {
          final professionalData = professionalDoc.data()!;
          data['professional_data'] = professionalData;
          data['professional_name'] = professionalData['full_name'];
          data['professional_specialization'] = professionalData['specialization'];
        }
      }

      // Apply search filter if provided
      if (searchTerm != null && searchTerm.isNotEmpty) {
        final patientName = (data['patient_name'] ?? '').toString().toLowerCase();
        final professionalName = (data['professional_name'] ?? '').toString().toLowerCase();
        final topic = (data['topic'] ?? '').toString().toLowerCase();
        
        if (!patientName.contains(searchTerm.toLowerCase()) &&
            !professionalName.contains(searchTerm.toLowerCase()) &&
            !topic.contains(searchTerm.toLowerCase())) {
          continue;
        }
      }

      bookings.add(data);
    }

    return bookings;
  }

  /// Get consultation booking statistics
  static Future<Map<String, dynamic>> getBookingStats() async {
    try {
      // Get all bookings
      final allBookingsQuery = await _firestore
          .collection('consultations')
          .get();

      // Get pending bookings (Scheduled status)
      final pendingBookingsQuery = await _firestore
          .collection('consultations')
          .where('status', isEqualTo: 'Scheduled')
          .get();

      // Get confirmed bookings
      final confirmedBookingsQuery = await _firestore
          .collection('consultations')
          .where('status', isEqualTo: 'Confirmed')
          .get();

      // Get completed bookings
      final completedBookingsQuery = await _firestore
          .collection('consultations')
          .where('status', isEqualTo: 'Completed')
          .get();

      // Get today's bookings
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final todayBookingsQuery = await _firestore
          .collection('consultations')
          .where('consultation_date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('consultation_date', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      return {
        'totalBookings': allBookingsQuery.docs.length,
        'pendingBookings': pendingBookingsQuery.docs.length,
        'confirmedBookings': confirmedBookingsQuery.docs.length,
        'completedBookings': completedBookingsQuery.docs.length,
        'todayBookings': todayBookingsQuery.docs.length,
      };
    } catch (e) {
      print('Error getting booking stats: $e');
      return {
        'totalBookings': 0,
        'pendingBookings': 0,
        'confirmedBookings': 0,
        'completedBookings': 0,
        'todayBookings': 0,
      };
    }
  }

  /// Update consultation booking status
  static Future<void> updateConsultationStatus({
    required String consultationId,
    required String newStatus,
    String? adminNotes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Verify admin role
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    if (userData?['role'] != 'admin') {
      throw Exception('Unauthorized: Admin access required');
    }

    await _firestore.collection('consultations').doc(consultationId).update({
      'status': newStatus,
      'updated_at': FieldValue.serverTimestamp(),
      'admin_notes': adminNotes ?? '',
    });

    // Log booking action
    await _logBookingAction(
      consultationId: consultationId,
      action: 'status_update',
      adminNotes: 'Status updated to $newStatus: ${adminNotes ?? 'No notes'}',
    );
  }

  /// Log professional verification/management actions
  static Future<void> _logVerificationAction({
    required String professionalId,
    required String action,
    String? adminNotes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('professional_management_logs').add({
      'admin_id': user.uid,
      'professional_id': professionalId,
      'action': action,
      'admin_notes': adminNotes ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Log booking management actions
  static Future<void> _logBookingAction({
    required String consultationId,
    required String action,
    String? adminNotes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('consultation_management_logs').add({
      'admin_id': user.uid,
      'consultation_id': consultationId,
      'action': action,
      'admin_notes': adminNotes ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Format time ago for display
  static String formatTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';

    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() != 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format date for display
  static String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';

    final date = timestamp.toDate();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Get consultation statistics for admin dashboard
  static Future<Map<String, dynamic>> getConsultationStats() async {
    try {
      final consultationsQuery = _firestore.collection('consultations');
      
      // Get all consultations
      final allConsultations = await consultationsQuery.get();
      final totalConsultations = allConsultations.docs.length;
      
      // Count by status
      int pendingApproval = 0;
      int confirmedConsultations = 0;
      int completedConsultations = 0;
      int todayConfirmed = 0;
      
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      for (final doc in allConsultations.docs) {
        final data = doc.data();
        final status = data['status'] ?? 'Scheduled';
        final consultationDate = data['consultation_date'] as Timestamp?;
        
        switch (status.toLowerCase()) {
          case 'scheduled':
            pendingApproval++;
            break;
          case 'confirmed':
            confirmedConsultations++;
            if (consultationDate != null && 
                consultationDate.toDate().isAfter(todayStart) &&
                consultationDate.toDate().isBefore(todayStart.add(const Duration(days: 1)))) {
              todayConfirmed++;
            }
            break;
          case 'completed':
            completedConsultations++;
            break;
        }
      }
      
      return {
        'totalConsultations': totalConsultations,
        'pendingApproval': pendingApproval,
        'confirmedConsultations': confirmedConsultations,
        'completedConsultations': completedConsultations,
        'todayConfirmed': todayConfirmed,
      };
    } catch (e) {
      print('Error getting consultation stats: $e');
      return {
        'totalConsultations': 0,
        'pendingApproval': 0,
        'confirmedConsultations': 0,
        'completedConsultations': 0,
        'todayConfirmed': 0,
      };
    }
  }
}