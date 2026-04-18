from google.adk.agents import Agent
import os
import requests
from sub_agents.property_recommendation.tools.google_maps import calculate_commute_time
from sub_agents.property_recommendation.tools.zillow import fetch_purchase_listings

def check_property_grant_eligibility(property_address: str) -> dict:
    """
    Checks if a specific property qualifies for localized housing grants.
    In production, this queries your internal HomePilot database or microservice.
    """
    # Assuming you set up an API Gateway/Lambda endpoint for your internal database
    internal_api_url = os.environ.get("HOMEPILOT_INTERNAL_API_URL", "https://api.yourdomain.com/v1/grants/check")
    
    payload = {
        "address": property_address
    }

    try:
        # We use a short timeout because internal microservices should be fast
        response = requests.post(internal_api_url, json=payload, timeout=3)
        
        # If your backend isn't up yet, gracefully catch the failure and return safe defaults
        if response.status_code != 200:
            return {
                "property": property_address,
                "eligible_grants": [],
                "total_grant_value": 0,
                "note": "Internal grant service unavailable."
            }
            
        data = response.json()
        
        return {
            "property": property_address,
            "eligible_grants": data.get("eligible_programs", []),
            "total_grant_value": data.get("total_value", 0)
        }

    except requests.exceptions.RequestException:
        # Failsafe for the agent so it doesn't crash if the microservice is down
        return {
            "property": property_address,
            "eligible_grants": [],
            "total_grant_value": 0,
            "note": "Failed to connect to grant eligibility service."
        }


property_agent = Agent(
    name="property_recommendation_agent",
    model="gemini-2.5-flash",
    description="Analyzes housing listings and ranks them based on affordability, user preferences, and grant eligibility.",
    instruction="""
    You are the Property Recommendation Agent for HomePilot AI. 
    Your objective is to find the best housing listings for the user, evaluate them against their lifestyle constraints, and rank them.
    
    Execution Strategy:
    1. Use 'fetch_purchase_listings' to pull available homes in the requested area that fit the user's budget and family size.
    2. If the user provides a work location, use 'calculate_commute_time' on the top listings.
    3. Use 'check_property_grant_eligibility' to determine if the homes qualify for assistance that could offset the purchase price.
    
    Response Rules:
    - Always present a ranked list.
    - Explicitly state WHY a property is ranked where it is.
    - If a home is slightly over budget but qualifies for a grant that brings it into range, highlight that financial strategy.
    """,
    tools=[fetch_purchase_listings, calculate_commute_time, check_property_grant_eligibility]
)

root_agent = property_agent
