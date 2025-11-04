import sqlite3


conn = sqlite3.connect("mydatabase.db")
cursor = conn.cursor()

"""CREATE TABLE IkeDining (
    name TEXT PRIMARY KEY AUTOINCREMENT,
    diningHall TEXT PRIMARY KEY AUTOINCREMENT)
    """
print("Table created successfully!")

conn.commit()

meals = [
    {"date": "2025-11-04", "meal_type": "Lunch", "item_name": "Chicken Sandwich", "calories": 320},
    {"date": "2025-11-04", "meal_type": "Dinner", "item_name": "Vegetable Stir Fry", "calories": 280}
]
for meal in meals:
    cursor.execute('''
        INSERT INTO meals (date, meal_type, item_name, calories, allergens)
        VALUES (?, ?, ?, ?, ?)
    ''', (meal["date"], meal["meal_type"], meal["item_name"], meal["calories"], meal["allergens"]))

conn.commit()

cursor.execute("SELECT * FROM meals")