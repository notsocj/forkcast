# Market Prices & Forecasting System - Complete Implementation Guide

## Overview
Complete Firebase-based market price tracking and forecasting system for ForkCast, designed to monitor real-time prices from Quezon City markets and support ML-driven price predictions for budget-aware meal planning.

## Implementation Date
October 8, 2025

---

## 🏗️ Firebase Structure

### Collection: `market_prices`
**Purpose**: Store latest prices for each product from Quezon City markets

**Document ID Format**: `{category}_{product_name}_{market_name}`
- Example: `fish_tilapia_ra_calalay`
- Composite key ensures unique product-market combinations
- Sanitized (lowercase, underscores, no special chars)

**Fields**:
```typescript
{
  category: string,              // e.g., "Fish", "Fruits", "Corn"
  product_name: string,          // e.g., "Tilapia", "Premium Rice"
  unit: string,                  // e.g., "Kilogram", "PC", "ML", "L"
  price_min: number (double),    // Lowest recorded price in PHP
  market_name: string,           // e.g., "R.A Calalay City-Owned Market"
  collected_at: timestamp,       // Date/time price was recorded
  source_type: string,           // "City-Owned Market" | "Private Market" | "Public Market"
  is_imported: boolean,          // true for imported products (e.g., commercial rice)
  last_updated: timestamp        // Auto-generated update time
}
```

**Example Document**:
```
market_prices/fish_tilapia_ra_calalay
{
  category: "Fish",
  product_name: "Tilapia",
  unit: "Kilogram",
  price_min: 140.00,
  market_name: "R.A Calalay City-Owned Market",
  collected_at: 2025-10-08T00:00:00Z,
  source_type: "City-Owned Market",
  is_imported: false,
  last_updated: 2025-10-08T12:00:00Z
}
```

### Subcollection: `price_history`
**Purpose**: Store historical prices for trend analysis and forecasting

**Parent**: `market_prices/{marketPriceId}`
**Document ID Format**: Date string (YYYY-MM-DD)
- Example: `2025-10-08`

**Fields**:
```typescript
{
  date: timestamp,               // Date of price record
  price: number (double),        // Price in PHP
  market_name: string,           // Market where data was gathered
  is_forecasted: boolean,        // true if ML-generated prediction
  model_version?: string,        // Optional: ML model version (e.g., "v1.0")
  forecast_confidence?: number   // Optional: Confidence level (0-1)
}
```

**Example Documents**:
```
market_prices/fish_tilapia_ra_calalay/price_history/
  2025-10-08:
    date: 2025-10-08T00:00:00Z
    price: 140.00
    market_name: "R.A Calalay City-Owned Market"
    is_forecasted: false
  
  2025-10-15:
    date: 2025-10-15T00:00:00Z
    price: 142.50
    market_name: "R.A Calalay City-Owned Market"
    is_forecasted: true
    model_version: "v1.0"
    forecast_confidence: 0.87
```

### Collection: `forecast_models`
**Purpose**: Track ML models for price forecasting

**Document ID**: Auto-generated or custom
**Fields**:
```typescript
{
  model_name: string,            // e.g., "Linear Regression", "ARIMA", "LSTM"
  model_version: string,         // e.g., "v1.0", "v2.1"
  trained_at: timestamp,         // When model was trained
  accuracy: number (double),     // Mean accuracy (MAPE or RMSE)
  features_used: array<string>,  // e.g., ["date", "price", "category"]
  deployed: boolean              // true if currently active
}
```

---

## 💻 Service Implementation

### File: `lib/services/market_price_service.dart`

#### Core Methods

**1. Get Latest Price**
```dart
Future<Map<String, dynamic>?> getLatestPrice(
  String category, 
  String productName, 
  String marketName
)
```
Returns current price data for a specific product.

**2. Get Prices by Category**
```dart
Stream<List<Map<String, dynamic>>> getPricesByCategory(String category)
```
Real-time stream of all products in a category (e.g., "Fish", "Fruits").

**3. Search Products**
```dart
Future<List<Map<String, dynamic>>> searchProducts(String query)
```
Search products by name or category across all markets.

**4. Update Market Price**
```dart
Future<bool> updateMarketPrice({
  required String category,
  required String productName,
  required String marketName,
  required String unit,
  required double priceMin,
  required String sourceType,
  bool isImported = false,
})
```
Add or update a product price. Automatically adds entry to price_history.

