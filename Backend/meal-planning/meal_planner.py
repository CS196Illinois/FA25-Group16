"""
Meal Planning Algorithm
Generates optimized meal plans based on calorie targets and nutritional goals
"""
import sqlite3
import pandas as pd
from datetime import datetime
from collections import defaultdict


class MealPlanner:
    def __init__(self, db_file='nutrition_data.db', excel_file=None):
        """
        Initialize meal planner

        Args:
            db_file: Path to SQLite database (optional)
            excel_file: Path to Excel file to use instead of database
        """
        self.db_file = db_file
        self.excel_file = excel_file
        self.data = None

    def load_data(self):
        """Load nutrition data from Excel or database"""
        if self.excel_file:
            print(f"Loading data from Excel: {self.excel_file}")
            self.data = pd.read_excel(self.excel_file)
            print(f"✓ Loaded {len(self.data)} items from Excel")
        else:
            print(f"Loading data from database: {self.db_file}")
            conn = sqlite3.connect(self.db_file)
            self.data = pd.read_sql_query("SELECT * FROM nutrition_data", conn)
            conn.close()
            print(f"✓ Loaded {len(self.data)} items from database")

    def get_current_meal_type(self):
        """Automatically determine meal type based on current time"""
        current_hour = datetime.now().hour

        if 6 <= current_hour < 10:
            return "Breakfast"
        elif 10 <= current_hour < 15:
            return "Lunch"
        elif 15 <= current_hour < 21:
            return "Dinner"
        else:
            # Late night or early morning - default to next meal
            if current_hour >= 21 or current_hour < 6:
                return "Breakfast"  # Next day breakfast
            return "Lunch"

    def filter_available_items(self, dining_hall, meal_type, date=None):
        """
        Filter items available for specific dining hall and meal

        Args:
            dining_hall: Name of dining hall (e.g., "ISR")
            meal_type: Type of meal (Breakfast, Lunch, Dinner)
            date: Optional date filter

        Returns:
            DataFrame of available items
        """
        if self.data is None:
            self.load_data()

        # Filter by dining hall (partial match)
        filtered = self.data[self.data['dining_hall'].str.contains(dining_hall, case=False, na=False)]

        # Filter by meal type
        filtered = filtered[filtered['meal_type'] == meal_type]

        # Filter by date if provided
        if date:
            filtered = filtered[filtered['date'].str.contains(date, case=False, na=False)]

        # Remove items with missing critical nutrition data
        filtered = filtered[
            (filtered['calories'].notna()) &
            (filtered['calories'] > 0) &
            (filtered['protein'].notna()) &
            (filtered['total_fat'].notna())
        ]

        return filtered.copy()

    def categorize_items(self, items_df):
        """
        Categorize items into food groups

        Returns:
            Dictionary with categories as keys and DataFrames as values
        """
        categories = {
            'protein': items_df[items_df['category'].str.contains(
                'entree|protein|chicken|beef|fish|pork|turkey|tofu|egg',
                case=False, na=False
            )],
            'carbs': items_df[items_df['category'].str.contains(
                'grain|rice|pasta|bread|potato|starch|cereal',
                case=False, na=False
            )],
            'vegetables': items_df[items_df['category'].str.contains(
                'vegetable|veggie|salad|greens',
                case=False, na=False
            )],
            'other': items_df  # All items as fallback
        }

        # Also categorize by name if category is missing
        for idx, row in items_df.iterrows():
            name_lower = str(row['name']).lower()

            # Protein indicators
            if any(word in name_lower for word in ['chicken', 'beef', 'pork', 'fish', 'salmon',
                                                     'turkey', 'egg', 'tofu', 'bean', 'lentil']):
                if idx not in categories['protein'].index:
                    categories['protein'] = pd.concat([categories['protein'], items_df.loc[[idx]]])

            # Carb indicators
            if any(word in name_lower for word in ['rice', 'pasta', 'bread', 'potato', 'noodle',
                                                     'tortilla', 'quinoa', 'oat']):
                if idx not in categories['carbs'].index:
                    categories['carbs'] = pd.concat([categories['carbs'], items_df.loc[[idx]]])

            # Vegetable indicators
            if any(word in name_lower for word in ['broccoli', 'carrot', 'spinach', 'lettuce',
                                                     'tomato', 'pepper', 'green', 'salad', 'veggie']):
                if idx not in categories['vegetables'].index:
                    categories['vegetables'] = pd.concat([categories['vegetables'], items_df.loc[[idx]]])

        return categories

    def score_item(self, item, target_calories, max_fat):
        """
        Score an item based on nutritional value for weight loss

        Scoring criteria:
        - High protein (better score)
        - Low fat (better score)
        - Appropriate calorie density
        - Fiber content (if available)

        Returns:
            Float score (higher is better)
        """
        score = 0.0

        calories = float(item['calories'])
        protein = float(item['protein'])
        fat = float(item['total_fat'])
        fiber = float(item['dietary_fiber']) if pd.notna(item['dietary_fiber']) else 0

        # Protein score (high protein is good) - up to 40 points
        # Aim for at least 10g protein per 200 calories
        protein_ratio = protein / (calories / 200) if calories > 0 else 0
        score += min(protein_ratio * 10, 40)

        # Fat score (low fat is good) - up to 30 points
        # Penalize high fat items
        fat_ratio = fat / (calories / 100) if calories > 0 else 0
        fat_score = max(30 - fat_ratio * 5, 0)  # Lower fat ratio = higher score
        score += fat_score

        # Fiber score (high fiber is good) - up to 15 points
        fiber_score = min(fiber * 2, 15)
        score += fiber_score

        # Calorie density score - up to 15 points
        # Prefer moderate calorie density (not too high, not too low)
        # Ideal range: 100-300 calories per serving
        if 100 <= calories <= 300:
            score += 15
        elif 50 <= calories < 100 or 300 < calories <= 400:
            score += 10
        elif calories < 50 or calories > 400:
            score += 5

        return score

    def create_meal_plan(self, target_calories, dining_hall, meal_type=None,
                        max_items=5, calorie_tolerance=0.1, max_fat_ratio=0.35):
        """
        Create an optimized meal plan

        Args:
            target_calories: Target calorie goal (e.g., 600)
            dining_hall: Dining hall name (e.g., "ISR")
            meal_type: Meal type (optional - auto-detected if None)
            max_items: Maximum number of items in meal plan (default: 5)
            calorie_tolerance: Allowed deviation from target (default: 10%)
            max_fat_ratio: Maximum fat as % of calories (default: 35%)

        Returns:
            Dictionary with meal plan details
        """
        # Auto-detect meal type if not provided
        if meal_type is None:
            meal_type = self.get_current_meal_type()
            print(f"Auto-detected meal type: {meal_type}")

        # Calculate calorie range
        min_calories = target_calories * (1 - calorie_tolerance)
        max_calories = target_calories * (1 + calorie_tolerance)

        # Calculate max fat in grams (fat has 9 cal/g)
        max_fat_grams = (target_calories * max_fat_ratio) / 9

        print(f"\n{'='*60}")
        print(f"MEAL PLANNER - Weight Loss Mode")
        print(f"{'='*60}")
        print(f"Dining Hall: {dining_hall}")
        print(f"Meal Type: {meal_type}")
        print(f"Target Calories: {target_calories} (range: {min_calories:.0f}-{max_calories:.0f})")
        print(f"Max Fat: {max_fat_grams:.1f}g")
        print(f"{'='*60}\n")

        # Get available items
        available_items = self.filter_available_items(dining_hall, meal_type)

        if len(available_items) == 0:
            return {
                'error': f'No items found for {dining_hall} - {meal_type}',
                'dining_hall': dining_hall,
                'meal_type': meal_type
            }

        print(f"Found {len(available_items)} available items")

        # Score all items FIRST (before categorizing)
        available_items['score'] = available_items.apply(
            lambda x: self.score_item(x, target_calories, max_fat_grams),
            axis=1
        )

        # Categorize items
        categories = self.categorize_items(available_items)

        # Greedy selection with diversity
        selected_items = []
        total_calories = 0
        total_protein = 0
        total_fat = 0
        total_carbs = 0
        categories_used = set()

        # Priority: protein -> vegetables -> carbs -> other
        category_priority = ['protein', 'vegetables', 'carbs', 'other']

        for category in category_priority:
            cat_items = categories[category]

            if len(cat_items) == 0:
                continue

            # Sort by score
            cat_items = cat_items.sort_values('score', ascending=False)

            # Try to add items from this category
            for idx, item in cat_items.iterrows():
                if len(selected_items) >= max_items:
                    break

                # Skip if already selected
                if any(s['name'] == item['name'] for s in selected_items):
                    continue

                # Calculate optimal serving size
                remaining_calories = max_calories - total_calories
                item_calories = float(item['calories'])

                if item_calories <= 0:
                    continue

                # Start with 1 serving
                servings = 1.0

                # Adjust serving size based on remaining calories
                if total_calories + item_calories > max_calories:
                    # Reduce serving size
                    servings = remaining_calories / item_calories
                    servings = max(0.25, min(servings, 1.0))  # Keep between 0.25 and 1.0

                # Calculate nutrition for this serving
                item_total_cal = item_calories * servings
                item_total_fat = float(item['total_fat']) * servings
                item_total_protein = float(item['protein']) * servings
                item_total_carbs = float(item['total_carbohydrate']) * servings

                # Check if adding this item would exceed fat limit
                if total_fat + item_total_fat > max_fat_grams:
                    continue  # Skip high-fat items

                # Check if this would put us way over calorie limit
                if total_calories + item_total_cal > max_calories * 1.2:
                    continue

                # Add item
                selected_items.append({
                    'name': item['name'],
                    'category': item['category'] if pd.notna(item['category']) else 'Other',
                    'servings': round(servings, 2),
                    'calories_per_serving': round(item_calories, 1),
                    'calories': round(item_total_cal, 1),
                    'protein': round(item_total_protein, 1),
                    'fat': round(item_total_fat, 1),
                    'carbs': round(item_total_carbs, 1),
                    'fiber': round(float(item['dietary_fiber']) * servings, 1) if pd.notna(item['dietary_fiber']) else 0,
                    'score': round(float(item['score']), 1)
                })

                total_calories += item_total_cal
                total_fat += item_total_fat
                total_protein += item_total_protein
                total_carbs += item_total_carbs
                categories_used.add(category)

                # Stop if we're close to target
                if total_calories >= min_calories:
                    break

            # Stop if we have enough calories and items
            if total_calories >= min_calories and len(selected_items) >= 2:
                break

        # Optimize servings to get closer to target
        if len(selected_items) > 0 and total_calories < min_calories:
            # Scale up proportionally
            scale_factor = min(target_calories / total_calories, 1.5)  # Max 1.5x scaling

            for item in selected_items:
                item['servings'] = round(item['servings'] * scale_factor, 2)
                item['calories'] = round(item['calories'] * scale_factor, 1)
                item['protein'] = round(item['protein'] * scale_factor, 1)
                item['fat'] = round(item['fat'] * scale_factor, 1)
                item['carbs'] = round(item['carbs'] * scale_factor, 1)
                item['fiber'] = round(item['fiber'] * scale_factor, 1)

            total_calories *= scale_factor
            total_protein *= scale_factor
            total_fat *= scale_factor
            total_carbs *= scale_factor

        # Calculate percentages
        fat_calories = total_fat * 9
        protein_calories = total_protein * 4
        carb_calories = total_carbs * 4

        fat_percent = (fat_calories / total_calories * 100) if total_calories > 0 else 0
        protein_percent = (protein_calories / total_calories * 100) if total_calories > 0 else 0
        carb_percent = (carb_calories / total_calories * 100) if total_calories > 0 else 0

        # Build result
        result = {
            'dining_hall': dining_hall,
            'meal_type': meal_type,
            'target_calories': target_calories,
            'calorie_range': f"{min_calories:.0f}-{max_calories:.0f}",
            'actual_calories': round(total_calories, 1),
            'items': selected_items,
            'totals': {
                'calories': round(total_calories, 1),
                'protein': round(total_protein, 1),
                'fat': round(total_fat, 1),
                'carbs': round(total_carbs, 1),
                'fat_percent': round(fat_percent, 1),
                'protein_percent': round(protein_percent, 1),
                'carb_percent': round(carb_percent, 1)
            },
            'meets_target': min_calories <= total_calories <= max_calories,
            'within_fat_limit': total_fat <= max_fat_grams,
            'diversity_score': len(categories_used)
        }

        return result

    def print_meal_plan(self, meal_plan):
        """Pretty print meal plan"""
        if 'error' in meal_plan:
            print(f"\n❌ {meal_plan['error']}")
            return

        print(f"\n{'='*60}")
        print(f"MEAL PLAN")
        print(f"{'='*60}")
        print(f"Location: {meal_plan['dining_hall']}")
        print(f"Meal: {meal_plan['meal_type']}")
        print(f"Target: {meal_plan['target_calories']} cal (range: {meal_plan['calorie_range']})")
        print(f"\n{'='*60}")
        print(f"ITEMS TO GET")
        print(f"{'='*60}\n")

        for i, item in enumerate(meal_plan['items'], 1):
            print(f"{i}. {item['name']}")
            print(f"   Servings: {item['servings']}x")
            print(f"   Nutrition: {item['calories']} cal | P:{item['protein']}g F:{item['fat']}g C:{item['carbs']}g")
            print(f"   Category: {item['category']}")
            print()

        totals = meal_plan['totals']
        print(f"{'='*60}")
        print(f"TOTALS")
        print(f"{'='*60}")
        print(f"Calories: {totals['calories']} {'✓' if meal_plan['meets_target'] else '⚠'}")
        print(f"Protein:  {totals['protein']}g ({totals['protein_percent']:.1f}%)")
        print(f"Fat:      {totals['fat']}g ({totals['fat_percent']:.1f}%) {'✓' if meal_plan['within_fat_limit'] else '⚠'}")
        print(f"Carbs:    {totals['carbs']}g ({totals['carb_percent']:.1f}%)")
        print(f"\nDiversity: {meal_plan['diversity_score']}/4 food groups")
        print(f"{'='*60}\n")


