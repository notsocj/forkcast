# Market Price Service - Quick API Reference

## Import
```dart
import 'package:forkcast/services/market_price_service.dart';
import 'package:forkcast/models/market_price.dart';
```

## Initialize
```dart
final marketPriceService = MarketPriceService();
```

---

## 📖 Read Operations

### Get Latest Price
```dart
final price = await marketPriceService.getLatestPrice(
  'Fish',              // category
  'Tilapia',           // product name
  'R.A Calalay City-Owned Market'  // market name
);
// Returns: Map<String, dynamic>? with all price fields
```

### Stream Prices by Category
```dart
marketPriceService.getPricesByCategory('Fish').listen((prices) {
  for (var price in prices) {
    print('${price['product_name']}: ₱${price['price_min']}');
  }
});
// Returns: Stream<List<Map<String, dynamic>>>
```

### Get All Categories
```dart
final categories = await marketPriceService.getAllCategories();
// Returns: List<String> - ["Fish", "Fruits", "Vegetables", ...]
```

### Search Products
```dart
final results = await marketPriceService.searchProducts('tilapia');
// Returns: List<Map<String, dynamic>> matching query
```

### Get Price History
```dart
final history = await marketPriceService.getPriceHistory(
  'Fish',
  'Tilapia',
  'R.A Calalay City-Owned Market',
  limit: 30,  // optional, default: 30
);
// Returns: List<Map<String, dynamic>> ordered by date (newest first)
```

### Stream Price History (Real-time)
```dart
marketPriceService.getPriceHistoryStream(
  'Fish',
  'Tilapia',
  'R.A Calalay City-Owned Market',
  limit: 30,
).listen((history) {
  // Update price chart in real-time
});
// Returns: Stream<List<Map<String, dynamic>>>
```

---

## ✏️ Write Operations

### Add/Update Market Price
```dart
await marketPriceService.updateMarketPrice(
  category: 'Fish',
  productName: 'Tilapia',
  marketName: 'R.A Calalay City-Owned Market',
  unit: 'Kilogram',
  priceMin: 145.00,
  sourceType: 'City-Owned Market',
  isImported: false,  // optional, default: false
);
// Returns: bool (success/failure)
// Also automatically adds entry to price_history
```

### Add Forecasted Prices
```dart
await marketPriceService.addForecastedPrices(
  'Fish',
  'Tilapia',
  'R.A Calalay City-Owned Market',
  [
    {
      'date': DateTime(2025, 10, 15),
      'price': 142.50,
      'confidence': 0.87,
    },
    {
      'date': DateTime(2025, 10, 22),
      'price': 143.25,
      'confidence': 0.82,
    },
  ],
  modelVersion: 'ARIMA_v1.0',
);
// Returns: bool (success/failure)
```

### Batch Update Prices (Import/Migration)
```dart
await marketPriceService.batchUpdatePrices([
  {
    'category': 'Fish',
    'product_name': 'Tilapia',
    'market_name': 'R.A Calalay City-Owned Market',
    'unit': 'Kilogram',
    'price_min': 140.00,
    'source_type': 'City-Owned Market',
    'is_imported': false,
  },
  // ... more prices
]);
// Returns: bool (success/failure)
```

---

## 📊 Analytics Operations

### Calculate Price Change
```dart
final changePercent = await marketPriceService.getPriceChangePercentage(
  'Fish',
  'Tilapia',
  'R.A Calalay City-Owned Market',
);
// Returns: double? - percentage change (e.g., 15.5 for 15.5% increase)
// Positive = increase, Negative = decrease, null = insufficient data
```

### Get Price Alerts
```dart
final alerts = await marketPriceService.getPriceAlerts(
  threshold: 10.0,  // optional, default: 10.0%
);
// Returns: List<Map<String, dynamic>> with price_change_percent and alert_type
```

---

## 🤖 Forecast Model Operations

### Create Forecast Model
```dart
final modelId = await marketPriceService.createForecastModel(
  modelName: 'Linear Regression',
  modelVersion: 'v1.0',
  accuracy: 0.85,  // 85% accuracy
  featuresUsed: ['date', 'price', 'category', 'season'],
  deployed: true,  // optional, default: false
);
// Returns: String? - document ID of created model
```

### Get All Forecast Models
```dart
final models = await marketPriceService.getAllForecastModels();
// Returns: List<Map<String, dynamic>> ordered by trained_at (newest first)
```