**5. Get Price History**
```dart
Future<List<Map<String, dynamic>>> getPriceHistory(
  String category,
  String productName,
  String marketName,
  {int limit = 30}
)
```
Retrieve historical prices for trend analysis and charts.

**6. Price Change Calculation**
```dart
Future<double?> getPriceChangePercentage(
  String category,
  String productName,
  String marketName
)
```
Calculate percentage change between latest and previous price.

**7. Price Alerts**
```dart
Future<List<Map<String, dynamic>>> getPriceAlerts({double threshold = 10.0})
```
Get products with significant price changes (default: ≥10% change).

**8. Add Forecasted Prices**
```dart
Future<bool> addForecastedPrices(
  String category,
  String productName,
  String marketName,
  List<Map<String, dynamic>> forecasts,
  {required String modelVersion}
)
```
Add ML-generated price predictions to price_history.

**9. Forecast Model Management**
```dart
// Create new model
Future<String?> createForecastModel({
  required String modelName,
  required String modelVersion,
  required double accuracy,
  required List<String> featuresUsed,
  bool deployed = false,
})

// Get all models
Future<List<Map<String, dynamic>>> getAllForecastModels()

// Get active model
Future<Map<String, dynamic>?> getDeployedModel()
```

**10. Batch Operations**
```dart
Future<bool> batchUpdatePrices(List<Map<String, dynamic>> prices)
```
Bulk import/migration support for multiple price updates.

---

## 🎨 Model Classes

### File: `lib/models/market_price.dart`

#### 1. MarketPrice
Represents a product price entry.

**Properties**:
```dart
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
  
  // Helper methods
  String get formattedPrice;      // "₱140.00"
  String get sourceTypeIcon;      // 🏛️ 🏪 🛒
  String get categoryIcon;        // 🐟 🍎 🥬
}
```

**Serialization**:
```dart
// From Firestore
MarketPrice.fromFirestore(DocumentSnapshot doc)
MarketPrice.fromMap(Map<String, dynamic> data, String id)

// To Firestore
Map<String, dynamic> toMap()
```

#### 2. PriceHistoryEntry
Represents historical price point or forecast.

**Properties**:
```dart
class PriceHistoryEntry {
  final String id;
  final DateTime date;
  final double price;
  final String marketName;
  final bool isForecasted;
  final String? modelVersion;
  final double? forecastConfidence;
  
  // Helper methods
  String get formattedPrice;      // "₱142.50"
  String? get confidencePercent;  // "87%"
  String get entryType;           // "Forecast" or "Actual"
}
```

#### 3. ForecastModel
Represents ML model metadata.

**Properties**:
```dart
class ForecastModel {
  final String id;
  final String modelName;
  final String modelVersion;
  final DateTime trainedAt;
  final double accuracy;
  final List<String> featuresUsed;
  final bool deployed;
  
  // Helper methods
  String get accuracyPercent;     // "85.5%"
  String get deploymentStatus;    // "Active" or "Inactive"
  String get displayName;         // "Linear Regression v1.0"
}
```

#### 4. PriceAlert
Represents significant price change notification.

**Properties**:
```dart
class PriceAlert {
  final MarketPrice marketPrice;
  final double priceChangePercent;
  final String alertType;         // "increase" or "decrease"
  
  // Helper methods
  String get severity;            // "high", "medium", "low"
  String get icon;                // ⚠️ 📈 📉
  String get message;             // "Tilapia price increased by 15.5%"
  String get formattedChange;     // "+15.5%"
}
```

---

## 📊 Usage Examples

### 1. Get Latest Prices for Dashboard
```dart
final service = MarketPriceService();

// Get all fish prices
service.getPricesByCategory('Fish').listen((prices) {
  for (var price in prices) {
    print('${price['product_name']}: ₱${price['price_min']}');
  }
});
```

### 2. Search for Products
```dart
final results = await service.searchProducts('tilapia');
for (var product in results) {
  print('${product['category']} - ${product['product_name']}: ₱${product['price_min']}');
}
```

### 3. Update a Price
```dart
await service.updateMarketPrice(
  category: 'Fish',
  productName: 'Tilapia',
  marketName: 'R.A Calalay City-Owned Market',
  unit: 'Kilogram',
  priceMin: 145.00,
  sourceType: 'City-Owned Market',
);
```

