from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
import time
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime
import json

class DiningHallsScraper:
    def __init__(self):
        """Initialize the scraper with Chrome options"""
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--disable-blink-features=AutomationControlled')
        options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        
        self.driver = webdriver.Chrome(options=options)
        self.wait = WebDriverWait(self.driver, 15)
        self.base_url = "https://eatsmart.housing.illinois.edu"
    
    def scrape_dining_structure(self):
        """Scrape all dining halls and their services from the dropdown menu"""
        try:
            print("Loading main page to extract dining hall structure...")
            self.driver.get(self.base_url + "/NetNutrition/1")
            time.sleep(4)
            
            print("Extracting dining halls and services from navigation dropdown...")
            
            dropdown = self.driver.find_element(By.ID, "nav-unit-selector")
            dropdown_items = dropdown.find_elements(By.CSS_SELECTOR, ".dropdown-item")
            
            print(f"Found {len(dropdown_items)} items in dropdown\n")
            
            dining_halls = []
            current_hall = None
            
            for item in dropdown_items:
                try:
                    link = item.find_element(By.TAG_NAME, "a")
                    name = link.get_attribute('title') or link.text.strip()
                    unit_id = link.get_attribute('data-unitoid')
                    
                    if not name or not unit_id or unit_id == '-1':
                        continue
                    
                    is_primary = 'text-primary' in link.get_attribute('class')
                    
                    if is_primary:
                        if current_hall and current_hall['dining_services']:
                            dining_halls.append(current_hall)
                        
                        current_hall = {
                            'dining_hall': name,
                            'unit_id': unit_id,
                            'dining_services': []
                        }
                        print(f"Main Hall: {name} (ID: {unit_id})")
                    else:
                        if current_hall:
                            service = {
                                'service_name': name,
                                'service_id': unit_id
                            }
                            current_hall['dining_services'].append(service)
                            print(f"  Service: {name} (ID: {unit_id})")
                
                except Exception as e:
                    continue
            
            if current_hall and current_hall['dining_services']:
                dining_halls.append(current_hall)
            
            all_links = dropdown.find_elements(By.CSS_SELECTOR, ".dropdown-item a")
            
            for link in all_links:
                try:
                    name = link.text.strip()
                    unit_id = link.get_attribute('data-unitoid')
                    is_primary = 'text-primary' in link.get_attribute('class')
                    
                    if is_primary and unit_id != '-1':
                        is_parent = any(h['unit_id'] == unit_id for h in dining_halls)
                        if not is_parent:
                            standalone = {
                                'dining_hall': name,
                                'unit_id': unit_id,
                                'dining_services': []
                            }
                            dining_halls.append(standalone)
                            print(f"Standalone: {name} (ID: {unit_id})")
                except:
                    continue
            
            return dining_halls
            
        except Exception as e:
            print(f"Error scraping dining structure: {str(e)}")
            import traceback
            traceback.print_exc()
            return []
    
    def navigate_to_service(self, unit_id, service_name):
        """Navigate to a specific dining service"""
        try:
            print(f"\nNavigating to {service_name} (ID: {unit_id})...")
            
            self.driver.get(f"{self.base_url}/NetNutrition/1")
            time.sleep(4)
            
            dropdown = self.driver.find_element(By.ID, "nav-unit-selector")
            service_link = dropdown.find_element(By.CSS_SELECTOR, f"a[data-unitoid='{unit_id}']")
            
            self.driver.execute_script("arguments[0].click();", service_link)
            time.sleep(5)
            
            print("Service loaded")
            return True
            
        except Exception as e:
            print(f"Error: {str(e)}")
            return False
    
    def get_first_menu(self):
        """Get the first available menu (usually today's date)"""
        try:
            results_panel = self.driver.find_element(By.ID, "navBarResults")
            menu_items = results_panel.find_elements(By.CSS_SELECTOR, "li.list-group-item")
            
            if menu_items:
                first_menu = menu_items[0]
                menu_text = first_menu.text.strip()
                print(f"Found menu: {menu_text}")
                return first_menu, menu_text
            
            return None, None
            
        except Exception as e:
            print(f"Error finding menu: {str(e)}")
            return None, None
    
    def click_menu(self, menu_element):
        """Click menu to load items"""
        try:
            print("Clicking menu...")
            self.driver.execute_script("arguments[0].click();", menu_element)
            time.sleep(8)
            print("Menu loaded")
            return True
        except Exception as e:
            print(f"Error: {str(e)}")
            return False
    
    def extract_menu_items(self):
        """Extract all menu item names"""
        try:
            print("Extracting menu items...")
            
            items = self.driver.find_elements(By.CSS_SELECTOR, ".cbo_nn_itemHover")
            print(f"Found {len(items)} items\n")
            
            menu_items = []
            
            for i, item in enumerate(items, 1):
                try:
                    inner_html = item.get_attribute('innerHTML')
                    soup = BeautifulSoup(inner_html, 'html.parser')
                    
                    text_parts = []
                    for content in soup.contents:
                        if isinstance(content, str):
                            text_parts.append(content.strip())
                    
                    food_name = ' '.join(text_parts).strip()
                    
                    if food_name:
                        menu_items.append(food_name)
                        print(f"  {i}. {food_name}")
                
                except Exception as e:
                    continue
            
            print(f"\nExtracted {len(menu_items)} items")
            return menu_items
            
        except Exception as e:
            print(f"Error: {str(e)}")
            import traceback
            traceback.print_exc()
            return []
    
    def scrape_all_services(self):
        """Scrape all dining halls and services"""
        all_results = []
        
        print("="*80)
        print("Illinois Dining Menu Scraper")
        print("="*80)
        
        dining_halls = self.scrape_dining_structure()
        
        if not dining_halls:
            print("Failed to get dining structure")
            return all_results
        
        total_services = sum(len(h['dining_services']) for h in dining_halls)
        print(f"\nTotal services to scrape: {total_services}\n")
        
        service_count = 0
        for hall in dining_halls:
            hall_name = hall['dining_hall']
            
            print(f"\n{'='*80}")
            print(f"Processing: {hall_name}")
            print(f"{'='*80}")
            
            if not hall['dining_services']:
                print(f"No services found for {hall_name}")
                continue
            
            for service in hall['dining_services']:
                service_count += 1
                service_name = service['service_name']
                service_id = service['service_id']
                
                print(f"\n[{service_count}/{total_services}]")
                
                if not self.navigate_to_service(service_id, service_name):
                    print(f"Skipping {service_name}")
                    continue
                
                menu_element, menu_text = self.get_first_menu()
                if not menu_element:
                    print(f"No menu found for {service_name}")
                    continue
                
                if not self.click_menu(menu_element):
                    print(f"Failed to click menu for {service_name}")
                    continue
                
                menu_items = self.extract_menu_items()
                
                result = {
                    'dining_hall': hall_name,
                    'service': service_name,
                    'date': menu_text,
                    'items': menu_items,
                    'item_count': len(menu_items),
                    'scraped_at': datetime.now().isoformat()
                }
                
                all_results.append(result)
                print(f"Stored {len(menu_items)} items for {service_name}")
        
        print(f"\n{'='*80}")
        print("Scraping complete!")
        print(f"{'='*80}")
        print(f"Total services scraped: {len(all_results)}")
        
        return all_results
    
    def export_to_excel(self, all_results, filename=None):
        """Export results to Excel"""
        if not all_results:
            print("No data to export")
            return None
        
        try:
            if not filename:
                filename = f"dining_menu_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
            
            print(f"\nExporting to Excel...")
            
            flattened_data = []
            for result in all_results:
                for item in result['items']:
                    flattened_data.append({
                        'dining_hall': result['dining_hall'],
                        'service': result['service'],
                        'date': result['date'],
                        'menu_item': item,
                        'scraped_at': result['scraped_at']
                    })
            
            df = pd.DataFrame(flattened_data)
            
            with pd.ExcelWriter(filename, engine='openpyxl') as writer:
                df.to_excel(writer, sheet_name='Menu Items', index=False)
                
                workbook = writer.book
                worksheet = writer.sheets['Menu Items']
                
                for column in worksheet.columns:
                    max_length = 0
                    column_letter = column[0].column_letter
                    
                    for cell in column:
                        try:
                            if len(str(cell.value)) > max_length:
                                max_length = len(str(cell.value))
                        except:
                            pass
                    
                    adjusted_width = min(max_length + 2, 50)
                    worksheet.column_dimensions[column_letter].width = adjusted_width
                
                from openpyxl.styles import Font, PatternFill, Alignment
                
                header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
                header_font = Font(bold=True, color="FFFFFF")
                
                for cell in worksheet[1]:
                    cell.fill = header_fill
                    cell.font = header_font
                    cell.alignment = Alignment(horizontal="center", vertical="center")
            
            print(f"Exported to {filename}")
            print(f"Total rows: {len(df)}")
            print(f"Columns: {', '.join(df.columns)}")
            
            return filename
            
        except Exception as e:
            print(f"Error exporting to Excel: {str(e)}")
            import traceback
            traceback.print_exc()
            return None
    
    def export_to_json(self, all_results, filename=None):
        """Export results to JSON"""
        if not all_results:
            print("No data to export")
            return None
        
        try:
            if not filename:
                filename = f"dining_menu_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(all_results, f, indent=2, ensure_ascii=False)
            
            print(f"Exported to {filename}")
            return filename
            
        except Exception as e:
            print(f"Error exporting to JSON: {str(e)}")
            return None
    
    def close(self):
        """Close the browser"""
        self.driver.quit()


