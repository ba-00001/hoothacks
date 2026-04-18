import os
import requests
from dotenv import load_dotenv

load_dotenv()

def fetch_purchase_listings(zip_code: str, max_price: int, min_bedrooms: int) -> list:
    """
    Fetches real-time property listings based on location, budget, and household size.
    Requires RAPIDAPI_KEY environment variable.
    """
    api_key = os.environ.get("RAPIDAPI_KEY")
    if not api_key:
        raise ValueError("RAPIDAPI_KEY environment variable is not set.")

    url = "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch"
    
    # Query parameters tailored for Zillow's API structure
    querystring = {
        "location": zip_code,
        "maxPrice": str(max_price),
        "bedsMin": str(min_bedrooms),
        "home_type": "Houses,Condos",
        "status_type": "ForSale"
    }

    headers = {
        "X-RapidAPI-Key": api_key,
        "X-RapidAPI-Host": "zillow-com1.p.rapidapi.com"
    }

    try:
        response = requests.get(url, headers=headers, params=querystring, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        # Parse and normalize the data for the agent
        formatted_listings = []
        for prop in data.get("props", [])[:10]: # Limit to top 10 to save agent context window
            formatted_listings.append({
                "id": prop.get("zpid"),
                "address": prop.get("address"),
                "price": prop.get("price"),
                "bedrooms": prop.get("bedrooms"),
                "type": prop.get("propertyType")
            })
            
        return formatted_listings

    except requests.exceptions.RequestException as e:
        print(f"Error fetching listings: {e}")
        return [] # Return empty list so the agent can gracefully fail and inform the user


if __name__ == "__main__":
    import json

    # --- Test 1: Zillow Listings (Requires RAPIDAPI_KEY) ---
    print("--- Test 1: fetch_purchase_listings ---")
    try:
        # Testing with a higher budget to ensure we get results even in expensive markets
        listings = fetch_purchase_listings(zip_code="33173", max_price=850000, min_bedrooms=2)
        if listings:
            print(f"✅ Success! Found {len(listings)} listings.")
            print(f"First result: {json.dumps(listings[0], indent=2)}")
        else:
            print("⚠️ Success, but no listings found (Check your area/budget criteria or API response).")
    except ValueError as e:
        print(f"⏭️ Skipped: {e}")
    except Exception as e:
        print(f"❌ Failed: {e}")
    print("\n")