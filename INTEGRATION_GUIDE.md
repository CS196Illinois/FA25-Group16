# EasyEats Backend-Frontend Integration Guide

## Overview

This guide documents the complete integration between the backend nutrition data/meal tracking system and the Flutter frontend with personalized food recommendations.

## What's New

### Backend Features

1. **Nutrition Data API** - Serve real dining hall food data from SQLite database
2. **Meal Tracking System** - Track consumed meals with persistent JSON storage
3. **Recommendation Algorithm** - Personalized food suggestions based on user goals
4. **User Profile Integration** - Connect nutrition tracking with user calorie goals

### Frontend Features

1. **Dynamic Home Page** - Real-time nutrition tracking with progress bars
2. **Dining Hall Detail Pages** - Browse foods and get personalized recommendations
3. **Meal Logging** - Select and log foods eaten to track daily nutrition
4. **Pull-to-Refresh** - Update nutrition data in real-time

## Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Frontend)     │
└────────┬────────┘
         │ HTTP/JSON
         ▼
┌─────────────────┐
│  Express Server │
│  (Backend)      │
└────┬──────┬─────┘
     │      │
     ▼      ▼
┌─────┐  ┌──────────┐
│SQLite│  │JSON Files│
│ DB   │  │Tracking  │
└─────┘  └──────────┘
```

## Backend API Endpoints

### Nutrition Data

#### GET /api/dining-halls
Get list of all available dining halls.

**Response:**
```json
{
  "dining_halls": ["ISR", "PAR", "LAR", "Ikenberry"]
}
```

#### GET /api/dining-halls/:hall/foods
Get all foods for a specific dining hall.

**Query Parameters:**
- `meal_type` (optional): Breakfast, Lunch, or Dinner
- `date` (optional): Date filter (YYYY-MM-DD)

**Response:**
```json
{
  "foods": [
    {
      "name": "Grilled Chicken",
      "category": "Entree",
      "serving_size": "4 oz",
      "calories": 250,
      "protein": 35,
      "total_fat": 8,
      "total_carbohydrate": 2,
      "dietary_fiber": 0,
      "sugars": 0,
      "sodium": 400
    }
  ],
  "count": 50
}
```

#### GET /api/recommendations/:userId
Get personalized food recommendations for a user.

**Query Parameters:**
- `dining_hall` (required): Dining hall name
- `meal_type` (optional): Breakfast, Lunch, or Dinner

**Response:**
```json
{
  "recommendations": [...foods],
  "user_target_calories": 667,
  "goal": "Lose weight",
  "count": 20
}
```

**Algorithm:**
Foods are scored and ranked based on:
- High protein ratio (better for weight loss/fitness)
- Low fat ratio
- High dietary fiber
- Appropriate calorie density

### Meal Tracking

#### POST /api/user/:userId/meals
Log a consumed meal.

**Request Body:**
```json
{
  "foods": [
    {
      "name": "Grilled Chicken",
      "calories": 250,
      "protein": 35,
      "total_fat": 8,
      "total_carbohydrate": 2
    }
  ],
  "meal_type": "Lunch",
  "dining_hall": "ISR",
  "consumed_at": "2025-11-27T12:30:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "meal": {
    "id": 1732745400000,
    "user_id": 1,
    "meal_type": "Lunch",
    "dining_hall": "ISR",
    "consumed_at": "2025-11-27T12:30:00Z",
    "foods": [...],
    "totals": {
      "calories": 250,
      "protein": 35,
      "fat": 8,
      "carbs": 2,
      "fiber": 0
    }
  }
}
```

#### GET /api/user/:userId/meals
Get user's meal history.

**Query Parameters:**
- `date` (optional): Filter by date (YYYY-MM-DD)
- `limit` (optional): Limit number of results

**Response:**
```json
{
  "meals": [...],
  "count": 5
}
```

#### GET /api/user/:userId/today-totals
Get today's nutrition totals for user.

**Response:**
```json
{
  "totals": {
    "calories": 1500,
    "protein": 120,
    "fat": 45,
    "carbs": 180,
    "fiber": 25,
    "meals_count": 3
  },
  "date": "2025-11-27",
  "meals": [...]
}
```

#### DELETE /api/user/:userId/meals/:mealId
Delete a meal entry.

**Response:**
```json
{
  "success": true,
  "message": "Meal deleted"
}
```

## Flutter Implementation

### Data Models

#### FoodItem
Located at: `lib/models/food_item.dart`

Represents a single food item with nutrition data.

#### MealEntry
Located at: `lib/models/meal_entry.dart`

Represents a logged meal with multiple food items and calculated totals.

#### NutritionTotals
Aggregated nutrition data with operator overloading for easy summation.

### Services

#### NutritionService
Located at: `lib/services/nutrition_service.dart`

Handles all nutrition-related API calls:
- `getDiningHalls()` - Fetch dining halls list
- `getFoodsForDiningHall()` - Get foods for a hall
- `getRecommendations()` - Get personalized recommendations
- `logMeal()` - Log consumed meal
- `getMealHistory()` - Get past meals
- `getTodayTotals()` - Get today's nutrition
- `deleteMeal()` - Delete a meal

#### UserService (Enhanced)
Located at: `lib/services/user_service.dart`

Added `getCurrentUser()` method to get combined user ID and profile data.

### Pages

#### HomePage (Updated)
Located at: `lib/pages/home_page.dart`

**Features:**
- Real-time nutrition tracking
- Dynamic progress bars based on actual consumption
- Pull-to-refresh support
- Today's meals summary cards
- Color-coded progress (green = on track, red = over goal)

**Key Changes:**
- Changed from StatelessWidget to StatefulWidget
- Loads today's totals from API
- Displays consumed meals
- Shows accurate macro breakdown

#### DiningHallDetailPage (New)
Located at: `lib/pages/dining_hall_detail_page.dart`

**Features:**
- View all foods for a dining hall
- Toggle between recommendations and all foods
- Filter by meal type (Breakfast/Lunch/Dinner)
- Search foods by name or category
- Multi-select foods to log
- Shows total calories/protein for selected items
- One-tap meal logging

**UI Components:**
- Meal type chips (Breakfast, Lunch, Dinner)
- Segmented control (Recommended vs All Foods)
- Food cards with nutrition chips
- Checkbox selection
- Bottom sheet with selected summary
- User goal banner

#### DiningHallsPage (Updated)
Located at: `lib/pages/dining_halls.dart`

**Changes:**
- Made all dining hall cards clickable
- Added navigation to DiningHallDetailPage
- Passes dining hall name to detail page

## User Flow

### 1. View Today's Progress
1. Open app → Home page loads
2. Fetches user profile for calorie goal
3. Fetches today's consumed meals from API
4. Displays progress bars with actual data
5. Shows meal cards for each logged meal

### 2. Browse Dining Halls
1. Tap "Dining Halls" in bottom nav
2. See all dining halls with images
3. Tap any dining hall card
4. Navigates to detail page

### 3. Get Recommendations
1. On dining hall detail page
2. "Recommended" tab is selected by default
3. Sees top 20 foods ranked by:
   - Protein content
   - Low fat
   - High fiber
   - Appropriate calories
4. User's goal displayed at top

### 4. Log a Meal
1. Select meal type (Breakfast/Lunch/Dinner)
2. Toggle to "Recommended" or "All Foods"
3. Search if needed
4. Check foods to add
5. See running total at bottom
6. Tap "Log Meal" button
7. Confirmation shown
8. Selected items cleared

### 5. View Updated Progress
1. Return to home page (pull to refresh)
2. See updated nutrition bars
3. New meal card appears
4. Progress bars update with new totals

## Data Storage

### Backend Storage

#### SQLite Database
**Location:** `Backend/data/nutrition_data.db`

**Table:** `nutrition_data`
- Contains scraped nutrition data from dining halls
- Fields: dining_hall, meal_type, name, calories, protein, fat, carbs, fiber, etc.

#### JSON File Storage
**Location:** `Backend/data/meal_tracking.json`

**Structure:**
```json
{
  "meals": [
    {
      "id": 1732745400000,
      "user_id": 1,
      "meal_type": "Lunch",
      "dining_hall": "ISR",
      "consumed_at": "2025-11-27T12:30:00Z",
      "foods": [...],
      "totals": {...}
    }
  ]
}
```

### Frontend Storage

#### SharedPreferences
- User session data
- User ID and profile
- 7-day login persistence

## Running the Application

### Start Backend Server

```bash
cd Backend
npm install  # If not already done
node server.js
```

Server runs on http://localhost:3000

### Start Flutter App

```bash
cd Frontend/flutter_easyeats
flutter pub get  # If not already done
flutter run
```

**Important:** Update `lib/services/auth_service.dart` and `lib/services/nutrition_service.dart` if testing on a physical device:
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
```