### 4. Get Price History for Chart
```dart
final history = await service.getPriceHistory(
  'Fish',
  'Tilapia',
  'R.A Calalay City-Owned Market',
  limit: 30,
);

// Use history data for price trend chart
for (var entry in history) {
  final date = (entry['date'] as Timestamp).toDate();
  final price = entry['price'];
  final isForecast = entry['is_forecasted'];
  // Plot data...
}
```

### 5. Check Price Alerts
```dart
final alerts = await service.getPriceAlerts(threshold: 15.0);

for (var alert in alerts) {
  final change = alert['price_change_percent'];
  final type = alert['alert_type'];
  print('⚠️ ${alert['product_name']}: $type by ${change.abs()}%');
}
```

### 6. Add ML Forecasts
```dart
final forecasts = [
  {
    'date': DateTime.now().add(Duration(days: 1)),
    'price': 142.50,
    'confidence': 0.87,
  },
  {
    'date': DateTime.now().add(Duration(days: 2)),
    'price': 143.25,
    'confidence': 0.82,
  },
];

await service.addForecastedPrices(
  'Fish',
  'Tilapia',
  'R.A Calalay City-Owned Market',
  forecasts,
  modelVersion: 'v1.0',
);
```

---

## 🔄 Data Flow

### Price Update Workflow
```
1. User/Admin enters new market price
   ↓
2. MarketPriceService.updateMarketPrice()
   ↓
3. Update market_prices document
   ↓
4. Add entry to price_history subcollection
   ↓
5. Calculate price change percentage
   ↓
6. Trigger alert if change > threshold
```

### Forecasting Workflow
```
1. ML model generates price predictions
   ↓
2. MarketPriceService.addForecastedPrices()
   ↓
3. Add forecasted entries to price_history
   ↓
4. Mark entries with is_forecasted: true
   ↓
5. Include model_version and confidence
   ↓
6. Display forecast data in dashboard
```

---

## 📈 Features & Benefits

### Real-Time Price Tracking
- ✅ Live price updates from Quezon City markets
- ✅ Multiple market source support (City-Owned, Private, Public)
- ✅ Product categorization (Fish, Fruits, Vegetables, etc.)
- ✅ Imported product identification

### Historical Analysis
- ✅ 30-day price history by default
- ✅ Trend visualization support
- ✅ Price change percentage calculation
- ✅ Historical vs forecasted data distinction

### Forecasting Integration
- ✅ ML model versioning and tracking
- ✅ Confidence scoring for predictions
- ✅ Model accuracy metrics (MAPE, RMSE)
- ✅ Deployment status management

### Price Alerts
- ✅ Configurable threshold (default: 10%)
- ✅ Increase/decrease classification
- ✅ Severity levels (high, medium, low)
- ✅ Notification-ready alert system

### Budget Planning
- ✅ Find lowest prices across markets
- ✅ Price comparison by product
- ✅ 7-day forecast for meal planning
- ✅ Category-based price monitoring

---

## 🔮 Future Enhancements

### Phase 1: Enhanced ML Integration
- [ ] ARIMA time-series forecasting
- [ ] LSTM deep learning models
- [ ] Seasonal price pattern detection
- [ ] Weather impact correlation

### Phase 2: Advanced Analytics
- [ ] Market price comparison dashboard
- [ ] Best value recommendations
- [ ] Budget optimization suggestions
- [ ] Supply shortage predictions

### Phase 3: User Features
- [ ] Favorite products tracking
- [ ] Custom price alerts
- [ ] Shopping list with live prices
- [ ] Nearby market locator

### Phase 4: Data Expansion
- [ ] More Quezon City markets
- [ ] Metro Manila market coverage
- [ ] Regional price comparisons
- [ ] Nutritional value per peso metric

---

## 📝 Related Documentation
- `firebase_structure.instructions.md` - Complete Firebase schema
- `implementation_checklist.instructions.md` - Development progress tracking
- `CLOUDINARY_IMAGE_INTEGRATION_SUMMARY.md` - Image handling guide

---

## 🎯 Conclusion
The market prices and forecasting system provides a robust foundation for:
- **Budget-Aware Meal Planning**: Users can plan meals based on current and predicted prices
- **Price Transparency**: Real-time visibility into Quezon City market prices
- **Smart Recommendations**: ML-driven forecasts help users make informed shopping decisions
- **Financial Wellness**: Helps users maximize nutrition within budget constraints

This system is fully integrated with the FNRI-based meal planning system, enabling ForkCast to deliver truly personalized, health-conscious, and budget-friendly meal recommendations. 🍽️💰📊
