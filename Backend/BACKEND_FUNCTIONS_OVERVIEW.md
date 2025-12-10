# Backend Functions Overview

## 📋 Table of Contents
1. [Nutrition Scraper Functions](#nutrition-scraper)
2. [Meal Planner Functions](#meal-planner)
3. [Server API Endpoints](#server-api)

---

## 🕷️ Nutrition Scraper Functions
**File**: `Backend/scrapers/nutrition_scraper.py`

### Core Class: `NutritionScraperComplete`

#### **1. `__init__(testing_mode=False)`**
**Purpose**: Initialize the web scraper with Chrome WebDriver
**Key Features**:
- Headless Chrome browser (runs in background)
- User agent spoofing to avoid bot detection
- Testing mode limits items for faster development

---

#### **2. `scrape_dining_structure()`**
**Purpose**: Extract all dining halls and their services from dropdown menu
**Returns**: List of dining halls with their services
```python
[
    {
        'dining_hall': 'Ikenberry Dining Center',
        'unit_id': '5',
        'dining_services': [
            {'service_name': 'Baked Expectations', 'service_id': '17'},
            {'service_name': 'Grillworks', 'service_id': '18'}
        ]
    }
]
```
**How it works**:
- Navigates to Illinois Housing dining website
- Finds dropdown menu with `id="nav-unit-selector"`
- Distinguishes primary halls (text-primary class) vs. services
- Builds hierarchical structure

---

#### **3. `navigate_to_service(unit_id, service_name)`**
**Purpose**: Navigate to a specific dining service page
**Parameters**:
- `unit_id`: Unique identifier for the service
- `service_name`: Human-readable name (for logging)

**How it works**:
- Loads base URL
- Finds service by `data-unitoid` attribute
- JavaScript click to trigger navigation
- Waits for date selector to appear

---

#### **4. `get_available_dates_for_next_n_days(n_days=7)`**
**Purpose**: Get available menu dates for next N days
**Returns**: List of date objects with metadata
```python
[
    {
        'data_date': 'Today',
        'date': datetime.date(2025, 11, 18),
        'date_str': 'Monday, November 18, 2025',
        'title': 'Monday, November 18, 2025'
    }
]
```
**Key Challenge**: Filters only dates within target range from 36+ available dates

---

#### **5. `select_date(date_element)`**
**Purpose**: Click a specific date from the dropdown
**Technique**: JavaScript click (more reliable than Selenium click)

---

#### **6. `get_all_meals_structured()`**
**Purpose**: Extract all meal periods (Breakfast/Lunch/Dinner) for selected date
**Returns**: List of meals with metadata
```python
[
    {
        'element': WebElement,
        'date': 'Monday, November 18, 2025',
        'meal_type': 'Breakfast',
        'onclick': 'showMenu(...)'
    }
]
```
**Key Fix**: Uses `textContent` instead of `.text` (headless Chrome compatibility)

---

#### **7. `click_meal(meal_element)`**
**Purpose**: Click on a meal to load its food items
**Technique**: Executes onclick JavaScript directly

---

#### **8. `extract_category_map()`**
**Purpose**: Build category map from webpage sections
**Returns**: Dictionary mapping food items to categories (Entrees, Proteins, Vegetables, etc.)

---

#### **9. `extract_nutrition_info(max_items=None)`**
**Purpose**: Extract nutrition data for all food items in current meal
**Process**:
1. Find all clickable food items (`a.cbo_nn_itemHover`)
2. For each item:
   - Click to open nutrition modal
   - Extract data from modal
   - Close modal
3. Return complete nutrition dataset

**Testing mode**: Limits to first 5 items per meal

---

#### **10. `extract_nutrition_from_modal(food_name)`**
**Purpose**: Parse nutrition data from the popup modal
**Returns**: Dictionary with nutrition info
```python
{
    'name': 'Grilled Chicken',
    'serving_size': '4 oz',
    'nutrition': {
        'calories': '180',
        'protein': '35g',
        'total_fat': '3.5g',
        ...
    }
}
```
**Parsing Strategy**:
- Searches modal text for keywords (calories, protein, fat, etc.)
- Extracts numeric values with units
- Handles missing data gracefully

---

#### **11. `parse_nutrition_value(value_str)`**
**Purpose**: Standardize nutrition values to grams
**Examples**:
- `"15g"` → `15.0`
- `"1500mg"` → `1.5` (converts mg to g)
- `"N/A"` → `0.0`
- `"0"` → `0.0`

**Why**: Ensures all nutrition data is in consistent units (grams)

---

#### **12. `scrape_all_with_complete_data(days_to_scrape=7)`**
**Purpose**: Main orchestration function - scrapes everything
**Process**:
```
For each dining hall:
    For each service:
        Navigate to service
        For each date (7 days):
            Select date
            For each meal (Breakfast/Lunch/Dinner):
                Click meal
                Extract all food items with nutrition
                Store results
```

**Returns**: List of all food items with complete metadata:
```python
[
    {
        'dining_hall': 'Ikenberry',
        'service': 'Grillworks',
        'date': 'Monday, November 18, 2025',
        'meal_type': 'Lunch',
        'category': 'Entrees',
        'name': 'Chicken Sandwich',
        'serving_size': '1 sandwich',
        'calories': 420.0,
        'protein': 28.0,
        'total_fat': 15.0,
        ...
    }
]
```

**Stale Element Handling**: Re-finds date/meal elements after navigation to avoid errors

---

#### **13. `export_to_excel(all_results, filename=None)`**
**Purpose**: Export scraped data to Excel file
**Filename Format**: `all_dining_halls_YYYYMMDD_HHMMSS.xlsx`
**Features**:
- Auto-generates timestamp
- Prints summary statistics
- Shows sample items

---

#### **14. `close()`**
**Purpose**: Cleanup - close browser and release resources

---

## 🍽️ Meal Planner Functions
**File**: `Backend/meal-planning/meal_planner.py`

### Core Class: `MealPlanner`

#### **1. `__init__(db_file, excel_file)`**
**Purpose**: Initialize meal planner with data source
**Data Sources**:
- SQLite database (`nutrition_data.db`) - production
- Excel file - testing/development

---

#### **2. `load_data()`**
**Purpose**: Load nutrition data from database or Excel
**Output**: Pandas DataFrame with all food items

---

#### **3. `get_current_meal_type()`**
**Purpose**: Auto-detect meal type from system time
**Rules**:
- 6am-10am → Breakfast
- 10am-3pm → Lunch
- 3pm-9pm → Dinner
- Otherwise → Breakfast (next day)

---

#### **4. `filter_available_items(dining_hall, meal_type, date)`**
**Purpose**: Filter foods available for specific context
**Filters**:
- Dining hall (partial match, case-insensitive)
- Meal type (exact match)
- Date (optional)
- Remove items with missing/invalid nutrition data

**Returns**: Filtered DataFrame

---

#### **5. `categorize_items(items_df)`**
**Purpose**: Organize foods into nutritional categories
**Categories**:
- **Protein**: Entrees, meats, eggs, tofu (high protein content)
- **Carbs**: Rice, pasta, bread, potatoes, grains
- **Vegetables**: Broccoli, carrots, salads, greens
- **Other**: Everything else

**Method**:
- First check `category` column
- Then check item names for keywords
- Example: "Grilled Chicken Breast" → Protein category

**Returns**: Dictionary with 4 category DataFrames

---

#### **6. `score_item(item, goal_config)`**
**Purpose**: Assign nutritional quality score to each food item
**Scoring Criteria** (Weight Loss Mode):

1. **Protein Score** (0-40 points):
   - Higher protein = higher score
   - Target: 10g protein per 200 calories
   - Formula: `protein_ratio × 10`

2. **Fat Score** (0-30 points):
   - Lower fat = higher score
   - Penalize high-fat items
   - Formula: `max(30 - fat_ratio × 5, 0)`

3. **Fiber Score** (0-15 points):
   - Higher fiber = higher score
   - Formula: `min(fiber × 2, 15)`

4. **Calorie Density Score** (0-15 points):
   - Prefer moderate calories (100-300 range)
   - Too low or too high penalized

**Total Score**: 0-100 points (higher is better for weight loss)

---

#### **7. `generate_random_meal(categories, target_calories, goal_config, max_items=5)`**
**Purpose**: Create meal plan using greedy selection algorithm
**Algorithm**:
```
1. Score all items
2. Iterate through categories in priority order:
   - Protein (most important)
   - Vegetables
   - Carbs
   - Other
3. For each category:
   - Select highest-scored items
   - Calculate optimal serving size
   - Check if adding item violates constraints (fat limit)
   - Add item if valid
4. Stop when:
   - Reached max items (5)
   - Hit calorie target
   - No more valid items
```

**Constraints**:
- Stay within calorie range (±10% tolerance)
- Don't exceed max fat (35% of calories)
- Maximize protein
- Prefer diversity (different categories)

---

#### **8. `is_discrete_item(name)`**
**Purpose**: Determine if item should be whole servings only
**Examples**:
- "Donut", "Cookie", "Muffin" → True (can't have 0.75 donuts)
- "Rice", "Chicken", "Salad" → False (can have 1.5 servings)

---

#### **9. `optimize_servings(items, target_calories)`**
**Purpose**: Adjust serving sizes to hit calorie target precisely
**Method**:
1. Calculate current total calories
2. If over target: reduce servings proportionally
3. If under target: increase servings proportionally
4. Respect discrete item constraints
5. Keep servings in range [0.25, 2.0]

**Example**:
```
Target: 600 cal
Current: 680 cal (1.13x over)
Action: Reduce all servings by 0.88x
Result: ~600 cal
```

---

#### **10. `evaluate_meal(items, target_calories, goal_config)`**
**Purpose**: Score the overall meal quality
**Metrics**:
- Calorie accuracy (how close to target)
- Protein content (higher is better)
- Fat percentage (lower is better)
- Diversity (more categories is better)

**Returns**: Composite score (0-100)

---

#### **11. `create_meal_plan(target_calories, dining_hall, meal_type, goal)`**
**Purpose**: Main function - generates complete meal plan
**Parameters**:
- `target_calories`: Goal calories (e.g., 600)
- `dining_hall`: Where to eat (e.g., "Ikenberry")
- `meal_type`: When to eat (auto-detected if None)
- `goal`: Nutrition goal ('weight_loss', 'balanced', 'muscle_gain')

**Returns**: Complete meal plan dictionary
```python
{
    'dining_hall': 'Ikenberry',
    'meal_type': 'Lunch',
    'target_calories': 600,
    'actual_calories': 615.0,
    'items': [
        {
            'name': 'Grilled Chicken Breast',
            'servings': 1.0,
            'calories': 250.0,
            'protein': 35.0,
            'fat': 4.5,
            'carbs': 0.0,
            'category': 'Protein'
        },
        {
            'name': 'Brown Rice',
            'servings': 0.75,
            'calories': 180.0,
            'protein': 4.0,
            'fat': 1.5,
            'carbs': 38.0,
            'category': 'Carbs'
        },
        ...
    ],
    'totals': {
        'calories': 615.0,
        'protein': 52.0,
        'fat': 15.5,
        'carbs': 65.0,
        'fat_percent': 22.7,
        'protein_percent': 33.8,
        'carb_percent': 42.3
    },
    'meets_target': True,
    'within_fat_limit': True,
    'diversity_score': 3
}
```

---

## 🖥️ Server API Endpoints
**File**: `Backend/server.js`

### Authentication Endpoints

#### **1. `POST /api/auth/register`**
**Purpose**: Create new user account
**Body**:
```json
{
    "email": "user@example.com",
    "password": "password123"
}
```
**Validation**:
- Email format check
- Password ≥6 characters
- Email uniqueness

**Returns**: User object with ID and token

---

#### **2. `POST /api/auth/login`**
**Purpose**: User login
**Body**:
```json
{
    "email": "user@example.com",
    "password": "password123"
}
```
**Returns**: User object with authentication token

---

#### **3. `GET /api/user/:userId/profile`**
**Purpose**: Get user profile
**Returns**:
```json
{
    "id": 1,
    "email": "user@example.com",
    "age": 21,
    "sex": "male",
    "goal": "weight_loss",
    "calories": 2000,
    "favorites": ["Chicken Sandwich", "Caesar Salad"]
}
```

---

#### **4. `PUT /api/user/:userId/profile`**
**Purpose**: Update user profile
**Body**:
```json
{
    "age": 22,
    "sex": "female",
    "goal": "muscle_gain",
    "calories": 2500
}
```

---

#### **5. `POST /api/user/:userId/change-password`**
**Purpose**: Change user password
**Body**:
```json
{
    "oldPassword": "old123",
    "newPassword": "new456"
}
```

---

#### **6. `POST /api/user/:userId/favorites`**
**Purpose**: Add food to favorites
**Body**:
```json
{
    "foodItem": "Grilled Chicken Breast"
}
```

---

#### **7. `DELETE /api/user/:userId/favorites/:index`**
**Purpose**: Remove food from favorites

---

### Nutrition Data Endpoints

#### **8. `GET /api/dining-halls`**
**Purpose**: List all available dining halls
**Returns**:
```json
{
    "dining_halls": [
        "Ikenberry Dining Center (Ike)",
        "Illinois Street Dining Center (ISR)",
        "Pennsylvania Avenue Dining Hall (PAR)",
        "Lincoln Avenue Dining Hall (LAR)",
        "Everybody Eats"
    ]
}
```
**Database Query**:
```sql
SELECT DISTINCT dining_hall FROM nutrition_data ORDER BY dining_hall
```

---

#### **9. `GET /api/dining-halls/:hall/foods?meal_type&date`**
**Purpose**: Get all foods for specific dining hall and meal
**Example**: `/api/dining-halls/Ikenberry/foods?meal_type=Lunch`
**Returns**:
```json
{
    "foods": [
        {
            "name": "Chicken Sandwich",
            "category": "Entrees",
            "serving_size": "1 sandwich",
            "calories": 420,
            "protein": 28,
            "total_fat": 15,
            "total_carbohydrate": 45,
            "dietary_fiber": 3,
            "sugars": 5,
            "sodium": 890
        },
        ...
    ],
    "count": 45
}
```
**Database Query**:
```sql
SELECT DISTINCT name, category, serving_size, calories, protein,
       total_fat, total_carbohydrate, dietary_fiber, sugars, sodium
FROM nutrition_data
WHERE dining_hall LIKE '%Ikenberry%'
AND meal_type = 'Lunch'
GROUP BY name
ORDER BY category, name
```

---

#### **10. `GET /api/recommendations/:userId?dining_hall&meal_type`**
**Purpose**: Get personalized food recommendations based on user goals
**Example**: `/api/recommendations/1?dining_hall=ISR&meal_type=Dinner`

**Process**:
1. Get user profile (age, sex, goal, calorie target)
2. Calculate target calories per meal (total ÷ 3)
3. Query database for foods at that dining hall
4. Score foods by nutrition:
   - High protein ratio (protein × 4 / calories)
   - Low fat ratio (fat × 9 / calories)
   - High fiber
5. Return top 20 recommendations

**Returns**:
```json
{
    "recommendations": [
        {
            "name": "Grilled Chicken Breast",
            "calories": 180,
            "protein": 35,
            "protein_ratio": 0.78,
            "fat_ratio": 0.18,
            ...
        },
        ...
    ],
    "user_target_calories": 666,
    "goal": "weight_loss",
    "count": 20
}
```

**Database Query**:
```sql
SELECT DISTINCT name, category, serving_size, calories, protein,
       total_fat, total_carbohydrate, dietary_fiber, sugars, sodium,
       (protein * 4.0 / NULLIF(calories, 0)) as protein_ratio,
       (total_fat * 9.0 / NULLIF(calories, 0)) as fat_ratio
FROM nutrition_data
WHERE dining_hall LIKE '%ISR%'
AND calories > 0
GROUP BY name
ORDER BY
    (protein * 4.0 / NULLIF(calories, 0)) DESC,
    (total_fat * 9.0 / NULLIF(calories, 0)) ASC,
    dietary_fiber DESC
LIMIT 20
```

---

### Meal Planning Endpoint

#### **11. `GET /api/meal-plan?calories&dining_hall&meal_type&goal`**
**Purpose**: Generate optimized meal plan
**Example**: `/api/meal-plan?calories=600&dining_hall=Ikenberry&meal_type=Lunch&goal=weight_loss`

**Process**:
1. Validate parameters (calories and dining_hall required)
2. Build Python script arguments
3. Spawn Python subprocess: `python3 meal_planner.py --calories 600 --hall Ikenberry --meal Lunch --json`
4. Collect JSON output from Python
5. Parse and return meal plan

**Returns**: Same format as `MealPlanner.create_meal_plan()` output

**Error Handling**:
- Missing parameters → 400 Bad Request
- Python script fails → 500 Internal Server Error
- Invalid JSON output → 500 with raw output

---

### Meal Tracking Endpoints

#### **12. `POST /api/user/:userId/meals`**
**Purpose**: Log a meal that user ate
**Body**:
```json
{
    "date": "2025-11-18",
    "meal_type": "Lunch",
    "items": [
        {
            "name": "Chicken Sandwich",
            "calories": 420,
            "protein": 28
        }
    ],
    "total_calories": 420
}
```

---

#### **13. `GET /api/user/:userId/meals?date`**
**Purpose**: Get user's meal history
**Returns**: List of logged meals

---

#### **14. `GET /api/user/:userId/today-totals`**
**Purpose**: Get today's nutrition totals
**Returns**:
```json
{
    "date": "2025-11-18",
    "total_calories": 1650,
    "total_protein": 95,
    "total_fat": 55,
    "total_carbs": 180,
    "meals_count": 3
}
```

---

#### **15. `DELETE /api/user/:userId/meals/:mealId`**
**Purpose**: Delete a logged meal

---

#### **16. `GET /health`**
**Purpose**: Health check endpoint (server status)
**Returns**: `{ "status": "ok" }`

---

## 🔄 Integration Flow

### Complete Data Pipeline:
```
1. Web Scraping (Python)
   └─> nutrition_scraper.py
       └─> Extracts from eatsmart.housing.illinois.edu
           └─> Saves to Excel (all_dining_halls_*.xlsx)

2. Data Loading (Python)
   └─> load_to_db.py
       └─> Reads Excel file
           └─> Inserts into nutrition_data.db (SQLite)

3. Server (Node.js)
   └─> server.js
       ├─> Queries nutrition_data.db
       ├─> Calls meal_planner.py for meal plans
       └─> Serves REST API to Flutter frontend

4. Meal Planning (Python called by Node)
   └─> meal_planner.py
       └─> Reads nutrition_data.db
           └─> Generates optimized meal plans
               └─> Returns JSON to server

5. Frontend (Flutter)
   └─> Calls API endpoints
       └─> Displays meal plans to users
```

---

## 🎯 Key Technical Decisions

### Why Selenium for Scraping?
- Website uses JavaScript to load menus dynamically
- Need to interact with dropdowns and modals
- BeautifulSoup alone can't handle dynamic content

### Why Hybrid Python-Node Architecture?
- **Python**: Better for algorithms (meal planning, data science)
- **Node.js**: Better for REST APIs (fast, async, large ecosystem)
- Best of both worlds: Python for computation, Node for serving

### Why SQLite Database?
- Lightweight (no separate database server)
- Perfect for read-heavy workloads
- 3,697 items is small enough for SQLite
- Easy to deploy and backup

### Why Greedy Algorithm for Meal Planning?
- Fast execution (< 1 second)
- Good enough results for real-world use
- Easy to understand and debug
- Can be improved later with optimization libraries if needed

---

## 📊 Performance Metrics

- **Scraping**: ~30-60 minutes for all dining halls (7 days)
- **Database Load**: < 5 seconds for 3,697 items
- **Meal Plan Generation**: < 1 second
- **API Response Time**: < 100ms (database queries)
- **Database Size**: 1.25 MB (nutrition_data.db)
