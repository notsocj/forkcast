import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for admin forum management and moderation functionality
/// Handles post reporting, content moderation, and admin actions
class ForumManagementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Report a forum post or answer
  static Future<String> reportContent({
    required String contentType, // 'question' or 'answer'
    required String contentId,
    required String reason,
    String? description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data for reporting
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final fullName = userData?['full_name'] ?? 'Anonymous';

    final reportRef = _firestore.collection('reported_content').doc();

    // Get the original content data
    Map<String, dynamic>? originalContent;
    String? originalAuthor;
    String? contentText;

    if (contentType == 'question') {
      final questionDoc = await _firestore.collection('qna_questions').doc(contentId).get();
      originalContent = questionDoc.data();
      originalAuthor = originalContent?['user_name'];
      contentText = originalContent?['question_text'];
    } else if (contentType == 'answer') {
      final answerDoc = await _firestore.collection('qna_answers').doc(contentId).get();
      originalContent = answerDoc.data();
      originalAuthor = originalContent?['expert_name'];
      contentText = originalContent?['answer_text'];
    }

    final reportData = {
      'content_type': contentType,
      'content_id': contentId,
      'reported_by_id': user.uid,
      'reported_by_name': fullName,
      'reason': reason,
      'description': description ?? '',
      'status': 'pending', // pending, reviewed, dismissed, action_taken
      'reported_at': FieldValue.serverTimestamp(),
      'original_author': originalAuthor,
      'content_text': contentText,
      'admin_notes': '',
      'reviewed_at': null,
      'reviewed_by': null,
      'action_taken': null,
    };

    await reportRef.set(reportData);
    return reportRef.id;
  }

  /// Get all reported content for admin review
  static Future<List<Map<String, dynamic>>> getReportedContent({
    String? status, // null for all, 'pending', 'reviewed', etc.
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('reported_content')
        .orderBy('reported_at', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final querySnapshot = await query.limit(limit).get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      // Ensure names are not empty
      if (data['reported_by_name'] == null || data['reported_by_name'].toString().trim().isEmpty) {
        data['reported_by_name'] = 'Anonymous';
      }
      if (data['original_author'] == null || data['original_author'].toString().trim().isEmpty) {
        data['original_author'] = 'Anonymous';
      }
      return data;
    }).toList();
  }

  /// Get recent forum posts for monitoring
  static Future<List<Map<String, dynamic>>> getRecentPosts({
    int limit = 20,
  }) async {
    // Get recent questions
    final questionsQuery = await _firestore
        .collection('qna_questions')
        .orderBy('posted_at', descending: true)
        .limit(limit ~/ 2)
        .get();

    // Get recent answers
    final answersQuery = await _firestore
        .collection('qna_answers')
        .orderBy('answered_at', descending: true)
        .limit(limit ~/ 2)
        .get();

    List<Map<String, dynamic>> allPosts = [];

    // Add questions
    for (final doc in questionsQuery.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      data['type'] = 'question';
      data['timestamp'] = data['posted_at'];
      // Ensure user_name is not empty
      if (data['user_name'] == null || data['user_name'].toString().trim().isEmpty) {
        data['user_name'] = 'Anonymous';
      }
      allPosts.add(data);
    }

    // Add answers
    for (final doc in answersQuery.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      data['type'] = 'answer';
      data['timestamp'] = data['answered_at'];
      // Ensure expert_name is not empty
      if (data['expert_name'] == null || data['expert_name'].toString().trim().isEmpty) {
        data['expert_name'] = 'Anonymous';
      }
      allPosts.add(data);
    }

    // Sort all posts by timestamp
    allPosts.sort((a, b) {
      final aTime = a['timestamp'] as Timestamp?;
      final bTime = b['timestamp'] as Timestamp?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    return allPosts.take(limit).toList();
  }

  /// Update report status (admin action)
  static Future<void> updateReportStatus({
    required String reportId,
    required String newStatus,
    String? adminNotes,
    String? actionTaken,
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
      'status': newStatus,
      'reviewed_at': FieldValue.serverTimestamp(),
      'reviewed_by': user.uid,
    };

    if (adminNotes != null) {
      updateData['admin_notes'] = adminNotes;
    }

    if (actionTaken != null) {
      updateData['action_taken'] = actionTaken;
    }

    await _firestore.collection('reported_content').doc(reportId).update(updateData);
  }

  /// Delete/Hide content (admin action)
  static Future<void> moderateContent({
    required String contentType,
    required String contentId,
    required String action, // 'hide', 'delete', 'warn_user'
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

    String collection = contentType == 'question' ? 'qna_questions' : 'qna_answers';

    if (action == 'delete') {
      await _firestore.collection(collection).doc(contentId).delete();
    } else if (action == 'hide') {
      await _firestore.collection(collection).doc(contentId).update({
        'is_hidden': true,
        'hidden_at': FieldValue.serverTimestamp(),
        'hidden_by': user.uid,
        'hidden_reason': reason ?? 'Content violation',
      });
    }

    // Log moderation action
    await _logModerationAction(
      contentType: contentType,
      contentId: contentId,
      action: action,
      reason: reason,
    );
  }

  /// Log moderation actions for audit trail
  static Future<void> _logModerationAction({
    required String contentType,
    required String contentId,
    required String action,
    String? reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('moderation_logs').add({
      'admin_id': user.uid,
      'content_type': contentType,
      'content_id': contentId,
      'action': action,
      'reason': reason ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get moderation statistics
  static Future<Map<String, dynamic>> getModerationStats() async {
    try {
      // Get pending reports count
      final pendingReportsQuery = await _firestore
          .collection('reported_content')
          .where('status', isEqualTo: 'pending')
          .get();

      // Get total reports count
      final totalReportsQuery = await _firestore
          .collection('reported_content')
          .get();

      // Get recent moderation actions count (last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentActionsQuery = await _firestore
          .collection('moderation_logs')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      return {
        'pendingReports': pendingReportsQuery.docs.length,
        'totalReports': totalReportsQuery.docs.length,
        'recentActions': recentActionsQuery.docs.length,
        'activeReports': pendingReportsQuery.docs.length,
      };
    } catch (e) {
      print('Error getting moderation stats: $e');
      return {
        'pendingReports': 0,
        'totalReports': 0,
        'recentActions': 0,
        'activeReports': 0,
      };
    }
  }

  /// Get reported content with enhanced data
  static Stream<List<Map<String, dynamic>>> getReportedContentStream({
    String status = 'pending',
  }) {
    return _firestore
        .collection('reported_content')
        .where('status', isEqualTo: status)
        .orderBy('reported_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get recent posts stream for real-time monitoring
  static Stream<List<Map<String, dynamic>>> getRecentPostsStream() {
    return _firestore
        .collection('qna_questions')
        .orderBy('posted_at', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['type'] = 'question';
        return data;
      }).toList();
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
}