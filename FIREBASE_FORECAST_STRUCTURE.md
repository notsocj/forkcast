# Firebase Forecast Data Structure Guide

## Collection Path
```
forecasted_market_prices/{date}/{category}/{product_id}
```

## Example Document Path
```
forecasted_market_prices/2025-10-13/corn/grits_feed_grade
```

## Required Fields in Each Product Document

Each product document (e.g., `grits_feed_grade`) **MUST** contain these fields:

```json
{
  "product_name": "Grits Feed Grade",
  "forecasted_price": 45.50,
  "trend": "increasing",
  "confidence": "high",
  "forecast_date": "2025-10-13",
  "last_updated": "2025-10-12T23:59:00Z",
  "model_version": "v1.0"
}
```

### Field Descriptions

| Field | Type | Description | Example Values |
|-------|------|-------------|----------------|
| `product_name` | string | Display name of the product | "Grits Feed Grade", "Tilapia", "Banana Lakatan" |
| `forecasted_price` | number | Predicted price in PHP | 45.50, 120.00, 85.75 |
| `trend` | string | Price movement direction | "increasing", "decreasing", "stable" |
| `confidence` | string | Model confidence level | "high", "medium", "low" |
| `forecast_date` | string | Date of the forecast (YYYY-MM-DD) | "2025-10-13" |
| `last_updated` | string | When forecast was generated | "2025-10-12T23:59:00Z" |
| `model_version` | string | ML model version used | "v1.0", "v1.1", "ARIMA-v2" |

## Complete Example: Corn Category

```
forecasted_market_prices/2025-10-13/corn/
├── grits_feed_grade
│   └── { product_name: "Grits Feed Grade", forecasted_price: 45.50, trend: "increasing", ... }
├── white_glutinous
│   └── { product_name: "White Glutinous", forecasted_price: 52.00, trend: "stable", ... }
├── white_grits_food_grade
│   └── { product_name: "White Grits Food Grade", forecasted_price: 48.75, trend: "decreasing", ... }
├── yellow_cracked_feed_grade
│   └── { product_name: "Yellow Cracked Feed Grade", forecasted_price: 43.25, trend: "increasing", ... }
├── yellow_grits_food_grade
│   └── { product_name: "Yellow Grits Food Grade", forecasted_price: 47.50, trend: "stable", ... }
└── yellow_sweet
    └── { product_name: "Yellow Sweet", forecasted_price: 55.00, trend: "increasing", ... }
```

## All Categories

1. **corn** - 6 products
2. **fish** - 10 products
3. **fruits** - 5 products
4. **livestock_and_poultry** - 15 products
5. **rice** - 4 products
6. **vegetables_highland** - 11 products
7. **vegetables_lowland** - 6 products

## Important Notes

1. **No Parent Document Required**: The parent document `/forecasted_market_prices/2025-10-13` does NOT need to exist in Firestore. Subcollections can exist independently.

2. **Product Name Formatting**: If `product_name` field is missing, the app will use the document ID (e.g., `grits_feed_grade` → "Grits Feed Grade").

3. **Current Price Lookup**: The app compares `forecasted_price` with current prices from the `market_prices` collection using `product_name` matching.

4. **Date Format**: Always use `YYYY-MM-DD` format (e.g., `2025-10-13`) for date document IDs.

5. **Trend Values**: Only use: `"increasing"`, `"decreasing"`, or `"stable"`.

6. **Confidence Values**: Only use: `"high"`, `"medium"`, or `"low"`.

## Backend Integration

Your Node.js backend should save forecasts to Firebase like this:

```javascript
// Example: Save corn forecasts
const cornForecasts = [
  {
    id: 'grits_feed_grade',
    product_name: 'Grits Feed Grade',
    forecasted_price: 45.50,
    trend: 'increasing',
    confidence: 'high',
    forecast_date: '2025-10-13',
    last_updated: new Date().toISOString(),
    model_version: 'v1.0'
  },
  // ... more products
];

for (const forecast of cornForecasts) {
  await db
    .collection('forecasted_market_prices')
    .doc('2025-10-13')
    .collection('corn')
    .doc(forecast.id)
    .set(forecast);
}
```

## Testing Your Data

Run the app and check the console for debug output:

```
🔍 DEBUG: Fetching forecasts for date: 2025-10-13
🔍 DEBUG: Category "corn" has 6 products
🔍 DEBUG: Product "grits_feed_grade" data: {product_name: Grits Feed Grade, forecasted_price: 45.5, ...}
✅ Added mover: Grits Feed Grade - 5.2% change
```

If you see **"Category X has 0 products"**, check:
1. Document IDs and field names are correct
2. Data exists in Firebase Console
3. Firebase security rules allow read access
4. Date format matches exactly (2025-10-13)
