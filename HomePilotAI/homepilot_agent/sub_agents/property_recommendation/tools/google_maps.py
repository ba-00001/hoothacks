import os
import requests
from dotenv import load_dotenv

load_dotenv()

def calculate_commute_time(property_address: str, work_address: str) -> dict:
    """
    Calculates the estimated driving commute time between a property and the user's workplace.
    """
    api_key = os.environ.get("GOOGLE_MAPS_API_KEY")
    if not api_key:
        raise ValueError("GOOGLE_MAPS_API_KEY environment variable is not set.")

    url = "https://maps.googleapis.com/maps/api/distancematrix/json"
    
    params = {
        "origins": property_address,
        "destinations": work_address,
        "mode": "driving",
        "departure_time": "now", # Can be modified for typical rush hour timestamps
        "key": api_key
    }

    try:
        response = requests.get(url, params=params, timeout=5)
        response.raise_for_status()
        data = response.json()

        if data["status"] == "OK":
            elements = data["rows"][0]["elements"][0]
            if elements["status"] == "OK":
                duration_secs = elements["duration"]["value"]
                return {
                    "property": property_address,
                    "workplace": work_address,
                    "commute_time_mins": duration_secs // 60,
                    "mode": "driving"
                }
        
        # Fallback if route not found
        return {
            "property": property_address,
            "error": "Could not calculate route.",
            "status": data.get("status")
        }

    except requests.exceptions.RequestException as e:
        print(f"Error calculating commute: {e}")
        return {"error": "Commute API failed"}
    

if __name__ == "__main__":
    import json

    print("🚀 Testing calculate_commute_time function...\n")

    # Define test scenarios
    test_cases = [
        {
            "description": "Zip Code to City Center",
            "origin": "33431", 
            "destination": "Downtown Fort Lauderdale, FL"
        },
        {
            "description": "Specific Addresses",
            "origin": "1600 Amphitheatre Parkway, Mountain View, CA",
            "destination": "1 Infinite Loop, Cupertino, CA"
        }
    ]

    for i, test in enumerate(test_cases, 1):
        print(f"--- Test {i}: {test['description']} ---")
        print(f"From: {test['origin']}")
        print(f"To:   {test['destination']}")
        
        try:
            result = calculate_commute_time(
                property_address=test['origin'],
                work_address=test['destination']
            )
            print("Response:")
            print(json.dumps(result, indent=2))
            
        except ValueError as e:
            print(f"⏭️ Skipped: {e}\n(Make sure to run: export GOOGLE_MAPS_API_KEY='your_key_here')")
        except Exception as e:
            print(f"❌ Failed with unexpected error: {e}")
            
        print("-" * 40 + "\n")