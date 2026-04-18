./mvnw spring-boot:run

---

# HomePilot AI — Backend

Spring Boot 3.4.1 REST API with JWT auth, PostgreSQL (Railway), and placeholder AI agent services.

## Quick Start

```bash
cd backend
./mvnw spring-boot:run
```

Runs on `http://localhost:8080`. Requires the Railway PostgreSQL connection configured in `application-secrets.yaml` (gitignored).

After startup, seed the database:

```bash
curl -X POST http://localhost:8080/admin/reset-and-seed
```

---

## Architecture

```
com.homepilot.app/
├── controllers/        # REST endpoints
│   ├── AuthController        POST /auth/*
│   ├── ListingController     GET/POST/DELETE /listings/*
│   ├── AiController          POST /ai/*
│   ├── AdminController       POST /admin/*
│   └── HealthController      GET /
├── services/           # Business logic
│   ├── AuthService                 signup, login, Google OAuth
│   ├── AffordabilityAgentService   rent/buy budget estimation
│   ├── GrantMatchingAgentService   housing grant eligibility
│   ├── RecommendationAgentService  listing ranking
│   ├── MortgageAgentService        monthly payment calculator
│   └── DatabaseAdminService        reset/seed operations
├── models/             # JPA entities → PostgreSQL tables
│   ├── User, Listing, GrantProgram,
│   ├── Recommendation, SavedProperty, MortgageEstimate
├── repositories/       # Spring Data JPA interfaces
├── dto/                # Request/response objects
│   ├── AuthRequest, AuthResponse, ProfileRequest
└── security/
    └── JwtUtil          JWT token generation & parsing
```

---

## API Routes

### Health

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/` | Health check |

```
GET http://localhost:8080/
→ {"status":"running","app":"HomePilot AI Backend"}
```

---

### Auth

| Method | URL | Body | Description |
|--------|-----|------|-------------|
| POST | `/auth/signup` | `{email, password}` | Create account, returns JWT |
| POST | `/auth/login` | `{email, password}` | Login, returns JWT |
| POST | `/auth/google` | `{googleIdToken}` | Google OAuth login/signup |
| GET | `/auth/profile/{userId}` | — | Get user profile |
| PUT | `/auth/profile/{userId}` | ProfileRequest JSON | Update profile |

**Examples:**

```bash
# Signup
curl -X POST http://localhost:8080/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'

# → {"token":"eyJhbG...","message":"Signup successful","userId":1}

# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'

# Get profile
curl http://localhost:8080/auth/profile/1

# Update profile
curl -X PUT http://localhost:8080/auth/profile/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Pablo",
    "incomeRange":"50k-75k",
    "employmentStatus":"student",
    "householdSize":2,
    "creditEstimate":700,
    "preferredLocation":"Miami, FL",
    "rentOrBuy":"rent"
  }'
```

---

### Listings

| Method | URL | Params | Description |
|--------|-----|--------|-------------|
| GET | `/listings` | `?type=rent&maxPrice=1500&location=Miami` | Get all listings (filterable) |
| GET | `/listings/{id}` | — | Get single listing |
| POST | `/listings/favorites` | `?userId=1&listingId=3` | Save a favorite |
| GET | `/listings/favorites/{userId}` | — | Get user's saved listings |
| DELETE | `/listings/favorites` | `?userId=1&listingId=3` | Remove a favorite |

**Examples:**

```bash
# All listings
curl http://localhost:8080/listings

# Only rentals
curl "http://localhost:8080/listings?type=rent"

# Buy under $300k
curl "http://localhost:8080/listings?type=buy&maxPrice=300000"

# Search by location
curl "http://localhost:8080/listings?location=Miami"

# Single listing
curl http://localhost:8080/listings/1

# Save favorite
curl -X POST "http://localhost:8080/listings/favorites?userId=1&listingId=3"

# Get favorites
curl http://localhost:8080/listings/favorites/1

