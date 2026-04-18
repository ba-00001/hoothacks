from google.adk.agents import Agent
from sub_agents.grant_matching.tools.federal_hud import find_housing_agencies 

def evaluate_grant_eligibility(annual_income: int, household_size: int, is_first_time_buyer: bool, is_student: bool) -> list:
    """
    Evaluates baseline eligibility for broad categories of state and federal housing assistance.
    """
    eligible_programs = []
    
    if annual_income < (50000 + (household_size * 5000)):
        if is_first_time_buyer:
            eligible_programs.append({
                "program_type": "first_time_buyer",
                "display_name": "First-Time Homebuyer Down Payment Assistance",
                "estimated_value": "$5,000 - $15,000",
                "notes": "Requires completion of a HUD-approved homebuyer education course."
            })
            
    if annual_income < 40000:
        eligible_programs.append({
            "program_type": "rental_assistance",
            "display_name": "Statewide Rental Assistance / Section 8",
            "estimated_value": "Varies based on local Fair Market Rent",
            "notes": "Long waitlists often apply. Priority given to families and essential workers."
        })
        
    if is_student and annual_income < 30000:
        eligible_programs.append({
            "program_type": "student_housing",
            "display_name": "Student Housing Support Initiatives",
            "estimated_value": "Up to $5,000 annually",
            "notes": "Subject to local university and municipal partnerships."
        })
        
    return eligible_programs


grant_agent = Agent(
    name="grant_matching_agent",
    model="gemini-2.5-flash",
    description="Evaluates user eligibility for housing assistance and connects them with highly specific local HUD grant administrators.",
    instruction="""
    You are the Grant Matching Agent for HomePilot AI.
    Your objective is to tell the user what type of financial assistance they likely qualify for, and then give them the exact local organizations to contact to claim it.
    
    Execution Strategy:
    1. First, use 'evaluate_grant_eligibility' based on the user's financial profile and statuses.
    2. IMMEDIATELY use 'find_housing_agencies' using the user's zip code. Based on the 'program_category' results from step 1, set the corresponding boolean parameters to `True` (e.g., `first_time_buyer=True`, `rental_assistance=True`) so you only find highly relevant agencies.
    
    Response Rules:
    - First, list the broad programs the user qualifies for, their estimated dollar value, and any notes.
    - Second, present the list of HUD-approved agencies retrieved from the tool. 
    - Format the agency contacts clearly: Name, Distance (miles), Phone, Website, and supported Languages.
    - If the tool returns an error or no agencies (even after expanding the radius), clearly communicate this to the user.
    - Conclude by explaining to the user that they must contact these specific agencies to formally apply for the funds.
    """,
    tools=[evaluate_grant_eligibility, find_housing_agencies]
)

root_agent = grant_agent