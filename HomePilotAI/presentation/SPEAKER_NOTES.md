# HomePilot AI - Hackathon Speaker Notes & Demo Script

## Slide 1: Title / Introduction
**Speaker:** 
"Hi everyone, we are excited to present HomePilot AI. It’s a full-stack housing affordability assistant designed to help renters and first-time homebuyers navigate the complicated and often overwhelming real estate market."

## Slide 2: The Problem (AI for Good Challenge Fit)
**Speaker:** 
"Our project addresses a massive real-world problem outside of typical college life: housing affordability. Today, many renters and aspiring homeowners struggle to figure out what they can actually afford. They don’t know which government grants or assistance programs they qualify for, and they waste time looking at listings that are financially out of reach. We wanted to build an AI solution not just for convenience, but for equity—to reduce housing confusion and improve access to support programs."

## Slide 3: The Solution
**Speaker:** 
"Enter HomePilot AI. Instead of giving users generic financial calculators, our app turns messy financial data into practical, personalized guidance. It estimates safe rent and home-buying budgets, matches users automatically with grants, and ranks real estate listings based on affordability, personal fit, and likelihood of support eligibility."

## Slide 4: Key Features
**Speaker:** 
"We’ve built a comprehensive suite of tools. Users can run our AI Affordability Estimator to get a reality check on their budget. Our Grant Eligibility Matcher scans available programs to find free money they might qualify for. We also feature Property Recommendation Ranking, which scores listings out of 100 based on the user's unique profile, plus a Mortgage Readiness estimator to help them plan for the future."

## Slide 5: Tech Stack & Architecture
**Speaker:** 
"Under the hood, HomePilot AI is a robust, full-stack application. The frontend is built with Flutter, allowing it to run smoothly on iOS, Android, and Web. The backend is powered by Spring Boot and secured with JWT authentication. We built a modular AI agent connector system, separating affordability, grants, recommendations, and mortgage calculations so we can easily plug in external LLMs like Gemini in the future."

## Slide 6: Revenue Model (B2B2C)
**Speaker:** 
"To make this sustainable, we’ve designed a B2B2C revenue model. The app is completely free for renters and buyers. Instead, landlords and real estate agents pay to list properties directly to our pre-qualified users. We offer a Free Trial, a Basic tier for $29/month, and a Premium tier for $79/month which provides priority ranking in our AI recommendations. This ensures landlords get highly qualified leads while keeping the core tool free for those who need it most."

## Slide 7: Future Upgrades
**Speaker:** 
"Looking ahead, our backend is structured to seamlessly integrate with external APIs. We plan to add Google Maps for commute overlays, Plaid for verified cashflow analysis, and live listing APIs from Zillow. We also plan to integrate Vertex AI or Gemini for even richer, natural language underwriting and recommendation logic."

---

## 💻 Live Demo Script

**1. Login / Onboarding:**
*Action: Open the app and navigate to the login screen.*
**Speaker:** "Let's jump into the demo. I'm going to log in using our test account, demo@homepilot.ai. When a user first signs up, they go through a quick profile setup to securely input their income, household size, and location preferences."

**2. Dashboard & Affordability Agent:**
*Action: Show the Dashboard, then click on the Affordability tool.*
**Speaker:** "Here on the dashboard, the user gets an immediate overview of their financial health. Let's ask the AI Affordability agent for an estimate. Behind the scenes, the agent analyzes the user's income and uses a conservative housing budget ratio to instantly recommend a safe monthly rent range—in this case, around $1,160 to $1,500—and an estimated purchase budget."

**3. Grant Matching:**
*Action: Navigate to the Grants/Assistance screen.*
**Speaker:** "Next is my favorite feature: Grant Matching. The AI scans available housing programs against the user's profile. Here, we see an 89% match for the 'First Step Homebuyer Grant', which could provide up to $12,000 in coverage. The AI even explains *why* the user is a good fit."

**4. Exploring Listings (Recommendations):**
*Action: Open the Listings/Recommendations screen.*
**Speaker:** "Now, let's look at homes. Instead of endless scrolling, our Recommendation Agent ranks listings. For example, this Columbus Affordable Cottage scores an 86.8. The AI provides a summary explaining that it fits the working budget and that the grant we just saw could make it even more affordable."

**5. Landlord Portal (If time permits):**
*Action: Briefly mention or show the Landlord login.*
**Speaker:** "And remember our revenue model? Landlords can log in—like our demo account 'Peach State Properties'—and manage their inventory directly through our Landlord API, getting their properties in front of these qualified buyers."

**6. Conclusion:**
*Action: Return to the HomePilot AI dashboard.*
**Speaker:** "By giving users a clearer path toward stable housing decisions, HomePilot AI uses technology to empower people and level the playing field. Thank you, and we'd love to take your questions!"