if __name__ == "__main__":
    scraper = DiningHallsScraper()
    
    try:
        all_results = scraper.scrape_all_services()
        
        if all_results:
            print(f"\n{'='*80}")
            print("Results Summary")
            print(f"{'='*80}")
            
            total_items = sum(r['item_count'] for r in all_results)
            print(f"Total dining halls: {len(set(r['dining_hall'] for r in all_results))}")
            print(f"Total services: {len(all_results)}")
            print(f"Total menu items: {total_items}")
            
            print(f"\nDetailed Breakdown:")
            for result in all_results:
                print(f"\n{result['dining_hall']} - {result['service']}")
                print(f"Date: {result['date']}")
                print(f"Items: {result['item_count']}")
            
            print(f"\n{'='*80}")
            print("Exporting Results")
            print(f"{'='*80}")
            
            excel_file = scraper.export_to_excel(all_results)
            json_file = scraper.export_to_json(all_results)
            
            print(f"\nSuccess!")
            if excel_file:
                print(f"Excel: {excel_file}")
            if json_file:
                print(f"JSON: {json_file}")
        else:
            print("Failed to scrape menus")
    
    except KeyboardInterrupt:
        print("\n\nInterrupted by user")
    except Exception as e:
        print(f"\nError: {str(e)}")
        import traceback
        traceback.print_exc()
    finally:
        scraper.close()
        print("Browser closed.")