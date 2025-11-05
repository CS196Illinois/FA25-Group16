# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EasyEats is a meal planning and nutrition tracking application for university dining halls. The project consists of a Flutter mobile frontend and Python-based menu scraper for the University of Illinois dining system.

## Repository Structure

- **Frontend/flutter_easyeats/** - Flutter mobile application
- **Backend/** - Backend services (placeholder for future development)
- **Project/** - Python utilities including the dining hall menu scraper
- **Docs/** - Project documentation and planning files
- **Research/** - Research and reference materials

## Flutter Frontend Development

### Running the Application

```bash
cd Frontend/flutter_easyeats
flutter pub get
flutter run
```

### Running Tests

```bash
cd Frontend/flutter_easyeats
flutter test
```

### Building the Application

```bash
cd Frontend/flutter_easyeats
# For Android
flutter build apk

# For iOS
flutter build ios

# For all platforms
flutter build
```

### Linting

```bash
cd Frontend/flutter_easyeats
flutter analyze
```

### Application Architecture

The Flutter app follows a page-based navigation structure:

- **Entry Point:** [lib/main.dart](Frontend/flutter_easyeats/lib/main.dart) initializes the app with `AuthScreen` as the home screen
- **Pages Directory:** [lib/pages/](Frontend/flutter_easyeats/lib/pages/) contains all screen components
  - `auth_screen.dart` - Initial authentication landing page
  - `sign_in_screen.dart` - User sign-in interface
  - `sign_up_screen.dart` - User registration interface
  - `questionnaire_screen.dart` - Onboarding questionnaire collecting user goals, age, sex, and calorie targets
  - `home_page.dart` (MainPage) - Main dashboard with bottom navigation, search, meal tracking, and nutrition goals

### Navigation Flow

1. App starts at `AuthScreen` (sign in/sign up options)
2. After sign up, users proceed to `QuestionnaireScreen` for personalization
3. After completing questionnaire, users navigate to `MainPage` (home dashboard)
4. Bottom navigation bar on `MainPage` allows navigation between main sections (currently only home is implemented)

### Key Dependencies

- `cupertino_icons: ^1.0.8` - iOS-style icons
- `flutter_lints: ^5.0.0` - Recommended linting rules

### Important Notes

- The app references widgets from a `widgets/` directory (e.g., `AppLogo`), but these files are not yet committed to the repository
- Asset images are referenced in `home_page.dart` but the assets directory structure is not fully defined in `pubspec.yaml`
- No backend integration is implemented yet - all data is stored locally in widget state

## Python Menu Scraper

### Running the Menu Scraper

```bash
cd Project
python menu_scraper.py
```

### Scraper Functionality

The `DiningHallsScraper` class in [Project/menu_scraper.py](Project/menu_scraper.py) uses Selenium to scrape menu data from the University of Illinois dining system (eatsmart.housing.illinois.edu).

**Key Features:**
- Automatically discovers all dining halls and their services from the navigation dropdown
- Scrapes menu items for each service
- Exports data to both Excel and JSON formats

**Output Files:**
- `dining_menu_results_YYYYMMDD_HHMMSS.xlsx` - Flattened table format
- `dining_menu_results_YYYYMMDD_HHMMSS.json` - Structured JSON with hierarchical data

### Scraper Requirements

The scraper requires:
- Selenium WebDriver with Chrome/Chromium
- BeautifulSoup4
- pandas
- openpyxl

Install dependencies:
```bash
pip install selenium beautifulsoup4 pandas openpyxl
```

## Development Workflow

When working on this project:

1. **Frontend changes:** Always work in `Frontend/flutter_easyeats/` and run `flutter pub get` after any pubspec.yaml changes
2. **Navigation changes:** The app uses standard Flutter `Navigator.push` and `Navigator.pushReplacement` - maintain the current flow through auth → questionnaire → main page
3. **New pages:** Add new screen files to `lib/pages/` and follow the existing naming convention (`*_screen.dart` for standalone screens, `*_page.dart` for main navigation destinations)
4. **Widgets:** Create reusable widgets in `lib/widgets/` (currently referenced but directory doesn't exist)
5. **Scraper modifications:** The scraper architecture is centered around the `DiningHallsScraper` class with separate methods for navigation, extraction, and export

## Testing

The Flutter app includes a basic widget test at [test/widget_test.dart](Frontend/flutter_easyeats/test/widget_test.dart). When adding new features, add corresponding tests in the `test/` directory following Flutter testing conventions.

## Git Workflow

- Main branch: `master`
- Recent work includes menu scraper integration and auth screen navigation improvements
- Commit messages should be descriptive and reference the feature or fix being implemented
