import 'package:cloud_firestore/cloud_firestore.dart';

/// Market Price Service for ForkCast
/// Manages real-time market prices, price history, and forecasting integration
/// Based on Quezon City public and private market data
class MarketPriceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _marketPricesRef => _firestore.collection('market_prices');
  CollectionReference get _forecastModelsRef => _firestore.collection('forecast_models');

  /// Get the latest price for a specific product
  /// Returns the market_prices document with the lowest recorded price
  Future<Map<String, dynamic>?> getLatestPrice(String category, String productName, String marketName) async {
    try {
      final docId = _createDocumentId(category, productName, marketName);
      final doc = await _marketPricesRef.doc(docId).get();
      
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting latest price: $e');
      return null;
    }
  }

  /// Get all prices for a specific category (e.g., "Fish", "Fruits")
  Stream<List<Map<String, dynamic>>> getPricesByCategory(String category) {
    return _marketPricesRef
        .where('category', isEqualTo: category)
        .orderBy('product_name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  /// Get all available market price categories
  Future<List<String>> getAllCategories() async {
    try {
      final snapshot = await _marketPricesRef.get();
      final categories = <String>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }
      
      return categories.toList()..sort();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  /// Search products by name across all categories
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final snapshot = await _marketPricesRef.get();
      final results = <Map<String, dynamic>>[];
      
      final lowerQuery = query.toLowerCase();
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final productName = (data['product_name'] as String?)?.toLowerCase() ?? '';
        final category = (data['category'] as String?)?.toLowerCase() ?? '';
        
        if (productName.contains(lowerQuery) || category.contains(lowerQuery)) {
          results.add({
            'id': doc.id,
            ...data,
          });
        }
      }
      
      return results;
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Add or update a market price
  Future<bool> updateMarketPrice({
    required String category,
    required String productName,
    required String marketName,
    required String unit,
    required double priceMin,
    required String sourceType,
    bool isImported = false,
  }) async {
    try {
      final docId = _createDocumentId(category, productName, marketName);
      final now = Timestamp.now();
      
      final data = {
        'category': category,
        'product_name': productName,
        'unit': unit,
        'price_min': priceMin,
        'market_name': marketName,
        'collected_at': now,
        'source_type': sourceType,
        'is_imported': isImported,
        'last_updated': now,
      };
      
      await _marketPricesRef.doc(docId).set(data, SetOptions(merge: true));
      
      // Also add to price history
      await _addPriceHistory(docId, priceMin, marketName, false);
      
      return true;
    } catch (e) {
      print('Error updating market price: $e');
      return false;
    }
  }

  /// Get price history for a specific product
  Future<List<Map<String, dynamic>>> getPriceHistory(
    String category,
    String productName,
    String marketName, {
    int limit = 30,
  }) async {
    try {
      final docId = _createDocumentId(category, productName, marketName);
      final snapshot = await _marketPricesRef
          .doc(docId)
          .collection('price_history')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Error getting price history: $e');
      return [];
    }
  }

  /// Get price history stream for real-time updates
  Stream<List<Map<String, dynamic>>> getPriceHistoryStream(
    String category,
    String productName,
    String marketName, {
    int limit = 30,
  }) {
    final docId = _createDocumentId(category, productName, marketName);
    return _marketPricesRef
        .doc(docId)
        .collection('price_history')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Add a price history entry (for actual prices or forecasts)
  Future<bool> _addPriceHistory(
    String marketPriceDocId,
    double price,
    String marketName,
    bool isForecasted, {
    String? modelVersion,
    double? forecastConfidence,
  }) async {
    try {
      final now = DateTime.now();
      final dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final data = {
        'date': Timestamp.fromDate(now),
        'price': price,
        'market_name': marketName,
        'is_forecasted': isForecasted,
        if (modelVersion != null) 'model_version': modelVersion,
        if (forecastConfidence != null) 'forecast_confidence': forecastConfidence,
      };
      
      await _marketPricesRef
          .doc(marketPriceDocId)
          .collection('price_history')
          .doc(dateString)
          .set(data, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error adding price history: $e');
      return false;
    }
  }

  /// Add forecasted prices to price history
  Future<bool> addForecastedPrices(
    String category,
    String productName,
    String marketName,
    List<Map<String, dynamic>> forecasts, {
    required String modelVersion,
  }) async {
    try {
      final docId = _createDocumentId(category, productName, marketName);
      
      for (var forecast in forecasts) {
        final date = forecast['date'] as DateTime;
        final price = forecast['price'] as double;
        final confidence = forecast['confidence'] as double?;
        
        final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final data = {
          'date': Timestamp.fromDate(date),
          'price': price,
          'market_name': marketName,
          'is_forecasted': true,
          'model_version': modelVersion,
          if (confidence != null) 'forecast_confidence': confidence,
        };
        
        await _marketPricesRef
            .doc(docId)
            .collection('price_history')
            .doc(dateString)
            .set(data);
      }
      
      return true;
    } catch (e) {
      print('Error adding forecasted prices: $e');
      return false;
    }
  }

  /// Calculate price change percentage
  Future<double?> getPriceChangePercentage(
    String category,
    String productName,
    String marketName,
  ) async {
    try {
      final history = await getPriceHistory(category, productName, marketName, limit: 2);
      
      if (history.length < 2) return null;
      
      final latestPrice = history[0]['price'] as double;
      final previousPrice = history[1]['price'] as double;
      
      if (previousPrice == 0) return null;
      
      final changePercent = ((latestPrice - previousPrice) / previousPrice) * 100;
      return changePercent;
    } catch (e) {
      print('Error calculating price change: $e');
      return null;
    }
  }

  /// Get price alerts (products with significant price changes)
  Future<List<Map<String, dynamic>>> getPriceAlerts({double threshold = 10.0}) async {
    try {
      final snapshot = await _marketPricesRef.get();
      final alerts = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String;
        final productName = data['product_name'] as String;
        final marketName = data['market_name'] as String;
        
        final changePercent = await getPriceChangePercentage(category, productName, marketName);
        
        if (changePercent != null && changePercent.abs() >= threshold) {
          alerts.add({
            'id': doc.id,
            ...data,
            'price_change_percent': changePercent,
            'alert_type': changePercent > 0 ? 'increase' : 'decrease',
          });
        }
      }
      
      return alerts;
    } catch (e) {
      print('Error getting price alerts: $e');
      return [];
    }
  }

  /// Get or create a forecast model
  Future<String?> createForecastModel({
    required String modelName,
    required String modelVersion,
    required double accuracy,
    required List<String> featuresUsed,
    bool deployed = false,
  }) async {
    try {
      final data = {
        'model_name': modelName,
        'model_version': modelVersion,
        'trained_at': Timestamp.now(),
        'accuracy': accuracy,
        'features_used': featuresUsed,
        'deployed': deployed,
      };
      
      final docRef = await _forecastModelsRef.add(data);
      return docRef.id;
    } catch (e) {
      print('Error creating forecast model: $e');
      return null;
    }
  }

  /// Get all forecast models
  Future<List<Map<String, dynamic>>> getAllForecastModels() async {
    try {
      final snapshot = await _forecastModelsRef
          .orderBy('trained_at', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Error getting forecast models: $e');
      return [];
    }
  }

  /// Get the currently deployed forecast model
  Future<Map<String, dynamic>?> getDeployedModel() async {
    try {
      final snapshot = await _forecastModelsRef
          .where('deployed', isEqualTo: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final doc = snapshot.docs.first;
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    } catch (e) {
      print('Error getting deployed model: $e');
      return null;
    }
  }

  /// Helper: Create composite document ID
  String _createDocumentId(String category, String productName, String marketName) {
    final sanitize = (String str) => str
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    
    return '${sanitize(category)}_${sanitize(productName)}_${sanitize(marketName)}';
  }

  /// Batch update multiple prices (for data import/migration)
  Future<bool> batchUpdatePrices(List<Map<String, dynamic>> prices) async {
    try {
      final batch = _firestore.batch();
      final now = Timestamp.now();
      
      for (var price in prices) {
        final docId = _createDocumentId(
          price['category'] as String,
          price['product_name'] as String,
          price['market_name'] as String,
        );
        
        final data = {
          'category': price['category'],
          'product_name': price['product_name'],
          'unit': price['unit'],
          'price_min': price['price_min'],
          'market_name': price['market_name'],
          'collected_at': now,
          'source_type': price['source_type'],
          'is_imported': price['is_imported'] ?? false,
          'last_updated': now,
        };
        
        batch.set(_marketPricesRef.doc(docId), data, SetOptions(merge: true));
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error batch updating prices: $e');
      return false;
    }
  }
}
