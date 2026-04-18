from google.adk.agents import Agent

def calculate_dti_estimate(annual_income: int, monthly_debts: int) -> dict:
    """
    Calculates the user's Debt-to-Income (DTI) ratio, a crucial metric for both landlords and lenders.
    """
    if annual_income <= 0:
        return {"error": "Income must be greater than zero."}
        
    monthly_income = annual_income / 12
    dti_percentage = (monthly_debts / monthly_income) * 100
    
    return {
        "monthly_income": round(monthly_income, 2),
        "total_monthly_debts": monthly_debts,
        "dti_percentage": round(dti_percentage, 1),
        "status": "Healthy" if dti_percentage <= 36 else "Elevated" if dti_percentage <= 43 else "High"
    }

def estimate_rent_range(annual_income: int) -> dict:
    """
    Calculates an affordable rent range based on the standard 30% gross income rule.
    Now includes automated calculations for standard move-in costs (First, Last, Security).
    """
    # Conservative budget: 25% of gross income
    min_rent = (annual_income * 0.25) / 12
    # Maximum recommended budget: 30% of gross income
    max_rent = (annual_income * 0.30) / 12
    
    # The "40x rule" which many landlords use for strict income verification
    landlord_max_approval = annual_income / 40

    # Based on the recommended max rent to ensure the user is financially prepared
    first_month = max_rent
    last_month = max_rent
    security_deposit = max_rent # Typically equal to one month's rent

    return {
        "recommended_min_rent": round(min_rent, 0),
        "recommended_max_rent": round(max_rent, 0),
        "landlord_approval_limit": round(landlord_max_approval, 0),
        "move_in_costs": {
            "first_months_rent": round(first_month, 0),
            "last_months_rent": round(last_month, 0),
            "security_deposit": round(security_deposit, 0),
            "total_estimated_cash_needed": round(first_month + last_month + security_deposit, 0)
        }
    }

def estimate_purchase_range(annual_income: int, monthly_debts: int, current_savings: int = 0) -> dict:
    """
    Provides a high-level estimate of an affordable home purchase price based on the 28/36 rule.
    Now includes automated calculations for necessary down payments and closing costs.
    """
    monthly_income = annual_income / 12
    max_front = monthly_income * 0.28
    max_back = (monthly_income * 0.36) - monthly_debts
    max_monthly_payment = min(max_front, max_back)
    
    # Assume 20% of the payment goes to taxes and insurance, leaving 80% for P&I
    pi_capacity = max_monthly_payment * 0.80
    
    # Reverse amortization at 6.5% over 30 years
    interest_rate = 6.5
    monthly_rate = (interest_rate / 100) / 12
    num_payments = 30 * 12 
    
    if monthly_rate > 0:
        max_loan_amount = pi_capacity * (((1 + monthly_rate)**num_payments - 1) / (monthly_rate * (1 + monthly_rate)**num_payments))
    else:
        max_loan_amount = pi_capacity * num_payments
        
    estimated_max_price = max_loan_amount + current_savings

    # Closing costs usually average 3% of the purchase price
    estimated_closing_costs = estimated_max_price * 0.03
    
    # Minimum down payment (e.g., standard FHA 3.5%)
    min_down_payment = estimated_max_price * 0.035
    
    # Ideal down payment (20% to avoid Private Mortgage Insurance)
    ideal_down_payment = estimated_max_price * 0.20

    return {
        "max_monthly_mortgage_budget": round(max_monthly_payment, 0),
        "estimated_max_home_price": round(estimated_max_price, 0),
        "cash_requirements": {
            "estimated_closing_costs": round(estimated_closing_costs, 0),
            "minimum_down_payment_3_5_percent": round(min_down_payment, 0),
            "ideal_down_payment_20_percent": round(ideal_down_payment, 0),
            "total_minimum_cash_to_close": round(min_down_payment + estimated_closing_costs, 0)
        }
    }


affordability_agent = Agent(
    name="affordability_agent",
    model="gemini-2.5-flash",
    description="Estimates affordable rent ranges, home purchase ranges, and calculates debt-to-income ratios.",
    instruction="""
    You are the Affordability Agent for HomePilot AI.
    Your objective is to establish the baseline financial parameters for the user's housing search, ensuring they are prepared for the upfront cash costs of their chosen path.
    
    Execution Strategy:
    1. Always calculate the user's DTI using 'calculate_dti_estimate'.
    2. Detect the user's intent:
       - If the user explicitly asks ONLY about renting, strictly use 'estimate_rent_range'.
       - If the user explicitly asks ONLY about buying, strictly use 'estimate_purchase_range'.
       - If the user asks about both, or if the question is general/vague (e.g., "What can I afford?", "What is my budget?"), use BOTH tools and present both options.
    
    Response Rules:
    - Output must be extremely clear and direct.
    - Format numbers beautifully (e.g., $950-$1,400).
    - IF presenting a Buying Budget: You MUST include a "Cash Needed to Close" section separating the Down Payment from the Estimated Closing Costs.
    - IF presenting a Renting Budget: You MUST include a "Cash Needed to Move In" section (First, Last, Security).
    - If the user's stated savings are lower than the total cash needed for their chosen option(s), politely advise them of the shortfall and suggest alternatives or point them to the Grant Agent.
    """,
    tools=[calculate_dti_estimate, estimate_rent_range, estimate_purchase_range]
)

root_agent = affordability_agent