# Remove favorite
curl -X DELETE "http://localhost:8080/listings/favorites?userId=1&listingId=3"
```

---

### AI Agents

All agent endpoints take `userId` as a query param. Each reads the user's profile from the DB and returns a structured JSON response. **All are currently placeholders** returning mock calculations — they will be replaced with Google ADK/Gemini calls.

| Method | URL | Params | Description |
|--------|-----|--------|-------------|
| POST | `/ai/affordability` | `?userId=1` | Rent/buy budget based on income |
| POST | `/ai/grants` | `?userId=1` | Matched grant programs |
| POST | `/ai/recommendations` | `?userId=1` | Ranked listing picks |
| POST | `/ai/mortgage-estimate` | `?userId=1` | Monthly payment estimate |

**Examples:**

```bash
# Affordability
curl -X POST "http://localhost:8080/ai/affordability?userId=1"
# → {
#   "userId": 1,
#   "estimatedAnnualIncome": 62500,
#   "recommendedRentMin": 1042,
#   "recommendedRentMax": 1563,
#   "recommendedPurchaseMax": 250000,
#   "estimatedDTI": "30%",
#   "summary": "Based on your income and household size, your recommended monthly rent range is $1,042–$1,563. Max home purchase: ~$250k.",
#   "source": "placeholder — awaiting Google ADK agent integration"
# }

# Grants
curl -X POST "http://localhost:8080/ai/grants?userId=1"
# → {
#   "userId": 1,
#   "matchedGrants": [
#     {"programName":"First-Time Home Buyer Assistance","coverageAmount":15000,"matchScore":0.92},
#     ...
#   ],
#   "totalPotentialAid": 30000
# }

# Recommendations
curl -X POST "http://localhost:8080/ai/recommendations?userId=1"
# → {
#   "userId": 1,
#   "preference": "rent",
#   "recommendations": [
#     {"listingId":1,"title":"Sunny 2BR in Miami","price":1450.00,"score":0.95},
#     ...
#   ]
# }

# Mortgage estimate
curl -X POST "http://localhost:8080/ai/mortgage-estimate?userId=1"
# → {
#   "userId": 1,
#   "recommendedPurchasePrice": 250000,
#   "estimatedMonthlyPayment": 1423,
#   "readinessScore": 0.65,
#   ...
# }
```

---

### Admin (Database Management)

| Method | URL | Description |
|--------|-----|-------------|
| POST | `/admin/reset` | Drop all rows from every table |
| POST | `/admin/seed` | Insert 10 mock listings + 4 grant programs |
| POST | `/admin/reset-and-seed` | Both in one call |

```bash
# Full reset + seed
curl -X POST http://localhost:8080/admin/reset-and-seed
# → {"reset":"All tables cleared successfully.","seed":"Database seeded with 10 listings and 4 grant programs."}
```

---

## Database (PostgreSQL on Railway)

Six tables managed by Hibernate `ddl-auto: update` (auto-creates/migrates on startup):

| Table | Key Fields |
|-------|------------|
| `users` | email, password, income_range, employment_status, household_size, credit_estimate, preferred_location, rent_or_buy |
| `listings` | title, price, location, bedrooms, bathrooms, rent_or_buy |
| `grant_programs` | program_name, eligibility_rules, coverage_amount |
| `recommendations` | user_id → users, listing_id → listings, score |
| `saved_properties` | user_id → users, listing_id → listings |
| `mortgage_estimates` | user_id → users, estimated_budget, monthly_payment |

---

## AI Agent Integration (TODO)

Each agent service is a standalone Spring `@Service` class. To connect Google ADK:

1. Add Google ADK / Vertex AI dependency to `pom.xml`
2. Replace the placeholder logic inside each service method
3. The controller endpoints and JSON response shapes stay the same

Services to update:
- `AffordabilityAgentService.calculateAffordability()`
- `GrantMatchingAgentService.matchGrants()`
- `RecommendationAgentService.recommend()`
- `MortgageAgentService.estimate()`

---

## Key Config Files

| File | Purpose | Gitignored? |
|------|---------|-------------|
| `application.yaml` | App name, JPA config, server port | No |
| `application-secrets.yaml` | DB url/password, Google client ID, JWT secret | **Yes** |
| `pom.xml` | Dependencies (Spring Boot 3.4.1, JWT, Google API Client) | No |