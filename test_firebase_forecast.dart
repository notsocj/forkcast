import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final forecastedPricesRef = firestore.collection('forecasted_market_prices');

  print('🔍 Testing Firebase Forecast Data Structure');
  print('=' * 60);

  final dateStr = '2025-10-13';
  print('\n📅 Checking forecast for date: $dateStr');

  // Check if document exists
  final forecastDoc = await forecastedPricesRef.doc(dateStr).get();
  print('Document exists: ${forecastDoc.exists}');
  print('Document data: ${forecastDoc.data()}');

  print('\n📂 Checking subcollections...');

  // Check corn category
  final cornSnapshot = await forecastedPricesRef
      .doc(dateStr)
      .collection('corn')
      .get();

  print('\n🌽 CORN category - ${cornSnapshot.docs.length} products:');
  for (final doc in cornSnapshot.docs) {
    print('  📄 Document ID: ${doc.id}');
    print('  📊 Data: ${doc.data()}');
    print('  ---');
  }

  // Check fish category (first 3 products)
  final fishSnapshot = await forecastedPricesRef
      .doc(dateStr)
      .collection('fish')
      .limit(3)
      .get();

  print('\n🐟 FISH category - Sample (first 3):');
  for (final doc in fishSnapshot.docs) {
    print('  📄 Document ID: ${doc.id}');
    print('  📊 Data: ${doc.data()}');
    print('  ---');
  }

  print('\n✅ Test complete!');
}
