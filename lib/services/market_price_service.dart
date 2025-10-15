import 'package:cloud_firestore/cloud_firestore.dart';

/// Market Price Service for ForkCast
/// Manages real-time market prices, price history, and forecasting integration
/// Based on Quezon City public and private market data
class MarketPriceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _marketPricesRef => _firestore.collection('market_prices');
  CollectionReference get _forecastModelsRef => _firestore.collection('forecast_models');
  CollectionReference get _forecastedPricesRef => _firestore.collection('forecasted_market_prices');

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

  /// Update market price with market name change (handles document migration)
  /// This method copies price history from old document to new document and deletes old one
  Future<bool> updateMarketPriceWithMarketChange({
    required String category,
    required String productName,
    required String oldMarketName,
    required String newMarketName,
    required String unit,
    required double priceMin,
    required String sourceType,
    bool isImported = false,
  }) async {
    try {
      final oldDocId = _createDocumentId(category, productName, oldMarketName);
      final newDocId = _createDocumentId(category, productName, newMarketName);
      final now = Timestamp.now();
      
      print('📦 Migrating document: $oldDocId → $newDocId');
      
      // Step 1: Get all price history from old document
      final oldPriceHistory = await getPriceHistory(category, productName, oldMarketName, limit: 1000);
      print('📜 Found ${oldPriceHistory.length} price history entries to migrate');
      
      // Step 2: Create new document with updated data
      final newData = {
        'category': category,
        'product_name': productName,
        'unit': unit,
        'price_min': priceMin,
        'market_name': newMarketName, // Use new market name
        'collected_at': now,
        'source_type': sourceType,
        'is_imported': isImported,
        'last_updated': now,
      };
      
      await _marketPricesRef.doc(newDocId).set(newData, SetOptions(merge: true));
      print('✅ Created new document with updated market name');
      
      // Step 3: Copy price history to new document (update market_name in each entry)
      final batch = _firestore.batch();
      for (final entry in oldPriceHistory) {
        final dateId = entry['id'] as String;
        final entryData = {
          'date': entry['date'],
          'price': entry['price'],
          'market_name': newMarketName, // Update market name in history
          'is_forecasted': entry['is_forecasted'] ?? false,
          if (entry['model_version'] != null) 'model_version': entry['model_version'],
          if (entry['forecast_confidence'] != null) 'forecast_confidence': entry['forecast_confidence'],
        };
        
        final newHistoryRef = _marketPricesRef
            .doc(newDocId)
            .collection('price_history')
            .doc(dateId);
        
        batch.set(newHistoryRef, entryData);
      }
      
      await batch.commit();
      print('✅ Migrated ${oldPriceHistory.length} price history entries');
      
      // Step 4: Add today's price to history (new entry)
      await _addPriceHistory(newDocId, priceMin, newMarketName, false);
      print('✅ Added today\'s price to history');
      
      // Step 5: Delete old document and its subcollections
      await _deleteDocumentWithSubcollections(oldDocId);
      print('🗑️ Deleted old document: $oldDocId');
      
      return true;
    } catch (e) {
      print('❌ Error updating market price with market change: $e');
      return false;
    }
  }

  /// Helper method to delete a document and all its subcollections
  Future<void> _deleteDocumentWithSubcollections(String docId) async {
    try {
      // Delete all price_history entries
      final historySnapshot = await _marketPricesRef
          .doc(docId)
          .collection('price_history')
          .get();
      
      final batch = _firestore.batch();
      for (final doc in historySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the parent document
      batch.delete(_marketPricesRef.doc(docId));
      
      await batch.commit();
    } catch (e) {
      print('Error deleting document with subcollections: $e');
      rethrow;
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

  // ============================================================================
  // AI FORECASTING METHODS
  // ============================================================================

  /// Get the next Monday date (forecast date)
  /// If today is Monday, returns today. Otherwise returns the upcoming Monday.
  DateTime _getNextMonday() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // Monday = 1, Tuesday = 2, ..., Sunday = 7
    
    // Calculate days until next Monday
    // If today is Monday (1), daysToAdd = 0
    // If today is Tuesday (2), daysToAdd = 6 (to next Monday)
    // If today is Sunday (7), daysToAdd = 1 (to next Monday)
    int daysToAdd;
    if (currentWeekday == DateTime.monday) {
      daysToAdd = 0; // Today is Monday
    } else {
      daysToAdd = (DateTime.monday - currentWeekday + 7) % 7;
    }
    
    final nextMonday = now.add(Duration(days: daysToAdd));
    return DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
  }

  /// Get all forecasted prices for the next Monday
  Future<Map<String, List<Map<String, dynamic>>>> getForecastedPrices() async {
    try {
      final nextMonday = _getNextMonday();
      final dateStr = '${nextMonday.year}-${nextMonday.month.toString().padLeft(2, '0')}-${nextMonday.day.toString().padLeft(2, '0')}';
      
      print('🔍 DEBUG: Fetching forecasts for date: $dateStr');
      
      // NOTE: Parent document doesn't need to exist in Firestore for subcollections to exist
      // We query subcollections directly
      final Map<String, List<Map<String, dynamic>>> forecasts = {};
      
      // Categories from backend: livestock_and_poultry, rice, vegetables_highland, vegetables_lowland, fruits, fish, corn
      final categories = ['livestock_and_poultry', 'rice', 'vegetables_highland', 'vegetables_lowland', 'fruits', 'fish', 'corn'];
      
      for (final category in categories) {
        final categorySnapshot = await _forecastedPricesRef
            .doc(dateStr)
            .collection(category)
            .get();
        
        print('🔍 DEBUG: Category "$category" has ${categorySnapshot.docs.length} products');
        
        if (categorySnapshot.docs.isNotEmpty) {
          final products = categorySnapshot.docs.map((doc) {
            final data = doc.data();
            print('🔍 DEBUG: Product "${doc.id}" data: $data');
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
          
          forecasts[category] = products;
        }
      }
      
      print('🔍 DEBUG: Total forecasts loaded: ${forecasts.length} categories');
      return forecasts;
    } catch (e) {
      print('❌ ERROR getting forecasted prices: $e');
      return {};
    }
  }

  /// Get top price movers (products with highest % change) for alerts
  Future<List<Map<String, dynamic>>> getTopPriceMovers({int limit = 10}) async {
    try {
      print('🔍 DEBUG: Starting getTopPriceMovers...');
      final forecasts = await getForecastedPrices();
      print('🔍 DEBUG: Forecasts loaded: ${forecasts.length} categories');
      
      final List<Map<String, dynamic>> movers = [];
      
      for (final categoryEntry in forecasts.entries) {
        final category = categoryEntry.key;
        final products = categoryEntry.value;
        
        print('🔍 DEBUG: Processing category "$category" with ${products.length} products');
        
        for (final product in products) {
          print('🔍 DEBUG: Product data: $product');
          
          final productName = product['product_name'] as String?;
          final forecastedPrice = (product['forecasted_price'] as num?)?.toDouble();
          final trend = product['trend'] as String?;
          
          if (productName == null) {
            print('⚠️ WARNING: Product has no product_name field, using id: ${product['id']}');
            // Use document ID as product name if product_name field is missing
            final idAsName = (product['id'] as String?)?.replaceAll('_', ' ').split(' ').map((word) => 
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
            ).join(' ');
            
            if (idAsName == null || forecastedPrice == null) continue;
            
            product['product_name'] = idAsName;
          }
          
          if (forecastedPrice == null) {
            print('⚠️ WARNING: Product "${product['product_name']}" has no forecasted_price');
            continue;
          }
          
          // Get current price for comparison
          final currentPriceData = await _findCurrentPrice(category, product['product_name'] as String);
          if (currentPriceData == null) {
            print('⚠️ WARNING: No current price found for "${product['product_name']}"');
            continue;
          }
          
          // Convert to double safely (handles both int and double from Firebase)
          final currentPrice = (currentPriceData['price_min'] as num?)?.toDouble();
          if (currentPrice == null) {
            print('⚠️ WARNING: Invalid price_min for "${product['product_name']}"');
            continue;
          }
          
          final priceChange = forecastedPrice - currentPrice;
          final percentChange = (priceChange / currentPrice) * 100;
          
          print('✅ Added mover: ${product['product_name']} - ${percentChange.toStringAsFixed(1)}% change');
          
          movers.add({
            'product': product['product_name'],
            'category': _formatCategoryName(category),
            'current_price': currentPrice,
            'forecasted_price': forecastedPrice,
            'price_change': priceChange,
            'percent_change': percentChange,
            'trend': trend ?? 'stable',
            'confidence': product['confidence'] ?? 'medium',
            'isIncrease': percentChange > 0,
          });
        }
      }
      
      print('🔍 DEBUG: Total movers found: ${movers.length}');
      
      // Sort by absolute percent change
      movers.sort((a, b) => 
        (b['percent_change'] as double).abs().compareTo((a['percent_change'] as double).abs())
      );
      
      print('✅ Returning top ${limit} movers');
      return movers.take(limit).toList();
    } catch (e) {
      print('❌ ERROR getting top price movers: $e');
      return [];
    }
  }

  /// Get forecasted prices for specific category
  Future<List<Map<String, dynamic>>> getForecastsByCategory(String category) async {
    try {
      final nextMonday = _getNextMonday();
      final dateStr = '${nextMonday.year}-${nextMonday.month.toString().padLeft(2, '0')}-${nextMonday.day.toString().padLeft(2, '0')}';
      
      final categorySnapshot = await _forecastedPricesRef
          .doc(dateStr)
          .collection(category)
          .get();
      
      final List<Map<String, dynamic>> forecasts = [];
      
      for (final doc in categorySnapshot.docs) {
        final data = doc.data();
        final productName = data['product_name'] as String?;
        final forecastedPrice = (data['forecasted_price'] as num?)?.toDouble();
        
        if (productName == null || forecastedPrice == null) continue;
        
        // Get current price for comparison
        final currentPriceData = await _findCurrentPrice(category, productName);
        final currentPrice = (currentPriceData?['price_min'] as num?)?.toDouble() ?? 0.0;
        
        forecasts.add({
          'id': doc.id,
          'product_name': productName,
          'forecasted_price': forecastedPrice,
          'current_price': currentPrice,
          'trend': data['trend'] ?? 'stable',
          'confidence': data['confidence'] ?? 'medium',
          'forecast_date': data['forecast_date'] ?? dateStr,
          'last_updated': data['last_updated'],
          'model_version': data['model_version'],
        });
      }
      
      return forecasts;
    } catch (e) {
      print('Error getting forecasts by category: $e');
      return [];
    }
  }

  /// Helper: Find current price for a product in a category
  Future<Map<String, dynamic>?> _findCurrentPrice(String category, String productName) async {
    try {
      final snapshot = await _marketPricesRef
          .where('category', isEqualTo: _formatCategoryName(category))
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docProductName = data['product_name'] as String?;
        
        if (docProductName != null && 
            docProductName.toLowerCase().contains(productName.toLowerCase())) {
          return {
            'id': doc.id,
            ...data,
          };
        }
      }
      
      return null;
    } catch (e) {
      print('Error finding current price: $e');
      return null;
    }
  }

  /// Helper: Format backend category names to display names
  String _formatCategoryName(String category) {
    switch (category) {
      case 'livestock_and_poultry':
        return 'Livestock & Poultry';
      case 'vegetables_highland':
        return 'Highland Vegetables';
      case 'vegetables_lowland':
        return 'Lowland Vegetables';
      case 'rice':
        return 'Rice';
      case 'fruits':
        return 'Fruits';
      case 'fish':
        return 'Fish';
      case 'corn':
        return 'Corn';
      default:
        return category;
    }
  }
}
