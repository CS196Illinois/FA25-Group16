"""
Illinois Dining Halls - Complete Nutrition Scraper
===================================================
Scrapes ALL dining halls and services for the next 7 days (including today)
Exports comprehensive nutrition data to Excel

Usage:
    python scrape_all_dining_halls.py

Output:
    all_dining_halls_YYYYMMDD_HHMMSS.xlsx
"""

from Nutrition_scraping import NutritionScraperComplete
from datetime import datetime

# ============================================================================
# CONFIGURATION
# ============================================================================
DAYS_TO_SCRAPE = 7  # Number of days to scrape (including today)
OUTPUT_FILENAME = f"all_dining_halls_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"

# ============================================================================
# MAIN EXECUTION
# ============================================================================

def main():
    """Main function to scrape all dining halls"""

    print("\n" + "="*80)
    print("ILLINOIS DINING HALLS - COMPLETE NUTRITION SCRAPER")
    print("="*80)
    print(f"Configuration:")
    print(f"  - Target: ALL dining halls and services")
    print(f"  - Days to scrape: {DAYS_TO_SCRAPE} (including today)")
    print(f"  - Output file: {OUTPUT_FILENAME}")
    print("="*80 + "\n")

    # Initialize scraper (testing_mode=False for full scraping)
    scraper = NutritionScraperComplete(testing_mode=False)

    try:
        # Scrape all dining halls for the specified number of days
        print("Starting comprehensive scraping...\n")
        all_results = scraper.scrape_all_with_complete_data(days_to_scrape=DAYS_TO_SCRAPE)

        if all_results:
            print(f"\n{'='*80}")
            print("SCRAPING COMPLETE - RESULTS SUMMARY")
            print(f"{'='*80}")

            # Calculate statistics
            unique_halls = set(r['dining_hall'] for r in all_results)
            unique_services = set(r['service'] for r in all_results)
            unique_dates = set(r['date'] for r in all_results)
            unique_meals = set(r['meal_type'] for r in all_results)
            unique_categories = set(r['category'] for r in all_results)

            print(f"\n📊 Statistics:")
            print(f"  Total items scraped: {len(all_results)}")
            print(f"  Dining halls: {len(unique_halls)}")
            print(f"  Services: {len(unique_services)}")
            print(f"  Dates: {len(unique_dates)}")
            print(f"  Meal types: {len(unique_meals)}")
            print(f"  Food categories: {len(unique_categories)}")

            # Show dining halls
            print(f"\n🏛️  Dining Halls Scraped:")
            for hall in sorted(unique_halls):
                count = len([r for r in all_results if r['dining_hall'] == hall])
                print(f"  - {hall}: {count} items")

            # Show dates
            print(f"\n📅 Dates Covered:")
            for date in sorted(unique_dates):
                count = len([r for r in all_results if r['date'] == date])
                print(f"  - {date}: {count} items")

            # Show meal types
            print(f"\n🍽️  Meal Types: {', '.join(sorted(unique_meals))}")

            # Export to Excel
            print(f"\n{'='*80}")
            print("EXPORTING TO EXCEL...")
            print(f"{'='*80}")

            excel_file = scraper.export_to_excel(all_results, filename=OUTPUT_FILENAME)

            if excel_file:
                print(f"\n✅ SUCCESS! Data exported to:")
                print(f"   {excel_file}")
                print(f"\n📁 Full path:")
                import os
                full_path = os.path.abspath(excel_file)
                print(f"   {full_path}")

                # Show sample items
                print(f"\n📋 Sample Items (first 10):")
                for i, r in enumerate(all_results[:10], 1):
                    print(f"  {i}. {r['name']}")
                    print(f"     [{r['dining_hall']} - {r['service']}]")
                    print(f"     {r['date']}, {r['meal_type']} | {r['calories']} cal")

                print(f"\n{'='*80}")
                print("🎉 ALL DONE! Check your Excel file for complete data.")
                print(f"{'='*80}\n")

            else:
                print("\n❌ ERROR: Failed to export to Excel")

        else:
            print("\n❌ ERROR: No data was scraped")
            print("Please check your internet connection and try again.")

    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user (Ctrl+C)")
        print("Partial data may have been collected.")

    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
        import traceback
        traceback.print_exc()

    finally:
        scraper.close()
        print("\n🔒 Browser closed.")


if __name__ == "__main__":
    main()
