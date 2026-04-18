# Create the new Flutter project called 'frontend'
flutter create frontend

# Navigate into the new folder
cd frontend

# Add the HTTP package for making API calls
flutter pub add http

flutter run -d macos

flutter run -d chrome

flutter run -d chrome --web-port 3000

---

# HomePilot AI — Flutter Frontend

Cross-platform Flutter app (web, iOS, Android, desktop) connected to the Spring Boot backend.

## Quick Start

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000
```

| Target | Command |
|--------|---------|
| Web (Chrome) | `flutter run -d chrome --web-port 3000` |
| macOS | `flutter run -d macos` |
| iOS Simulator | `flutter run -d ios` |
| Android Emulator | `flutter run -d android` |

The app auto-detects the platform and sets the backend URL:
- **Web / iOS Simulator / macOS**: `http://localhost:8080`
- **Android Emulator**: `http://10.0.2.2:8080` (maps to host localhost)

---

## Architecture

```
lib/
├── main.dart                 # App entry, theme, AuthGate (login check)
├── services/
│   └── api_service.dart      # All HTTP calls to backend
├── screens/
│   ├── login_screen.dart     # Email/password login
│   ├── signup_screen.dart    # Account creation → profile setup
│   ├── profile_setup_screen.dart  # Income, employment, credit, location, rent/buy
│   ├── dashboard_screen.dart # Home — affordability, grants, top picks
│   ├── listings_screen.dart  # Browse & filter listings, save favorites
│   ├── saved_screen.dart     # Saved/favorited properties
│   ├── grants_screen.dart    # Grant eligibility results
│   └── mortgage_screen.dart  # Mortgage payment estimate
├── models/                   # (expandable — currently inline)
└── widgets/                  # (expandable — reusable components)
```

---

## Screens

### Login
Email + password form. On success, stores JWT token and userId in `SharedPreferences` and navigates to Dashboard. Persists login across app restarts.

### Signup
Email + password + confirm password. On success, navigates directly to Profile Setup (not Dashboard) so the user fills out their financial info before using AI features.

### Profile Setup
Collects all profile fields the AI agents need:
- Full name, preferred location (text fields)
- Income range, employment status (dropdowns)
- Household size, credit estimate (sliders)
- Rent vs Buy preference (segmented button)

Calls `PUT /auth/profile/{userId}`. Accessible again later via the profile icon on the Dashboard.

### Dashboard
Loads three AI endpoints in parallel on mount:
- **Affordability card** — shows rent range and purchase max from `/ai/affordability`
- **Eligible Grants card** — top 2 grants from `/ai/grants` with "View all →" link
- **Top Picks card** — top 3 recommended listings from `/ai/recommendations` with match %

Quick-action buttons at the bottom navigate to Listings, Saved, and Mortgage screens. Pull-to-refresh reloads all data.

### Listings
Fetches from `GET /listings` with a segmented filter (All / Rent / Buy). Each listing card shows title, location, bed/bath count, price, and a heart icon to save as favorite. Tapping the heart calls `POST /listings/favorites?userId=X&listingId=Y`.

### Saved Properties
Fetches from `GET /listings/favorites/{userId}`. Each item has a delete button that calls `DELETE /listings/favorites?userId=X&listingId=Y` and refreshes the list.

### Grant Eligibility
Fetches from `POST /ai/grants?userId=X`. Shows total potential aid at the top, then a card for each matched grant with program name, coverage amount, eligibility criteria, and match score percentage.

### Mortgage Estimate
Fetches from `POST /ai/mortgage-estimate?userId=X`. Displays estimated monthly payment prominently, then a breakdown table: purchase price, down payment, interest rate, loan term, credit estimate, and readiness score.

---

## API Service (`api_service.dart`)

Single class that wraps every backend call. Key methods:

| Method | Backend Route | Used By |
|--------|---------------|---------|
| `signup(email, pass)` | `POST /auth/signup` | SignupScreen |
| `login(email, pass)` | `POST /auth/login` | LoginScreen |
| `googleAuth(idToken)` | `POST /auth/google` | (Google Sign-In) |
| `getProfile(userId)` | `GET /auth/profile/{id}` | ProfileSetupScreen |
| `updateProfile(userId, data)` | `PUT /auth/profile/{id}` | ProfileSetupScreen |
| `getListings(type?, location?, maxPrice?)` | `GET /listings?...` | ListingsScreen |
| `saveFavorite(userId, listingId)` | `POST /listings/favorites` | ListingsScreen |
| `getFavorites(userId)` | `GET /listings/favorites/{id}` | SavedScreen |
| `removeFavorite(userId, listingId)` | `DELETE /listings/favorites` | SavedScreen |
| `getAffordability(userId)` | `POST /ai/affordability` | DashboardScreen |
| `getGrants(userId)` | `POST /ai/grants` | DashboardScreen, GrantsScreen |
| `getRecommendations(userId)` | `POST /ai/recommendations` | DashboardScreen |
| `getMortgageEstimate(userId)` | `POST /ai/mortgage-estimate` | MortgageScreen |
| `resetAndSeed()` | `POST /admin/reset-and-seed` | (dev use) |

---

## Auth Flow

1. `AuthGate` widget checks `SharedPreferences` for stored token/userId on launch
2. If found → skip login, go to Dashboard
3. If not → show LoginScreen
4. On login/signup success → store token + userId in SharedPreferences
5. On logout → clear SharedPreferences, navigate to LoginScreen
6. Token is attached as `Authorization: Bearer <token>` header on all API calls

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `http` | REST API calls |
| `shared_preferences` | Persist JWT token + userId locally |
| `google_sign_in` | Google OAuth (for `/auth/google` flow) |
| `cupertino_icons` | iOS-style icons |

---

## Google OAuth Setup (Optional)

The Google Sign-In button is wired but not yet added to the login screen UI. To enable:

1. The backend already verifies Google ID tokens via `google-api-client`
2. Add a "Sign in with Google" button to `login_screen.dart`
3. Use the `google_sign_in` package to get the ID token client-side
4. Call `api.googleAuth(idToken)` with the result
5. Google Cloud Console already has `localhost:8080` and `localhost:3000` as authorized origins