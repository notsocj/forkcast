# 🧪 AI Forecasting Testing Guide

## Quick Test Checklist

### ✅ Prerequisites
- [ ] Backend forecasting service is running
- [ ] Firebase `forecasted_market_prices` collection has data
- [ ] Flutter app is connected to Firebase
- [ ] Android emulator or device is ready

---

## 1. Test Trends Tab (Chart Visualization)

### Steps:
1. Open ForkCast app
2. Navigate to **Market Prices** (bottom nav, 3rd tab - Price Monitoring icon)
3. Switch to **"Trends"** tab

### Expected Results:
✅ **With Forecast Data:**
- Top 10 products displayed with line charts
- Each chart shows:
  - Product name at top
  - Trend badge (Rising/Falling/Stable) with appropriate color
  - Smooth line chart with historical curve
  - Dashed forecast line
  - Current price (green label at bottom left)
  - Forecasted price (red/blue label at bottom right)
- AI info banner at bottom with GPT-4 branding

✅ **Without Forecast Data:**
- Cloud icon with message
- "No forecast data available"
- "AI forecasts will be generated weekly"

### Screenshots to Capture:
- [ ] Chart with rising trend (red line)
- [ ] Chart with falling trend (blue line)
- [ ] Chart with stable trend (gray line)
- [ ] AI info banner
- [ ] Empty state (if no data)

---

## 2. Test Alerts Tab (Top Price Movers)

### Steps:
1. Stay on **Market Prices** page
2. Switch to **"Alerts"** tab

### Expected Results:
✅ **With Forecast Data:**
- Header: "Top Price Movers" with trending icon
- Subtitle: "Products with biggest forecasted price changes"
- Product cards showing:
  - Trend icon (up/down arrow) in colored circle
  - Product name
  - Category name
  - Confidence badge (HIGH/MEDIUM/LOW)
  - Percentage change badge (e.g., "+8.3%" in red)
  - Current price
  - Forecasted price with arrow indicator
- Cards sorted by absolute % change (biggest movers first)

✅ **Without Forecast Data:**
- Hourglass icon with message
- "No price movers yet"
- "AI forecasts will be generated weekly"

### Data Validation:
- [ ] Rising prices show red badges/icons
- [ ] Falling prices show blue badges/icons
- [ ] Percentage changes are accurate
- [ ] Confidence levels display correctly
- [ ] Current vs forecast prices match data

---

## 3. Test Firebase Connection

### Check Firebase Console:
1. Open Firebase Console → Firestore Database
2. Navigate to `forecasted_market_prices` collection
3. Click on latest date document (e.g., `2025-10-14`)
4. Verify subcollections exist:
   - livestock_and_poultry
   - rice
   - vegetables_highland
   - vegetables_lowland
   - fruits
   - fish
   - corn

### Sample Data Check:
```
forecasted_market_prices/2025-10-14/livestock_and_poultry/whole_chicken
├── product_name: "Whole Chicken"
├── forecasted_price: 188.50
├── trend: "rising"
├── confidence: "high"
├── forecast_date: "2025-10-14"
└── model_version: "gpt-4o-mini-v1.0"
```

---

## 4. Test Edge Cases

### No Internet Connection:
- [ ] App shows error state gracefully
- [ ] No crashes when loading forecasts

### Partial Data:
- [ ] Some categories have forecasts, others don't
- [ ] App handles missing fields (product_name, forecasted_price, etc.)

### Large Numbers:
- [ ] Prices > 1000 display correctly (₱1,234.56)
- [ ] Percentages > 100% display correctly

### Long Product Names:
- [ ] Text wraps properly (maxLines: 2)
- [ ] No overflow errors

---

## 5. Performance Testing

### Load Time:
- [ ] Trends tab loads within 2 seconds
- [ ] Alerts tab loads within 2 seconds
- [ ] Charts render smoothly without lag

### Memory:
- [ ] No memory leaks when switching tabs repeatedly
- [ ] Scroll performance is smooth

### Multiple Devices:
- [ ] Test on small screen (e.g., 5" phone)
- [ ] Test on large screen (e.g., 6.5" phone)
- [ ] Test on tablet (if available)

---

## 6. Backend Integration Testing

### Manual Forecast Trigger:
```bash
# In forkcast_backend directory
npm run forecast
```

### Expected Output:
```
[2025-10-12 10:30:00] Starting weekly forecast job...
[2025-10-12 10:30:05] ✓ Fetched historical data: 6 weeks
[2025-10-12 10:30:10] ✓ Generated forecasts for livestock_and_poultry
[2025-10-12 10:30:15] ✓ Generated forecasts for rice
...
[2025-10-12 10:30:45] ✓ Saved all forecasts to Firestore
[2025-10-12 10:30:45] Forecast job completed successfully!
```

### Verify in Firebase:
- [ ] New forecast document created (date: next Monday)
- [ ] All 7 categories have subcollections
- [ ] Each product has required fields

---

## 7. User Acceptance Testing

### Ask Test Users:
1. "Can you understand what the charts show?"
2. "Do the price trends make sense?"
3. "Is the 'Top Price Movers' section helpful?"
4. "Are confidence levels clear?"
5. "Would you use this for meal planning?"

### Collect Feedback:
- [ ] UI clarity and readability
- [ ] Chart design and colors
- [ ] Information density (too much/too little?)
- [ ] Navigation and tab switching
- [ ] Overall usefulness of forecasts

---

## 🐛 Common Issues & Solutions

### Issue: "No forecast data available"
**Causes:**
- Backend hasn't run yet
- Firestore collection is empty
- Wrong date calculation (not Monday)

**Solution:**
1. Run `npm run forecast` in backend
2. Check Firebase console for data
3. Verify date calculation in `_getNextMonday()`

### Issue: Charts not displaying
**Causes:**
- Missing `PriceTrendChart` widget import
- Forecast data structure mismatch
- Null values in price data

**Solution:**
1. Check import in `user_market_prices_page.dart`
2. Verify Firebase data structure
3. Add null checks in `_buildTrendsTab()`

### Issue: Alerts tab empty despite having data
**Causes:**
- `_priceAlerts` not populated
- `_loadForecastingData()` not called
- `getTopPriceMovers()` returning empty

**Solution:**
1. Check `initState()` calls `_loadForecastingData()`
2. Verify MarketPriceService methods
3. Check console for error messages

---

## 📊 Success Metrics

### Must Have:
- ✅ All charts display correctly with proper data
- ✅ Top movers show in alerts tab
- ✅ No crashes or errors
- ✅ Data refreshes when pulling down (if implemented)

### Nice to Have:
- ✅ Smooth animations
- ✅ Fast load times (<2s)
- ✅ Responsive on all screen sizes
- ✅ Clear and intuitive UI

---

## 📝 Test Report Template

```
Test Date: __________
Tester: __________
Device: __________
Android Version: __________

TRENDS TAB:
□ Charts display correctly
□ Trend badges show proper colors
□ Current/forecast prices accurate
□ Empty state works

ALERTS TAB:
□ Top movers display correctly
□ Percentage changes accurate
□ Confidence badges show
□ Empty state works

PERFORMANCE:
□ Load time <2s
□ Smooth scrolling
□ No memory issues

ISSUES FOUND:
1. ___________________________
2. ___________________________
3. ___________________________

OVERALL RATING: __/10
```

---

**Status**: Ready for testing
**Last Updated**: October 12, 2025
**Next Review**: After first test cycle
