# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EasyEats is a meal planning and nutrition tracking application for university dining halls. The project consists of:
- **Flutter mobile frontend** - Cross-platform app for meal tracking and nutrition goals
- **Python nutrition scraper** - Automated data collection from University of Illinois dining system

## Repository Structure

```
FA25-Group16/
├── Frontend/flutter_easyeats/   # Flutter mobile application
├── Backend/nutrition-scraper/   # Python web scraper for dining hall menus
├── WebScraping/                 # Legacy scraper scripts
├── Docs/                        # Project documentation
└── Research/                    # Reference materials
```

## Flutter Frontend

### Essential Commands

```bash
cd Frontend/flutter_easyeats

# Install dependencies
flutter pub get

# Run app (connects to device/emulator)
flutter run

# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code for issues
flutter analyze

# Build for platforms
flutter build apk          # Android
flutter build ios          # iOS
flutter build             # All platforms
```

### Application Architecture

**Entry Point:** [lib/main.dart](Frontend/flutter_easyeats/lib/main.dart)
- Initializes `MyApp` with MaterialApp
- Sets `AuthScreen` as home screen
- Uses green primary color theme

**Navigation Flow:**
1. `AuthScreen` → User chooses sign in or sign up
2. `SignUpScreen` → New user registration
3. `QuestionnaireScreen` → Collects user goals, age, sex, calorie targets
4. `MainPage` (home_page.dart) → Main dashboard with bottom navigation

**Page Structure:**
All screens are in [lib/pages/](Frontend/flutter_easyeats/lib/pages/):
- `auth_screen.dart` - Landing page with auth options
- `sign_in_screen.dart` - User login
- `sign_up_screen.dart` - User registration
- `questionnaire_screen.dart` - Onboarding personalization
- `home_page.dart` - Main dashboard (MainPage widget)
- `dining_halls.dart` - Dining hall selection (separate MainPage widget)

**Navigation Pattern:**
- Uses standard `Navigator.push` and `Navigator.pushReplacement`
- Bottom navigation bar in MainPage allows switching between sections
- `dining_halls.dart` contains another MainPage widget with same bottom nav structure

**Key Dependencies:**
- SDK: Dart 3.9.2, Flutter 3.35.5
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_lints: ^5.0.0` - Linting rules

**Assets:**
- Images stored in `assets/images/` directory
- Configured in `pubspec.yaml` as `assets: - assets/images/`
- Referenced in code (e.g., Logo.png, Grillworks.jpg)

**Current Limitations:**
- No backend integration - all data stored in widget state
- No persistent storage or database
- Multiple widgets named `MainPage` in different files (home_page.dart and dining_halls.dart) - can cause confusion

### Adding New Features

**New screens:** Add to `lib/pages/` following naming conventions:
- `*_screen.dart` for standalone screens (auth, sign-up, questionnaire)
- `*_page.dart` for main navigation destinations (home)

**Widgets directory:** Currently referenced but not present - create `lib/widgets/` for reusable components

## Python Nutrition Scraper

### Location and Files

**Directory:** `Backend/nutrition-scraper/`

**Key Files:**
- `Nutrition_scraping.py` - Core `NutritionScraperComplete` class with all scraping logic
- `scrape_all_dining_halls.py` - Main execution script
- `requirements.txt` - Python dependencies

### Running the Scraper

```bash
cd Backend/nutrition-scraper

# Install dependencies
pip install -r requirements.txt

# Install ChromeDriver (Mac)
brew install chromedriver

# Run scraper (takes 30-60 minutes)
python scrape_all_dining_halls.py
```

### Scraper Architecture

**Main Class:** `NutritionScraperComplete` in Nutrition_scraping.py

**Initialization:**
- `testing_mode=False` - Full scraping (default)
- `testing_mode=True` - Limits to 5 items per meal for faster testing

**Execution Flow:**
1. `scrape_dining_structure()` - Extracts all dining halls and services from dropdown
2. `navigate_to_service()` - Navigates to specific dining service by unit_id
3. `scrape_all_with_complete_data()` - Main loop iterating through halls, services, dates, meals
4. For each meal: Clicks every food item, extracts nutrition data from modal
5. `export_to_excel()` - Exports to timestamped Excel file

**Key Configuration:**
- `DAYS_TO_SCRAPE = 7` in scrape_all_dining_halls.py - Number of days to scrape
- Headless Chrome browser (runs in background)
- Data source: https://eatsmart.housing.illinois.edu

**Output Format:**
- Filename: `all_dining_halls_YYYYMMDD_HHMMSS.xlsx`
- Contains: dining_hall, service, date, meal_type, category, name, serving_size, calories, all macro/micronutrients

**Dependencies:**
- selenium>=4.0.0 (web automation)
- beautifulsoup4>=4.9.0 (HTML parsing)
- pandas>=1.3.0 (data manipulation)
- openpyxl>=3.0.0 (Excel export)

### Scraper Testing

To test changes quickly:
```python
# Modify scrape_all_dining_halls.py
scraper = NutritionScraperComplete(testing_mode=True)  # Limits items
DAYS_TO_SCRAPE = 1  # Test single day
```

## Development Workflow

**Flutter changes:**
- Always work in `Frontend/flutter_easyeats/`
- Run `flutter pub get` after modifying pubspec.yaml
- Use `flutter analyze` before committing
- Test files go in `test/` directory

**Scraper modifications:**
- Work in `Backend/nutrition-scraper/`
- Test in `testing_mode=True` first
- Chrome version must match ChromeDriver version

**Navigation changes:**
- Maintain flow: auth → questionnaire → main page
- Be aware of duplicate `MainPage` widget names in different files
- Bottom navigation uses index-based routing

## Testing

**Flutter:**
```bash
cd Frontend/flutter_easyeats
flutter test                          # All tests
flutter test test/widget_test.dart    # Specific test
```

**Scraper:**
- No automated tests currently
- Manual testing with `testing_mode=True`

## Git Workflow

- Main branch: `master`
- Repository includes work from multiple team members (cicizhu2, jaylonw2, warrenh2, sdiaz66, mihirsd2)
- Recent commits focus on menu scraper integration and navigation improvements