## API Configuration

All API endpoints use:
- Base URL: `http://localhost:3000/api`
- Content-Type: `application/json`
- CORS: Enabled for all origins

## Recommendation Algorithm

Foods are scored using this formula:

```javascript
score = protein_score + fat_score + fiber_score + calorie_density_score

protein_score = min((protein / (calories / 200)) * 10, 40)
fat_score = max(30 - (fat / (calories / 100)) * 5, 0)
fiber_score = min(fiber * 2, 15)
calorie_density_score = 15 (if 100-300 cal), 10 (if 50-400 cal), 5 (otherwise)
```

Higher scores indicate better choices for the user's goals.

## Testing the Integration

### Test Backend APIs

```bash
# Health check
curl http://localhost:3000/health

# Get dining halls
curl http://localhost:3000/api/dining-halls

# Get foods for ISR
curl "http://localhost:3000/api/dining-halls/ISR/foods?meal_type=Lunch"

# Get recommendations (replace userId)
curl "http://localhost:3000/api/recommendations/1?dining_hall=ISR&meal_type=Lunch"

# Log a meal (replace userId)
curl -X POST http://localhost:3000/api/user/1/meals \
  -H "Content-Type: application/json" \
  -d '{
    "foods": [{"name": "Test", "calories": 100, "protein": 10, "total_fat": 5, "total_carbohydrate": 12}],
    "meal_type": "Lunch",
    "dining_hall": "ISR"
  }'

# Get today's totals (replace userId)
curl http://localhost:3000/api/user/1/today-totals
```

