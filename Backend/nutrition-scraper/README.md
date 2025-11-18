# Illinois Dining Halls Nutrition Scraper 🍽️

A Python web scraper that automatically collects comprehensive nutrition data from all University of Illinois dining halls.

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Output](#output)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Requirements](#requirements)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This scraper automatically collects nutrition information for every menu item from all University of Illinois dining halls for multiple days. It navigates the dining website, extracts data, and exports everything to a formatted Excel spreadsheet.

**Data Source:** https://eatsmart.housing.illinois.edu

---

## ✨ Features

- ✅ **Scrapes ALL dining halls** (Ikenberry, ISR, PAR, etc.)
- ✅ **Collects 7 days of data** (today + next 6 days)
- ✅ **Complete nutrition info** for every menu item
- ✅ **Organized by date and meal type** (Breakfast, Lunch, Dinner, etc.)
- ✅ **Exports to Excel** with formatted columns
- ✅ **Headless mode** - runs in background without browser window
- ✅ **Handles navigation** - automatically deals with dropdowns, modals, and date selection

---

## 🚀 Quick Start

### Prerequisites

1. **Install Python 3.7+**

2. **Install required packages:**
   ```bash
   pip install selenium beautifulsoup4 pandas openpyxl
   ```

3. **Install Chrome & ChromeDriver:**
   - **Mac:** `brew install chromedriver`
   - **Windows/Linux:** Download from [ChromeDriver](https://chromedriver.chromium.org/)

### Run the Scraper

```bash
python scrape_all_dining_halls.py
```

That's it! The scraper will:
- Run for ~30-60 minutes
- Scrape all dining halls
- Create an Excel file with all data

---

## 📊 Output

### Excel File Format
**Filename:** `all_dining_halls_YYYYMMDD_HHMMSS.xlsx`

**Columns:**
- `dining_hall` - Name of dining hall (e.g., "Ikenberry Dining Center")
- `service` - Service name (e.g., "Baked Expectations", "Field of Greens")
- `date` - Date of the meal (e.g., "Tuesday, November 18, 2025")
- `meal_type` - Breakfast, Lunch, Dinner, Brunch, or Late Night
- `category` - Food category (e.g., "Entrees", "Sides", "Desserts")
- `name` - Food item name
- `serving_size` - Serving size information
- `calories` - Calories
- `total_fat` - Total fat (g)
- `saturated_fat` - Saturated fat (g)
- `trans_fat` - Trans fat (g)
- `cholesterol` - Cholesterol (g)
- `sodium` - Sodium (g)
- `potassium` - Potassium (g)
- `total_carbohydrate` - Total carbohydrate (g)
- `dietary_fiber` - Dietary fiber (g)
- `sugars` - Sugars (g)
- `protein` - Protein (g)

**Note:** All nutrition values are standardized to grams (mg values are automatically converted)

### Sample Output
```
Dining Hall: Ikenberry Dining Center
Service: Baked Expectations
Date: Tuesday, November 18, 2025
Meal: Breakfast
Item: Blueberry Muffin
Calories: 420
Total Fat: 18g
...
```

---

## 📁 Project Structure

```
Project/
│
├── Nutrition_scraping.py          # Core scraper class with all functionality
├── scrape_all_dining_halls.py     # Main script - run this!
├── README.md                       # This file
│
└── [Generated files]
    └── all_dining_halls_*.xlsx    # Output Excel files (auto-generated)
```

### File Descriptions

**`Nutrition_scraping.py`**
- Core scraper engine
- Contains the `NutritionScraperComplete` class
- Handles all web scraping logic, navigation, and data extraction

**`scrape_all_dining_halls.py`**
- Main execution script
- Configures and runs the scraper
- Generates Excel output

---

## ⚙️ How It Works

### Step-by-Step Process

1. **Initialize Browser**
   - Launches headless Chrome browser
   - Loads Illinois dining website

2. **Extract Structure**
   - Identifies all dining halls from dropdown menu
   - Gets all services for each hall

3. **Navigate & Scrape** (for each dining hall → service → date → meal):
   - Navigate to the service
   - Select the date
   - Click on the meal period (Breakfast/Lunch/Dinner)
   - For each food item:
     - Click to open nutrition modal
     - Extract all nutrition data
     - Close modal
     - Move to next item

4. **Export to Excel**
   - Organize all collected data
   - Format columns and headers
   - Save to timestamped Excel file

### Data Flow
```
Dining Halls → Services → Dates → Meal Periods → Food Items → Nutrition Data → Excel
```

---

## 🔧 Requirements

### System Requirements
- Python 3.7 or higher
- Chrome browser
- ChromeDriver (matching your Chrome version)
- Internet connection

### Python Packages
```
selenium>=4.0.0
beautifulsoup4>=4.9.0
pandas>=1.3.0
openpyxl>=3.0.0
```

Install with:
```bash
pip install selenium beautifulsoup4 pandas openpyxl
```

---

## 🛠️ Troubleshooting

### "ChromeDriver not found"
**Solution:** Install ChromeDriver
- **Mac:** `brew install chromedriver`
- **Windows:** Download from https://chromedriver.chromium.org/
- Make sure it's in your PATH

### "Chrome version mismatch"
**Solution:** Update ChromeDriver to match your Chrome version
```bash
# Mac
brew upgrade chromedriver

# Or download matching version from ChromeDriver website
```

### Scraper is very slow
**Expected behavior!** The scraper:
- Clicks every single food item individually
- Waits for modals to load
- Navigates through multiple days and meal periods
- **Normal runtime: 30-60 minutes** for all dining halls

### Some dining halls are missing
This is normal if:
- The dining hall isn't serving on those dates
- The website doesn't have data available
- The scraper will skip halls with no available data

### Script crashes or stops
**Solution:**
- Check your internet connection
- Make sure Chrome is up to date
- Try closing other Chrome instances
- Run again - the scraper generates a new file each time

---

## 📝 Configuration

### Change Number of Days
Edit `scrape_all_dining_halls.py`:
```python
DAYS_TO_SCRAPE = 7  # Change this number (1-14 recommended)
```

### Change Output Filename
Edit `scrape_all_dining_halls.py`:
```python
OUTPUT_FILENAME = "my_custom_name.xlsx"
```

---

## 📈 Expected Results

### Runtime
- **All dining halls, 7 days:** ~30-60 minutes
- **Single dining hall, 1 day:** ~5-10 minutes

### Data Volume
Typical output contains:
- 5-7 dining halls
- 25+ services
- 7 days of menus
- 100+ food items per day
- **Total: 500-1000+ rows** in Excel

---

## 🤝 Contributing

This is a CS 124 Honors project. Feel free to:
- Report bugs
- Suggest improvements
- Fork and enhance

---

## 📜 License

Created for CS 124 Honors - FA25 Group 16

---

## 🙋 FAQ

**Q: How often should I run this?**
A: Weekly, since it collects 7 days of data.

**Q: Can I scrape more than 7 days?**
A: Yes, change `DAYS_TO_SCRAPE` in the script. However, the website typically only shows 7-14 days ahead.

**Q: Why does it take so long?**
A: The scraper clicks every food item to get nutrition data. With hundreds of items across multiple halls, days, and meals, this takes time.

**Q: Can I run it faster?**
A: Not easily. The scraper needs to wait for pages to load and modals to appear. Going too fast causes errors.

**Q: What if I only want one dining hall?**
A: You'll need to modify `Nutrition_scraping.py` to filter the dining halls list. Consider creating a custom script.

---

## 📞 Support

For issues or questions about this scraper:
1. Check the [Troubleshooting](#troubleshooting) section
2. Make sure all requirements are installed
3. Verify your internet connection and Chrome setup

---

**Happy Scraping! 🎉**
