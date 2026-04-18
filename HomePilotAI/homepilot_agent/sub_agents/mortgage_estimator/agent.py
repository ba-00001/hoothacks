from google.adk.agents import Agent


def calculate_mortgage_payment(home_price: int, down_payment: int, interest_rate: float, loan_term_years: int = 30) -> dict:
    """
    Calculates the estimated total monthly mortgage payment including Principal, Interest, Taxes, and Insurance (PITI).
    """
    principal = home_price - down_payment
    monthly_rate = (interest_rate / 100) / 12
    num_payments = loan_term_years * 12

    # Standard amortization formula
    if monthly_rate == 0:
        pi_payment = principal / num_payments
    else:
        pi_payment = principal * (monthly_rate * (1 + monthly_rate)**num_payments) / ((1 + monthly_rate)**num_payments - 1)

    # Estimate Taxes (National avg ~1.2% annually) and Insurance (~$1200 annually)
    monthly_tax = (home_price * 0.012) / 12
    monthly_insurance = 1200 / 12
    
    # Estimate Private Mortgage Insurance (PMI) if down payment is less than 20%
    monthly_pmi = 0
    if down_payment < (home_price * 0.20):
        monthly_pmi = (principal * 0.0075) / 12

    total = pi_payment + monthly_tax + monthly_insurance + monthly_pmi

    return {
        "home_price": home_price,
        "principal_and_interest": round(pi_payment, 2),
        "property_taxes_est": round(monthly_tax, 2),
        "home_insurance_est": round(monthly_insurance, 2),
        "pmi_est": round(monthly_pmi, 2),
        "total_monthly_payment": round(total, 2)
    }

def calculate_max_purchase_price(annual_income: int, monthly_debts: int, down_payment: int, interest_rate: float = 6.5) -> dict:
    """
    Reverse-engineers the maximum affordable home price based on the 28/36 Debt-to-Income (DTI) banking rule.
    """
    monthly_income = annual_income / 12
    
    # Front-end ratio (Housing costs only): Max 28% of gross income
    max_housing_payment_front = monthly_income * 0.28
    
    # Back-end ratio (Total debts): Max 36% of gross income
    max_housing_payment_back = (monthly_income * 0.36) - monthly_debts

    # Banks use the more conservative (lower) of the two limits
    max_allowed_pi = min(max_housing_payment_front, max_housing_payment_back)

    # Shave off 20% to account for taxes and insurance, leaving pure Principal & Interest capacity
    max_pi_only = max_allowed_pi * 0.80

    # Reverse amortization formula
    monthly_rate = (interest_rate / 100) / 12
    num_payments = 30 * 12 

    if monthly_rate > 0:
        max_principal = max_pi_only * (((1 + monthly_rate)**num_payments - 1) / (monthly_rate * (1 + monthly_rate)**num_payments))
    else:
        max_principal = max_pi_only * num_payments

    max_home_price = max_principal + down_payment

    return {
        "recommended_max_price": int(max_home_price),
        "max_monthly_budget": round(max_allowed_pi, 2),
        "limiting_factor": "Total Existing Debts (Back-End DTI)" if max_housing_payment_back < max_housing_payment_front else "Income Level (Front-End DTI)"
    }

def evaluate_loan_readiness(credit_score: int, annual_income: int, monthly_debts: int, total_savings: int) -> dict:
    """
    Evaluates a user's financial profile and returns a readiness score (0-100) 
    along with actionable feedback for mortgage pre-approval.
    """
    score = 100
    feedback = []

    # 1. Credit Score Check
    if credit_score < 620:
        score -= 40
        feedback.append("Credit score is below the 620 minimum for conventional loans. An FHA loan (580+ minimum) is your best path.")
    elif credit_score < 680:
        score -= 15
        feedback.append("Credit score is Fair. You will qualify, but expect slightly higher interest rates.")
    else:
        feedback.append("Credit score is Good/Excellent! You are positioned for competitive interest rates.")

    # 2. Debt-to-Income (DTI) Check
    monthly_income = annual_income / 12
    dti = (monthly_debts / monthly_income) * 100 if monthly_income > 0 else 100
    
    if dti > 43:
        score -= 40
        feedback.append(f"DTI ratio is dangerously high ({round(dti)}%). Most lenders hard-cap approvals at 43%. Focus on paying off car loans or credit cards.")
    elif dti > 36:
        score -= 20
        feedback.append(f"DTI ratio is elevated ({round(dti)}%). This will restrict how much house you can buy.")
    else:
        feedback.append(f"DTI ratio is very healthy ({round(dti)}%).")

    # 3. Liquidity/Savings Check (Assuming a $10k absolute minimum for 3% down + closing on a cheap starter home)
    if total_savings < 10000:
        score -= 20
        feedback.append("Cash reserves are low. You will likely need to rely heavily on Down Payment Assistance programs or seller concessions.")

    score = max(0, score) # Prevent negative scores

    return {
        "readiness_score": score,
        "readiness_rating": "Pre-Approval Ready" if score >= 85 else "Action Required" if score >= 60 else "Not Ready",
        "feedback_points": feedback
    }


mortgage_agent = Agent(
    name="mortgage_estimator_agent",
    model="gemini-2.5-flash",
    description="Analyzes financial health to provide mortgage readiness scores, budget limits, and monthly payment estimates.",
    instruction="""
    You are the Mortgage Estimator Agent for HomePilot AI.
    Your objective is to give the user a realistic, math-backed assessment of what they can afford to buy and how likely they are to be approved by a bank.
    
    Execution Strategy:
    1. If the user asks what they can afford, use 'calculate_max_purchase_price'.
    2. If the user asks about a specific house price, use 'calculate_mortgage_payment' (assume a 6.5% interest rate if they don't specify, and assume they use their total savings as the down payment unless stated otherwise).
    3. Always run 'evaluate_loan_readiness' to give them a health check on their credit and debts.
    
    Response Rules:
    - Format numbers beautifully (e.g., $450,000 instead of 450000).
    - Give a clear, bold "Loan Readiness Score" out of 100.
    - If their score is lowered by debts or credit, firmly but politely explain what they need to fix before talking to a lender.
    """,
    tools=[calculate_mortgage_payment, calculate_max_purchase_price, evaluate_loan_readiness]
)

root_agent = mortgage_agent
