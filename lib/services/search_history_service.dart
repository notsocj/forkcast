import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a search query to user's search history
  Future<void> addSearchToHistory(String query) async {
    final user = _auth.currentUser;
    if (user == null || query.trim().isEmpty) return;

    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final searchRef = userRef.collection('search_history').doc();

      await searchRef.set({
        'query': query.trim(),
        'searched_at': Timestamp.now(),
      });

      // Keep only the latest 20 searches to avoid unlimited growth
      await _cleanupOldSearches(userRef);
    } catch (e) {
      print('Error adding search to history: $e');
    }
  }

  /// Get user's recent search history
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('search_history')
          .orderBy('searched_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['query'] as String)
          .where((query) => query.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  /// Clear user's search history
  Future<void> clearSearchHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final searchHistoryRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('search_history');

      final batch = _firestore.batch();
      final docs = await searchHistoryRef.get();
      
      for (final doc in docs.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  /// Remove a specific search from history
  Future<void> removeSearchFromHistory(String query) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('search_history')
          .where('query', isEqualTo: query)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error removing search from history: $e');
    }
  }

  /// Cleanup old searches to keep only the latest 20
  Future<void> _cleanupOldSearches(DocumentReference userRef) async {
    try {
      final querySnapshot = await userRef
          .collection('search_history')
          .orderBy('searched_at', descending: true)
          .get();

      if (querySnapshot.docs.length > 20) {
        final batch = _firestore.batch();
        
        // Delete searches beyond the 20 most recent
        for (int i = 20; i < querySnapshot.docs.length; i++) {
          batch.delete(querySnapshot.docs[i].reference);
        }
        
        await batch.commit();
      }
    } catch (e) {
      print('Error cleaning up old searches: $e');
    }
  }
}