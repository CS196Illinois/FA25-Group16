"""
Example database queries for nutrition data
Shows common use cases for querying the nutrition database
"""
import sqlite3
import sys


def connect_db(db_file='nutrition_data.db'):
    """Connect to the database"""
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)


def query_1_items_by_dining_hall(conn):
    """Get count of items by dining hall"""
    print("\n1. Items by Dining Hall")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT dining_hall, COUNT(*) as item_count
        FROM nutrition_data
        GROUP BY dining_hall
        ORDER BY item_count DESC
    """)

    for row in cursor.fetchall():
        print(f"   {row[0]}: {row[1]} items")


def query_2_high_protein_items(conn):
    """Find high-protein items (>20g)"""
    print("\n2. High Protein Items (>20g)")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT name, protein, dining_hall, meal_type, calories
        FROM nutrition_data
        WHERE protein > 20
        ORDER BY protein DESC
        LIMIT 10
    """)

    for row in cursor.fetchall():
        print(f"   {row[0]}")
        print(f"      Protein: {row[1]}g | Calories: {row[4]} | {row[2]} - {row[3]}")


def query_3_low_calorie_items(conn):
    """Find low-calorie items (<200 cal)"""
    print("\n3. Low Calorie Items (<200 cal)")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT name, calories, protein, dining_hall, meal_type
        FROM nutrition_data
        WHERE calories > 0 AND calories < 200
        ORDER BY calories ASC
        LIMIT 10
    """)

    for row in cursor.fetchall():
        print(f"   {row[0]}: {row[1]} cal, {row[2]}g protein ({row[3]}, {row[4]})")


def query_4_breakfast_items_isr(conn):
    """Get all breakfast items at ISR"""
    print("\n4. Breakfast Items at ISR")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT name, calories, protein, category
        FROM nutrition_data
        WHERE dining_hall LIKE '%ISR%'
        AND meal_type = 'Breakfast'
        ORDER BY calories DESC
        LIMIT 15
    """)

    for row in cursor.fetchall():
        category = row[3] if row[3] else 'Uncategorized'
        print(f"   {row[0]}: {row[1]} cal, {row[2]}g protein [{category}]")


def query_5_avg_calories_by_meal(conn):
    """Average calories by meal type"""
    print("\n5. Average Calories by Meal Type")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT meal_type,
               ROUND(AVG(calories), 1) as avg_calories,
               COUNT(*) as item_count
        FROM nutrition_data
        WHERE calories > 0
        GROUP BY meal_type
        ORDER BY avg_calories DESC
    """)

    for row in cursor.fetchall():
        print(f"   {row[0]}: {row[1]} calories (from {row[2]} items)")


def query_6_items_by_category(conn):
    """Count items by category"""
    print("\n6. Items by Category")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT category, COUNT(*) as item_count
        FROM nutrition_data
        WHERE category IS NOT NULL AND category != ''
        GROUP BY category
        ORDER BY item_count DESC
        LIMIT 10
    """)

    for row in cursor.fetchall():
        print(f"   {row[0]}: {row[1]} items")


def query_7_balanced_meals(conn):
    """Find balanced meals (good protein, moderate calories)"""
    print("\n7. Balanced Meals (15-25g protein, 300-500 cal)")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT name, calories, protein, total_fat, total_carbohydrate,
               dining_hall, meal_type
        FROM nutrition_data
        WHERE protein BETWEEN 15 AND 25
        AND calories BETWEEN 300 AND 500
        ORDER BY protein DESC
        LIMIT 10
    """)

    for row in cursor.fetchall():
        print(f"   {row[0]}")
        print(f"      {row[1]} cal | P:{row[2]}g F:{row[3]}g C:{row[4]}g | {row[5]} - {row[6]}")


def query_8_search_by_name(conn, search_term):
    """Search for items by name"""
    print(f"\n8. Search Results for '{search_term}'")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT name, calories, protein, dining_hall, meal_type
        FROM nutrition_data
        WHERE name LIKE ?
        ORDER BY calories DESC
        LIMIT 15
    """, (f'%{search_term}%',))

    results = cursor.fetchall()
    if not results:
        print(f"   No items found matching '{search_term}'")
    else:
        for row in results:
            print(f"   {row[0]}: {row[1]} cal, {row[2]}g protein ({row[3]}, {row[4]})")


def query_9_meals_by_date(conn, date):
    """Get all meals for a specific date"""
    print(f"\n9. All Meals for {date}")
    print("-" * 60)

    cursor = conn.cursor()
    cursor.execute("""
        SELECT meal_type, COUNT(*) as item_count,
               ROUND(AVG(calories), 1) as avg_calories
        FROM nutrition_data
        WHERE date LIKE ?
        GROUP BY meal_type
        ORDER BY
            CASE meal_type
                WHEN 'Breakfast' THEN 1
                WHEN 'Lunch' THEN 2
                WHEN 'Dinner' THEN 3
                ELSE 4
            END
    """, (f'%{date}%',))

    for row in cursor.fetchall():
        print(f"   {row[0]}: {row[1]} items (avg {row[2]} cal)")


def query_10_nutritional_stats(conn):
    """Overall nutritional statistics"""
    print("\n10. Overall Database Statistics")
    print("-" * 60)

    cursor = conn.cursor()

    # Total items
    cursor.execute("SELECT COUNT(*) FROM nutrition_data")
    total = cursor.fetchone()[0]
    print(f"   Total items: {total}")

    # Unique dates
    cursor.execute("SELECT COUNT(DISTINCT date) FROM nutrition_data")
    dates = cursor.fetchone()[0]
    print(f"   Unique dates: {dates}")

    # Dining halls
    cursor.execute("SELECT COUNT(DISTINCT dining_hall) FROM nutrition_data")
    halls = cursor.fetchone()[0]
    print(f"   Dining halls: {halls}")

    # Average nutrition per item
    cursor.execute("""
        SELECT ROUND(AVG(calories), 1),
               ROUND(AVG(protein), 1),
               ROUND(AVG(total_fat), 1),
               ROUND(AVG(total_carbohydrate), 1)
        FROM nutrition_data
        WHERE calories > 0
    """)
    avg = cursor.fetchone()
    print(f"\n   Average per item:")
    print(f"      Calories: {avg[0]}")
    print(f"      Protein: {avg[1]}g")
    print(f"      Fat: {avg[2]}g")
    print(f"      Carbs: {avg[3]}g")


def main():
    """Run all example queries"""
    print("="*60)
    print("NUTRITION DATABASE - EXAMPLE QUERIES")
    print("="*60)

    # Connect to database
    conn = connect_db()

    # Run all queries
    query_1_items_by_dining_hall(conn)
    query_2_high_protein_items(conn)
    query_3_low_calorie_items(conn)
    query_4_breakfast_items_isr(conn)
    query_5_avg_calories_by_meal(conn)
    query_6_items_by_category(conn)
    query_7_balanced_meals(conn)
    query_8_search_by_name(conn, "chicken")
    query_9_meals_by_date(conn, "November 18")
    query_10_nutritional_stats(conn)

    print("\n" + "="*60)
    print("Done! Modify this file to create your own queries.")
    print("="*60)

    conn.close()


if __name__ == "__main__":
    main()
