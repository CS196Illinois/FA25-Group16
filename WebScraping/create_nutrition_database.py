"""
Create SQLite database for nutrition data
This creates the proper schema to match the scraped nutrition data
"""
import sqlite3
import os


def create_database(db_file='nutrition_data.db'):
    """Create the nutrition database with proper schema"""

    # Connect to database (creates if doesn't exist)
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()

    print(f"Creating database: {db_file}\n")

    # Create nutrition_data table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS nutrition_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dining_hall TEXT NOT NULL,
            service TEXT NOT NULL,
            date TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            category TEXT,
            name TEXT NOT NULL,
            serving_size TEXT,
            calories REAL DEFAULT 0,
            total_fat REAL DEFAULT 0,
            saturated_fat REAL DEFAULT 0,
            trans_fat REAL DEFAULT 0,
            cholesterol REAL DEFAULT 0,
            sodium REAL DEFAULT 0,
            potassium REAL DEFAULT 0,
            total_carbohydrate REAL DEFAULT 0,
            dietary_fiber REAL DEFAULT 0,
            sugars REAL DEFAULT 0,
            protein REAL DEFAULT 0,
            scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    print("✓ Created table: nutrition_data")

    # Create indexes for better query performance
    cursor.execute('''
        CREATE INDEX IF NOT EXISTS idx_dining_hall
        ON nutrition_data(dining_hall)
    ''')
    print("✓ Created index: idx_dining_hall")

    cursor.execute('''
        CREATE INDEX IF NOT EXISTS idx_date_meal
        ON nutrition_data(date, meal_type)
    ''')
    print("✓ Created index: idx_date_meal")

    cursor.execute('''
        CREATE INDEX IF NOT EXISTS idx_name
        ON nutrition_data(name)
    ''')
    print("✓ Created index: idx_name")

    cursor.execute('''
        CREATE INDEX IF NOT EXISTS idx_category
        ON nutrition_data(category)
    ''')
    print("✓ Created index: idx_category")

    conn.commit()

    # Display table schema
    print("\n" + "="*60)
    print("TABLE SCHEMA")
    print("="*60)
    cursor.execute("PRAGMA table_info(nutrition_data)")
    columns = cursor.fetchall()

    for col in columns:
        col_id, name, type_, not_null, default, pk = col
        print(f"{name:20} {type_:15} {'PRIMARY KEY' if pk else ''}")

    print("\n✓ Database created successfully!")
    print(f"Location: {os.path.abspath(db_file)}")

    conn.close()

    return db_file


if __name__ == "__main__":
    create_database()