### Get Deployed Model
```dart
final activeModel = await marketPriceService.getDeployedModel();
// Returns: Map<String, dynamic>? - currently deployed model or null
```

---

## 🎨 Using Model Classes

### MarketPrice Model
```dart
final marketPrice = MarketPrice.fromMap(priceData, docId);

// Access properties
print(marketPrice.productName);     // "Tilapia"
print(marketPrice.priceMin);        // 140.00
print(marketPrice.formattedPrice);  // "₱140.00"
print(marketPrice.categoryIcon);    // "🐟"
print(marketPrice.sourceTypeIcon);  // "🏛️"

// Convert back to Map
final data = marketPrice.toMap();
```

### PriceHistoryEntry Model
```dart
final entry = PriceHistoryEntry.fromMap(historyData, docId);

print(entry.date);                  // DateTime
print(entry.price);                 // 142.50
print(entry.formattedPrice);        // "₱142.50"
print(entry.isForecasted);          // true
print(entry.entryType);             // "Forecast"
print(entry.confidencePercent);     // "87%"
```

### ForecastModel Model
```dart
final model = ForecastModel.fromMap(modelData, docId);

print(model.modelName);             // "Linear Regression"
print(model.modelVersion);          // "v1.0"
print(model.displayName);           // "Linear Regression v1.0"
print(model.accuracyPercent);       // "85.0%"
print(model.deploymentStatus);      // "Active"
print(model.featuresUsed);          // ["date", "price", "category"]
```

### PriceAlert Model
```dart
final alert = PriceAlert(
  marketPrice: marketPrice,
  priceChangePercent: 15.5,
  alertType: 'increase',
);

print(alert.severity);              // "medium"
print(alert.icon);                  // "📈"
print(alert.message);               // "Tilapia price increased by 15.5%"
print(alert.formattedChange);       // "+15.5%"
```

---

## 🔤 Enum Values

### Source Types
- `"City-Owned Market"`
- `"Private Market"`
- `"Public Market"`

### Alert Types
- `"increase"` - Price went up
- `"decrease"` - Price went down

### Alert Severity
- `"high"` - ≥20% change
- `"medium"` - 10-19% change
- `"low"` - <10% change

---

## 💡 Common Patterns

### Load Category Prices for Dashboard
```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: marketPriceService.getPricesByCategory('Fish'),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final prices = snapshot.data!;
    return ListView.builder(
      itemCount: prices.length,
      itemBuilder: (context, index) {
        final price = prices[index];
        return ListTile(
          title: Text(price['product_name']),
          subtitle: Text(price['market_name']),
          trailing: Text('₱${price['price_min']}'),
        );
      },
    );
  },
)
```

### Display Price Trend Chart
```dart
final history = await marketPriceService.getPriceHistory(
  'Fish', 'Tilapia', 'R.A Calalay City-Owned Market',
  limit: 30,
);

final chartData = history.map((entry) {
  return FlSpot(
    entry['date'].millisecondsSinceEpoch.toDouble(),
    entry['price'],
  );
}).toList();

// Use chartData with fl_chart package
```

### Check for Price Alerts
```dart
final alerts = await marketPriceService.getPriceAlerts(threshold: 15.0);

if (alerts.isNotEmpty) {
  for (var alert in alerts) {
    showNotification(
      title: 'Price Alert!',
      body: '${alert['product_name']} ${alert['alert_type']} by ${alert['price_change_percent'].abs()}%',
    );
  }
}
```

### Admin Price Update Form
```dart
await marketPriceService.updateMarketPrice(
  category: categoryController.text,
  productName: productNameController.text,
  marketName: marketNameController.text,
  unit: unitController.text,
  priceMin: double.parse(priceController.text),
  sourceType: sourceTypeDropdown.value,
  isImported: isImportedCheckbox.value,
);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Price updated successfully!')),
);
```

---

## 🚨 Error Handling

All methods return `null`, `false`, or empty collections on error and print error messages to console:

```dart
try {
  final price = await marketPriceService.getLatestPrice('Fish', 'Tilapia', 'Market');
  if (price == null) {
    print('Price not found');
  }
} catch (e) {
  print('Error getting price: $e');
}
```

---

## 📚 See Also
- `MARKET_PRICES_IMPLEMENTATION.md` - Complete system documentation
- `firebase_structure.instructions.md` - Database schema
- `lib/models/market_price.dart` - Model class definitions
- `lib/services/market_price_service.dart` - Full service implementation
