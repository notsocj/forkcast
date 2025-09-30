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

  /// Save a question to user's saved list
  Future<void> saveQuestion(String questionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('saved_questions')
        .doc(questionId)
        .set({
      'question_id': _firestore.collection('qna_questions').doc(questionId),
      'saved_at': FieldValue.serverTimestamp(),
    });
  }

  /// Unsave a question from user's saved list
  Future<void> unsaveQuestion(String questionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('saved_questions')
        .doc(questionId)
        .delete();
  }

  /// Check if a question is saved by current user
  Future<bool> isQuestionSaved(String questionId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('saved_questions')
        .doc(questionId)
        .get();

    return doc.exists;
  }

  /// Get saved questions for current user
  Stream<List<Map<String, dynamic>>> getSavedQuestions() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    await for (var savedSnapshot in _firestore
        .collection('users')
        .doc(user.uid)
        .collection('saved_questions')
        .orderBy('saved_at', descending: true)
        .snapshots()) {
      
      List<Map<String, dynamic>> questions = [];
      
      for (var savedDoc in savedSnapshot.docs) {
        final questionRef = savedDoc.data()['question_id'] as DocumentReference;
        final questionDoc = await questionRef.get();
        
        if (questionDoc.exists) {
          final questionData = questionDoc.data() as Map<String, dynamic>;
          questionData['id'] = questionDoc.id;
          
          // Handle Timestamp conversion
          if (questionData['posted_at'] != null && questionData['posted_at'] is Timestamp) {
            questionData['posted_at'] = (questionData['posted_at'] as Timestamp).toDate();
          }
          
          // Get answer count
          final answersCount = await getAnswersCount(questionDoc.id);
          questionData['answers_count'] = answersCount;
          
          questions.add(questionData);
        }
      }
      
      yield questions;
    }
  }

  /// Delete a question (only if user owns it)
  Future<void> deleteQuestion(String questionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if user owns the question
    final questionDoc = await _firestore
        .collection('qna_questions')
        .doc(questionId)
        .get();

    if (!questionDoc.exists) {
      throw Exception('Question not found');
    }

    final questionData = questionDoc.data();
    if (questionData?['user_id'] != user.uid) {
      throw Exception('You can only delete your own questions');
    }

    // Delete the question
    await _firestore.collection('qna_questions').doc(questionId).delete();

    // Delete all answers to this question
    final answersQuery = await _firestore
        .collection('qna_answers')
        .where('question_id', isEqualTo: _firestore.collection('qna_questions').doc(questionId))
        .get();

    final batch = _firestore.batch();
    for (var doc in answersQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Delete from all users' saved questions
    final usersQuery = await _firestore.collection('users').get();
    final savedBatch = _firestore.batch();
    for (var userDoc in usersQuery.docs) {
      final savedRef = userDoc.reference
          .collection('saved_questions')
          .doc(questionId);
      savedBatch.delete(savedRef);
    }
    await savedBatch.commit();
  }

  /// Delete an answer (only if user owns it)
  Future<void> deleteAnswer(String answerId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if user owns the answer
    final answerDoc = await _firestore
        .collection('qna_answers')
        .doc(answerId)
        .get();

    if (!answerDoc.exists) {
      throw Exception('Answer not found');
    }

    final answerData = answerDoc.data();
    if (answerData?['expert_id'] != user.uid) {
      throw Exception('You can only delete your own answers');
    }

    // Delete the answer
    await _firestore.collection('qna_answers').doc(answerId).delete();
  }
}