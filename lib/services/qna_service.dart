import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing Q&A forum functionality
/// Handles questions, answers, likes, and professional interactions
/// Updated to use top-level collections to avoid indexing issues
class QnAService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Post a new question in the Q&A forum
  Future<String> postQuestion({
    required String questionText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data for denormalization
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final fullName = userData?['full_name'] ?? 'Anonymous';
    final specialization = userData?['specialization'];

    // Debug: Print user data to verify fields
    print('QnA Service - User data: $userData');
    print('QnA Service - full_name: ${userData?['full_name']}');
    print('QnA Service - specialization: ${userData?['specialization']}');

    // Create question in top-level qna_questions collection
    final questionRef = _firestore.collection('qna_questions').doc();

    final questionData = {
      'question_text': questionText,
      'posted_at': FieldValue.serverTimestamp(),
      'user_id': user.uid,
      'user_name': fullName,
      'user_specialization': specialization,
    };

    print('QnA Service - Question data to save: $questionData');

    await questionRef.set(questionData);

    return questionRef.id;
  }

  /// Get all questions from the top-level qna_questions collection
  Stream<List<Map<String, dynamic>>> getAllQuestions() {
    return _firestore
        .collection('qna_questions')
        .orderBy('posted_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> questions = [];
      
      for (var doc in snapshot.docs) {
        final questionData = doc.data();
        questionData['id'] = doc.id;
        
        // Debug: Print loaded question data
        print('QnA Service - Loaded question: $questionData');
        
        // Handle Timestamp conversion
        if (questionData['posted_at'] != null && questionData['posted_at'] is Timestamp) {
          questionData['posted_at'] = (questionData['posted_at'] as Timestamp).toDate();
        }
        
        // Get answer count for this question
        final answersCount = await getAnswersCount(doc.id);
        questionData['answers_count'] = answersCount;
        
        questions.add(questionData);
      }
      
      return questions;
    });
  }

  /// Get answers for a specific question
  Stream<List<Map<String, dynamic>>> getAnswersForQuestion(String questionId) {
    return _firestore
        .collection('qna_answers')
        .where('question_id', isEqualTo: _firestore.collection('qna_questions').doc(questionId))
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> answers = snapshot.docs.map((doc) {
        final answerData = doc.data();
        answerData['id'] = doc.id;
        
        // Handle Timestamp conversion
        if (answerData['answered_at'] != null && answerData['answered_at'] is Timestamp) {
          answerData['answered_at'] = (answerData['answered_at'] as Timestamp).toDate();
        }
        
        return answerData;
      }).toList();
      
      // Sort answers by answered_at in Dart instead of Firestore
      answers.sort((a, b) {
        final aTime = a['answered_at'] as DateTime?;
        final bTime = b['answered_at'] as DateTime?;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
      
      return answers;
    });
  }

  /// Post an answer to a question
  Future<String> postAnswer({
    required String questionId,
    required String answerText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get user data for denormalization
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final fullName = userData?['full_name'] ?? 'Anonymous';
    final specialization = userData?['specialization'];

    // Create answer in top-level qna_answers collection
    final answerRef = _firestore.collection('qna_answers').doc();
    
    await answerRef.set({
      'question_id': _firestore.collection('qna_questions').doc(questionId),
      'expert_id': user.uid,
      'expert_name': fullName,
      'expert_specialization': specialization,
      'answer_text': answerText,
      'answered_at': FieldValue.serverTimestamp(),
    });

    return answerRef.id;
  }

  /// Get answers count for a question
  Future<int> getAnswersCount(String questionId) async {
    final answersQuery = await _firestore
        .collection('qna_answers')
        .where('question_id', isEqualTo: _firestore.collection('qna_questions').doc(questionId))
        .count()
        .get();
    
    return answersQuery.count ?? 0;
  }

  /// Get saved questions for current user (placeholder for future implementation)
  Stream<List<Map<String, dynamic>>> getSavedQuestions() {
    // This would require additional schema for saving questions
    // For now, return empty stream
    return Stream.value([]);
  }
}