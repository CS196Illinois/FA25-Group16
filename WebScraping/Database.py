import sqlite3
import pandas as pd

df = pd.read_csv("nutrition_with_meals_20251104_012147.csv")

conn = sqlite3.connect("mydatabase.db")
cursor = conn.cursor()

cursor.execute("DROP TABLE IF EXISTS meals")

cursor.execute("""CREATE TABLE IF NOT EXISTS meals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    dining_hall TEXT NOT NULL,
    service TEXT,
    serving_size TEXT,
    calories TEXT NOT NULL
);""")

print("Table created successfully!")

conn.commit()

df = df[["name", "dining_hall", "service", "serving_size", "calories"]]


for _, row in df.iterrows():
    cursor.execute('''
        INSERT INTO meals (name, dining_hall, service, serving_size, calories)
        VALUES (?, ?, ?, ?, ?)
    ''', (row["name"], row["dining_hall"], row["service"], row["serving_size"], row["calories"]))

conn.commit()

cursor.execute("SELECT name, dining_hall, service, serving_size, calories FROM meals")
rows = cursor.fetchall()

print("SELECT name, dining_hall, service, serving_size, calories FROM meals")
for row in rows:
    print(f"{row[0]} - {row[1]}")

conn.close()