### Test Flutter App

1. **Login:** Use existing account or create new one
2. **Home Page:**
   - Should show 0 calories if no meals logged
   - Pull down to refresh
3. **Dining Halls:**
   - Tap any dining hall
   - Should navigate to detail page
4. **Recommendations:**
   - Should see foods with nutrition info
   - User goal banner should appear
5. **Log Meal:**
   - Select foods
   - See total at bottom
   - Tap "Log Meal"
   - Should show success message
6. **Return Home:**
   - Pull to refresh
   - Progress bars should update
   - New meal card should appear

## Troubleshooting

### Backend Issues

**Problem:** Cannot connect to database
- **Check:** Database file exists at `Backend/data/nutrition_data.db`
- **Solution:** Run nutrition scraper first

**Problem:** Port 3000 already in use
- **Check:** `lsof -ti:3000`
- **Solution:** Kill process or change PORT in server.js

### Frontend Issues

**Problem:** Network error connecting to backend
- **Check:** Backend server is running
- **Check:** Correct IP address in service files
- **Solution:** Use `http://10.0.2.2:3000` for Android emulator

**Problem:** User not logged in error
- **Check:** User has completed registration/login
- **Solution:** Login again to refresh session

**Problem:** No foods appearing
- **Check:** Database has nutrition data
- **Check:** Dining hall name matches database
- **Solution:** Run scraper or check dining hall spelling

## Future Enhancements

1. **Favorites System** - Save favorite foods
2. **Meal History Page** - View past week's meals
3. **Nutrition Charts** - Visualize nutrition trends
4. **Barcode Scanner** - Scan food items
5. **Meal Suggestions** - AI-powered meal combinations
6. **Social Features** - Share meals with friends
7. **Offline Mode** - Cache nutrition data locally
8. **Push Notifications** - Meal reminders

## File Reference

### Backend Files
- `server.js` - Main Express server with all endpoints
- `package.json` - Dependencies (added sqlite3)
- `data/nutrition_data.db` - SQLite database
- `data/meal_tracking.json` - Meal tracking storage
- `data/users.json` - User profiles

### Frontend Files
- `lib/models/food_item.dart` - Food data model
- `lib/models/meal_entry.dart` - Meal and nutrition totals models
- `lib/services/nutrition_service.dart` - Nutrition API service
- `lib/services/user_service.dart` - Enhanced user service
- `lib/pages/home_page.dart` - Updated stateful home page
- `lib/pages/dining_hall_detail_page.dart` - New detail page
- `lib/pages/dining_halls.dart` - Updated with navigation

## Summary

The integration connects the nutrition scraper data with the Flutter frontend, providing:
- ✅ Real-time meal tracking
- ✅ Personalized food recommendations
- ✅ Accurate nutrition progress bars
- ✅ Easy meal logging interface
- ✅ User goal-based suggestions

The system is ready for testing and can be extended with additional features as needed.
