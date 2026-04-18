# HomePilot AI

HomePilot AI is a full-stack housing affordability assistant built with Flutter and Spring Boot. It helps users estimate affordable rent and purchase ranges, match with housing assistance programs, explore listings, save favorites, and gauge mortgage readiness.

## Project Structure

```text
HomePilotAI/
├── backend_springboot/
│   ├── src/main/java/com/homepilotai/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── dto/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── security/
│   │   ├── services/
│   │   └── HomePilotApplication.java
│   └── src/main/resources/application.properties
├── frontend_flutter/
│   └── lib/
│       ├── models/
│       ├── screens/
│       ├── services/
│       ├── widgets/
│       └── main.dart
├── database_schema.sql
└── docker-compose.yml
```

## MVP Features

- JWT authentication with signup and login
- Post-login profile setup flow
- AI affordability estimator
- Grant eligibility matcher
- Property recommendation ranking
- Mortgage estimate and readiness scoring
- Mock rental and purchase listings
- Saved properties
- Flutter mobile screens wired to backend APIs

## Backend Endpoints

- `POST /auth/signup`
- `POST /auth/login`
- `GET /profile`
- `PUT /profile`
- `GET /dashboard`
- `GET /listings`
- `GET /listings/{id}`
- `GET /favorites`
- `POST /favorites`
- `POST /ai/affordability`
- `POST /ai/grants`
- `POST /ai/recommendations`
- `POST /ai/mortgage-estimate`

## Example API Responses

`POST /ai/affordability`

```json
{
  "message": "Based on your income and household size your recommended monthly rent range is $1160-$1502.",
  "recommendedRentMin": 1160,
  "recommendedRentMax": 1502,
  "recommendedPurchaseMin": 173917,
  "recommendedPurchaseMax": 207421,
  "estimatedDebtToIncomeRatio": 0.195,
  "recommendedHousingBudget": 1365
}
```

`POST /ai/grants`

```json
{
  "matches": [
    {
      "programId": 1,
      "programName": "First Step Homebuyer Grant",
      "rationale": "Matches your buy preference. Income appears within the target range. Location fit looks strong.",
      "coverageAmount": 12000,
      "eligibilityScore": 89
    }
  ]
}
```

`POST /ai/recommendations`

```json
{
  "recommendations": [
    {
      "listingId": 8,
      "title": "Columbus Affordable Cottage",
      "price": 156000,
      "location": "Columbus, OH",
      "bedrooms": 2,
      "bathrooms": 1,
      "rentOrBuy": "BUY",
      "score": 86.8,
      "fitSummary": "Fits your working budget. Grant eligibility may improve the overall fit."
    }
  ]
}
```

## Agent Logic Notes

Affordability agent:
- Converts the user income range into an estimated annual income midpoint
- Uses a conservative `28%` housing budget ratio
- Produces rent range, purchase range, and estimated DTI

Grant matching agent:
- Scores seeded grant programs against `type`, `maxIncome`, `minCredit`, `householdMin`, and `location`
- Returns ranked results with rationale text

Recommendation agent:
- Scores listings using budget compatibility, location fit, household sizing, and grant boost
- Saves generated recommendation scores into the `recommendations` table

Mortgage agent:
- Uses a conservative monthly housing ratio and credit-adjusted borrowing multiplier
- Stores mortgage estimates for the current user

## Run Locally

### 1. Start PostgreSQL

```bash
cd HomePilotAI
docker compose up -d
```

### 2. Run Spring Boot

```bash
cd HomePilotAI/backend_springboot
./mvnw spring-boot:run
```

Optional environment variables:

```bash
export DB_URL=jdbc:postgresql://localhost:5432/homepilotai
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export JWT_SECRET=homepilotai-super-secret-key-homepilotai-super-secret-key
```

### 3. Run Flutter

Android emulator:

```bash
cd HomePilotAI/frontend_flutter
flutter run
```

If you need a different backend host:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

## Verification

- Backend: `./mvnw test`
- Flutter: `flutter analyze`
- Flutter tests: `flutter test`

## Future Upgrade Paths

The backend service layer is separated so future integrations can slot in without major restructuring:

- Google Maps API for commute and neighborhood overlays
- Plaid API for verified cashflow analysis
- Zillow or Realtor APIs for live listings
- Vertex AI or Gemini for richer recommendation and underwriting logic
