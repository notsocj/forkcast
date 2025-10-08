import 'package:cloud_firestore/cloud_firestore.dart';

/// Market Price Model
/// Represents a product price entry from Quezon City markets
class MarketPrice {
  final String id;
  final String category;
  final String productName;
  final String unit;
  final double priceMin;
  final String marketName;
  final DateTime collectedAt;
  final String sourceType;
  final bool isImported;
  final DateTime lastUpdated;

  MarketPrice({
    required this.id,
    required this.category,
    required this.productName,
    required this.unit,
    required this.priceMin,
    required this.marketName,
    required this.collectedAt,
    required this.sourceType,
    required this.isImported,
    required this.lastUpdated,
  });

  /// Create MarketPrice from Firestore document
  factory MarketPrice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketPrice.fromMap(data, doc.id);
  }

  /// Create MarketPrice from Map
  factory MarketPrice.fromMap(Map<String, dynamic> data, String id) {
    return MarketPrice(
      id: id,
      category: data['category'] as String? ?? '',
      productName: data['product_name'] as String? ?? '',
      unit: data['unit'] as String? ?? '',
      priceMin: (data['price_min'] as num?)?.toDouble() ?? 0.0,
      marketName: data['market_name'] as String? ?? '',
      collectedAt: (data['collected_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sourceType: data['source_type'] as String? ?? 'Public Market',
      isImported: data['is_imported'] as bool? ?? false,
      lastUpdated: (data['last_updated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'product_name': productName,
      'unit': unit,
      'price_min': priceMin,
      'market_name': marketName,
      'collected_at': Timestamp.fromDate(collectedAt),
      'source_type': sourceType,
      'is_imported': isImported,
      'last_updated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Get formatted price string
  String get formattedPrice => '₱${priceMin.toStringAsFixed(2)}';

  /// Get source type icon
  String get sourceTypeIcon {
    switch (sourceType) {
      case 'City-Owned Market':
        return '🏛️';
      case 'Private Market':
        return '🏪';
      case 'Public Market':
        return '🛒';
      default:
        return '📍';
    }
  }

  /// Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'fish':
        return '🐟';
      case 'fruits':
        return '🍎';
      case 'vegetables':
      case 'highland vegetables':
        return '🥬';
      case 'corn':
        return '🌽';
      case 'rice':
        return '🍚';
      case 'meat':
        return '🥩';
      case 'poultry':
        return '🍗';
      case 'eggs':
        return '🥚';
      default:
        return '🛒';
    }
  }
}

/// Price History Entry Model
/// Represents a historical price point or forecast
class PriceHistoryEntry {
  final String id;
  final DateTime date;
  final double price;
  final String marketName;
  final bool isForecasted;
  final String? modelVersion;
  final double? forecastConfidence;

  PriceHistoryEntry({
    required this.id,
    required this.date,
    required this.price,
    required this.marketName,
    required this.isForecasted,
    this.modelVersion,
    this.forecastConfidence,
  });

  /// Create from Firestore document
  factory PriceHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PriceHistoryEntry.fromMap(data, doc.id);
  }

  /// Create from Map
  factory PriceHistoryEntry.fromMap(Map<String, dynamic> data, String id) {
    return PriceHistoryEntry(
      id: id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      marketName: data['market_name'] as String? ?? '',
      isForecasted: data['is_forecasted'] as bool? ?? false,
      modelVersion: data['model_version'] as String?,
      forecastConfidence: (data['forecast_confidence'] as num?)?.toDouble(),
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'price': price,
      'market_name': marketName,
      'is_forecasted': isForecasted,
      if (modelVersion != null) 'model_version': modelVersion,
      if (forecastConfidence != null) 'forecast_confidence': forecastConfidence,
    };
  }

  /// Get formatted price
  String get formattedPrice => '₱${price.toStringAsFixed(2)}';

  /// Get confidence percentage
  String? get confidencePercent {
    if (forecastConfidence == null) return null;
    return '${(forecastConfidence! * 100).toStringAsFixed(0)}%';
  }

  /// Get entry type label
  String get entryType => isForecasted ? 'Forecast' : 'Actual';
}

/// Forecast Model
/// Represents a machine learning model used for price predictions
class ForecastModel {
  final String id;
  final String modelName;
  final String modelVersion;
  final DateTime trainedAt;
  final double accuracy;
  final List<String> featuresUsed;
  final bool deployed;

  ForecastModel({
    required this.id,
    required this.modelName,
    required this.modelVersion,
    required this.trainedAt,
    required this.accuracy,
    required this.featuresUsed,
    required this.deployed,
  });

  /// Create from Firestore document
  factory ForecastModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForecastModel.fromMap(data, doc.id);
  }

  /// Create from Map
  factory ForecastModel.fromMap(Map<String, dynamic> data, String id) {
    return ForecastModel(
      id: id,
      modelName: data['model_name'] as String? ?? '',
      modelVersion: data['model_version'] as String? ?? '',
      trainedAt: (data['trained_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
      featuresUsed: List<String>.from(data['features_used'] as List? ?? []),
      deployed: data['deployed'] as bool? ?? false,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'model_name': modelName,
      'model_version': modelVersion,
      'trained_at': Timestamp.fromDate(trainedAt),
      'accuracy': accuracy,
      'features_used': featuresUsed,
      'deployed': deployed,
    };
  }

  /// Get accuracy percentage
  String get accuracyPercent => '${(accuracy * 100).toStringAsFixed(1)}%';

  /// Get deployment status
  String get deploymentStatus => deployed ? 'Active' : 'Inactive';

  /// Get model display name
  String get displayName => '$modelName $modelVersion';
}

/// Price Alert Model
/// Represents a significant price change notification
class PriceAlert {
  final MarketPrice marketPrice;
  final double priceChangePercent;
  final String alertType; // 'increase' or 'decrease'

  PriceAlert({
    required this.marketPrice,
    required this.priceChangePercent,
    required this.alertType,
  });

  /// Get alert severity (based on price change magnitude)
  String get severity {
    final absChange = priceChangePercent.abs();
    if (absChange >= 20) return 'high';
    if (absChange >= 10) return 'medium';
    return 'low';
  }

  /// Get alert icon
  String get icon {
    if (alertType == 'increase') {
      return priceChangePercent >= 20 ? '⚠️' : '📈';
    } else {
      return priceChangePercent.abs() >= 20 ? '⬇️' : '📉';
    }
  }

  /// Get alert message
  String get message {
    final direction = alertType == 'increase' ? 'increased' : 'decreased';
    return '${marketPrice.productName} price $direction by ${priceChangePercent.abs().toStringAsFixed(1)}%';
  }

  /// Get formatted change
  String get formattedChange {
    final sign = priceChangePercent > 0 ? '+' : '';
    return '$sign${priceChangePercent.toStringAsFixed(1)}%';
  }
}
