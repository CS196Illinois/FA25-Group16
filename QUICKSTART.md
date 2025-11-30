# EasyEats Quick Start Guide

## Prerequisites

- Node.js (v14 or higher)
- Flutter SDK (3.35.5 or higher)
- iOS Simulator or Android Emulator (or physical device)

## Step 1: Start the Backend Server

```bash
# Navigate to backend directory
cd Backend

# Install dependencies (if not done already)
npm install

# Start the server
node server.js
```

You should see:
```
Server running on http://localhost:3000
Authentication endpoints available at:
  POST http://localhost:3000/api/auth/register
  POST http://localhost:3000/api/auth/login
  ...
```

**Keep this terminal window open** - the server needs to keep running.

## Step 2: Start the Flutter App

Open a **new terminal window**:

```bash
# Navigate to Flutter directory
cd Frontend/flutter_easyeats

# Get dependencies (if not done already)
flutter pub get

# Run the app
flutter run
```

Select your target device when prompted (iOS Simulator, Android Emulator, etc.)

## Step 3: Use the App

### First Time Setup

1. **Register Account:**
   - Tap "Sign Up"
   - Enter email and password
   - Tap "Sign Up" button

2. **Complete Profile:**
   - Enter your goal (e.g., "Lose weight", "Build muscle")
   - Enter age
   - Select sex
   - Enter target calories (e.g., 2000)
   - Tap "Continue"

3. **Home Page:**
   - You'll see the home page with 0 calories logged
   - All progress bars start at 0%

### Browse and Log Meals

1. **Navigate to Dining Halls:**
   - Tap "Dining Halls" icon in bottom navigation

2. **Select a Dining Hall:**
   - Tap on any dining hall card (ISR, PAR, LAR, or Ikenberry)

3. **View Recommendations:**
   - See personalized food recommendations
   - Foods are ranked based on your goals
   - Your daily calorie target per meal is shown at top

4. **Select Foods:**
   - Tap meal type chip (Breakfast/Lunch/Dinner) if needed
   - Toggle between "Recommended" and "All Foods"
   - Use search bar to find specific foods
   - Tap checkboxes to select foods you ate
   - Bottom sheet shows running total

5. **Log Your Meal:**
   - Review selected foods and totals
   - Tap "Log Meal" button
   - See success confirmation

6. **View Progress:**
   - Tap "Home" icon in bottom navigation
   - Pull down to refresh (or it auto-refreshes)
   - See updated progress bars
   - Your logged meal appears as a card
   - Calories, protein, carbs, and fat update

### View Your Nutrition

The home page shows:
- **Progress bars** for calories, protein, carbs, and fat
- **Percentage** of daily goal achieved
- **Color coding:** Green (on track), Red (over goal)
- **Meal cards** showing what you ate and when
- **Pull-to-refresh** to update data

## Testing the Complete Flow

Here's a complete test scenario:

```
1. Start backend server ✓
2. Start Flutter app ✓
3. Register new account → Profile shows "Not logged in" ✗
4. Complete questionnaire → Redirected to home
5. Home shows 0/2000 calories → Progress: 0% ✓
6. Tap "Dining Halls" → See 4 dining halls ✓
7. Tap "ISR" → Opens detail page ✓
8. See "Recommended" foods → Top foods shown ✓
9. Select "Grilled Chicken" + "Rice" → Bottom shows totals ✓
10. Tap "Log Meal" → Success message ✓
11. Tap "Home" → Pull down to refresh ✓
12. See updated calories → Progress bar updates ✓
13. See meal card → Shows "Lunch at ISR" ✓
```

## Troubleshooting

### Issue: "Network error" in app

**Cause:** App can't reach backend server

**Solutions:**
1. Check backend server is running (see Step 1)
2. Check server logs for errors
3. If using physical device, update IP address:
   - Open `lib/services/auth_service.dart`
   - Change `localhost` to your computer's IP address
   - Same for `lib/services/nutrition_service.dart`

### Issue: "No foods found"

**Cause:** Database is empty or dining hall name doesn't match

**Solutions:**
1. Check database exists: `Backend/data/nutrition_data.db`
2. If missing, run the nutrition scraper first
3. Check backend logs for database errors

### Issue: Home page shows "Not logged in"

**Cause:** User session expired or not set

**Solutions:**
1. Log out and log back in
2. Complete the registration flow again
3. Check that UserService is saving session correctly

### Issue: Backend won't start - "EADDRINUSE"

**Cause:** Port 3000 already in use

**Solutions:**
```bash
# Find process using port 3000
lsof -ti:3000

# Kill the process (replace PID)
kill <PID>

# Or change port in server.js:
const PORT = process.env.PORT || 3001;
```

### Issue: Flutter build errors

**Solutions:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## What You Should See

### Backend Server Output
```
Server running on http://localhost:3000
```

### Flutter App Screens

1. **Auth Screen** - Green logo, Sign In/Sign Up buttons
2. **Sign Up** - Email/password form
3. **Questionnaire** - Goal, age, sex, calories
4. **Home Page** - Logo, search, progress bars
5. **Dining Halls** - 4 dining hall cards with images
6. **Detail Page** - Foods list with nutrition info
7. **After Logging** - Updated home page with meal cards

## Next Steps

- Log meals for breakfast, lunch, and dinner
- Try different dining halls
- Switch between meal types
- Use search to find specific foods
- Pull down on home page to refresh
- Check your progress throughout the day

## Support

For issues or questions:
1. Check the [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md) for detailed documentation
2. Review backend logs at `/tmp/easyeats-server.log`
3. Check Flutter console output for errors
4. Report issues on GitHub

## Summary

✅ Backend API serves nutrition data
✅ Flutter app tracks meals in real-time
✅ Home page shows accurate progress
✅ Recommendations based on user goals
✅ Full meal logging workflow

**You're all set! Start tracking your nutrition with EasyEats!** 🍎🥗💪