# Example usage
if __name__ == "__main__":
    import argparse
    import json
    import sys
    import os

    # Default paths
    # Script is in Backend/services/
    # DB is in Backend/data/nutrition_data.db
    current_dir = os.path.dirname(os.path.abspath(__file__))
    backend_dir = os.path.dirname(current_dir)
    default_db = os.path.join(backend_dir, 'data', 'nutrition_data.db')
    
    # Fallback to relative path if absolute doesn't work as expected
    if not os.path.exists(default_db):
        default_db = 'nutrition_data.db'

    parser = argparse.ArgumentParser(description='Generate a meal plan')
    parser.add_argument('--calories', type=int, default=600, help='Target calories')
    parser.add_argument('--hall', type=str, default='ISR', help='Dining hall name')
    parser.add_argument('--meal', type=str, help='Meal type (Breakfast, Lunch, Dinner)')
    parser.add_argument('--db', type=str, default=default_db, help='Path to database')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    
    args = parser.parse_args()

    # Initialize planner
    # Check if db exists, otherwise warn
    if not os.path.exists(args.db) and not args.json:
        print(f"Warning: Database not found at {args.db}")
        
    planner = MealPlanner(db_file=args.db)

    # Generate plan
    meal_plan = planner.create_meal_plan(
        target_calories=args.calories,
        dining_hall=args.hall,
        meal_type=args.meal
    )

    if args.json:
        # Output only JSON to stdout
        print(json.dumps(meal_plan))
    else:
        # Pretty print
        planner.print_meal_plan(meal_plan)
