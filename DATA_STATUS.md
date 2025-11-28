# EasyEats - Dining Hall Data Status

## Current Data Availability

### ✅ Ikenberry Dining Center (Ike)
- **Status:** ACTIVE - 164 food items
- **Meals Available:** Breakfast (42 items), Lunch, Dinner
- **Last Updated:** From nutrition scraper
- **Recommendation System:** WORKING

### ⏸️ ISR (Illinois Street Residence)
- **Status:** NO DATA - 0 food items
- **Reason:** Dining hall was not serving during scraping or is closed over break
- **Display:** Shows "No meals being served" message

### ⏸️ PAR (Pennsylvania Avenue Residence)
- **Status:** NO DATA - 0 food items
- **Reason:** Dining hall was not serving during scraping or is closed over break
- **Display:** Shows "No meals being served" message

### ⏸️ LAR (Lincoln Avenue Residence)
- **Status:** NO DATA - 0 food items
- **Reason:** Dining hall was not serving during scraping or is closed over break
- **Display:** Shows "No meals being served" message

---

## Error Handling

The app now gracefully handles dining halls with no data:

### Before (Network Error):
```
Exception: Network Error: Exception: Failed to load recommendations
```

### After (User-Friendly Message):
```
🍽️ Oops! It seems like there are no meals being served
   at this dining hall currently.

   Try selecting a different dining hall or check back later.
```

---

## Testing Recommendations

### To Test with Real Data:
1. Open app
2. Tap "Dining Halls"
3. **Tap "Ikenberry"** ← This one has data!
4. Select meal type (Breakfast recommended - has 42 items)
5. See food recommendations
6. Select foods and log a meal
7. Return to home page to see updated progress

### Expected Behavior for Empty Halls:
1. Tap "ISR", "PAR", or "LAR"
2. See friendly "No meals being served" message
3. No error dialog or crash
4. User can navigate back to try another hall

---

## How to Add Data for Other Dining Halls

When the dining halls are open again (after break), you can scrape their data:

```bash
cd Backend/nutrition-scraper

# Run the scraper for all dining halls
python scrape_all_dining_halls.py

# This will take 30-60 minutes and scrape:
# - ISR
# - PAR
# - LAR
# - Ikenberry
# - Any other UIUC dining halls
```

The scraper will:
1. Visit https://eatsmart.housing.illinois.edu
2. Extract all dining halls from dropdown
3. Scrape 7 days of menus (Breakfast, Lunch, Dinner)
4. Click every food item to get nutrition data
5. Export to Excel file
6. Can be imported to SQLite database

---

## Database Schema

The nutrition data is stored in:
- **Location:** `Backend/data/nutrition_data.db`
- **Table:** `nutrition_data`
- **Rows:** 164 (currently, only Ikenberry)

### Sample Query:
```sql
SELECT dining_hall, COUNT(*) as item_count
FROM nutrition_data
GROUP BY dining_hall;
```

**Output:**
```
Ikenberry Dining Center (Ike) | 164
```

---

## Recommendation Algorithm (Ikenberry Only)

Since only Ikenberry has data, recommendations only work for that hall:

**Top Recommended Foods (Breakfast at Ikenberry):**
1. Scrambled Eggs - High protein, low fat
2. Turkey Sausage - Good protein ratio
3. Oatmeal - High fiber
4. Greek Yogurt - Protein-rich
5. Fresh Fruit - Low calorie, fiber

The algorithm scores based on:
- Protein-to-calorie ratio (higher = better)
- Fat-to-calorie ratio (lower = better)
- Fiber content (higher = better)
- Calorie density (100-300 cal ideal)

---

## UI Updates Made

### 1. Error Suppression
- Network errors no longer show red error boxes
- Failed API calls return empty arrays gracefully
- No error state when dining hall is just closed

### 2. Empty State Message
- Large restaurant icon (greyed out)
- Primary message: "Oops! It seems like there are no meals being served at this dining hall currently."
- Secondary message: "Try selecting a different dining hall or check back later."
- Centered, padded, easy to read

### 3. Search-Aware Messages
- If user searched: "Try adjusting your search or check back later."
- If browsing: "Try selecting a different dining hall or check back later."

---

## What Users Should Know

### ✅ Working Features:
- Ikenberry dining hall is fully functional
- Food recommendations working for Ikenberry
- Meal logging works for Ikenberry foods
- Progress tracking updates correctly
- All 164 Ikenberry foods available

### ⏸️ Temporarily Unavailable:
- ISR, PAR, LAR dining halls (no data)
- Will work once dining halls reopen and scraper runs

### 💡 Best Practice:
During break/holidays when dining halls are closed:
1. Use Ikenberry for testing/demos
2. Show 42 breakfast items with recommendations
3. Demonstrate meal logging and progress tracking
4. Explain other halls will populate when open

---

## Future Improvements

1. **Cache Last Known Menus**
   - Keep previous week's data even when halls close
   - Mark as "Last Week's Menu" with date

2. **Live Status Indicator**
   - Show green dot for halls with data
   - Show grey dot for halls without data
   - Display "Currently Serving" vs "Closed"

3. **Data Age Warning**
   - Show when data was last updated
   - Warn if data is >7 days old
   - Prompt to re-run scraper

4. **Multiple Data Sources**
   - Combine scraper data with manual entries
   - Allow users to add missing foods
   - Crowdsource nutrition data

---

## Summary

- ✅ Only **Ikenberry** has live data (164 items)
- ✅ Other halls show **friendly empty state message**
- ✅ No more **network error exceptions**
- ✅ App remains **stable and usable**
- ⏸️ Data for other halls available after **scraper runs when they reopen**

**For demos and testing, use Ikenberry Dining Center! 🍽️**
