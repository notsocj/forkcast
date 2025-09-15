# Copilot Instructions for ForkCast (Android)

## Project Overview
ForkCast is an Android mobile application built with Flutter.  
It provides **personalized meal planning**, **localized Filipino recipes**, **market price monitoring**, and **nutritionist Q&A features**, tailored for users with or without common non-communicable diseases (NCDs).  

The app leverages **FNRI/PDRI nutrition rules** and integrates real-time market price data to deliver **budget-aware, health-conscious meal planning**.

---

## Folder Structure (Android App - Flutter)
Follow this structure to ensure modular, maintainable code:

lib/
│
├── main.dart # App entry point
├── core/ # Global config & utilities
│ ├── theme/ # App colors, text styles
│ ├── config/ # Firebase & API configs
│ ├── utils/ # Helper functions
│ └── constants.dart # Global constants
│
├── models/ # Data models (User, Recipe, Ingredient, etc.)
├── services/ # Firebase, APIs, ML/AI services
│ ├── auth_service.dart
│ ├── meal_plan_service.dart
│ ├── recipe_service.dart
│ ├── market_price_service.dart
│ └── nutritionist_service.dart
│
├── features/ # Main feature modules
│ ├── auth/ # Create & log in account
│ ├── profile/ # Profile setup & management
│ ├── meal_planner/ # Daily meal plan generator
│ ├── recipes/ # Recipe DB + search + scoring
│ ├── market_prices/ # Dashboard, alerts, forecasts
│ ├── qna_forum/ # Ask questions, answers, teleconsult
│ └── notifications/ # Push tips, reminders, alerts
│
├── screens/ # UI pages (organized per feature)
├── widgets/ # Reusable UI components
└── providers/ # State management (e.g., Riverpod/Provider/Bloc)

---

## User Requirements
The application must allow users to:

- Create & log into account  
- Set up personal profile (age, weight, health, household size/PAX, budget, etc.)  
- Generate daily personalized meal plans  
- Filter meals by ingredients, health conditions, and budget  
- Access curated Filipino recipes with **FNRI-based nutrition values**  
- Get meal suggestions based on cooking method  
- Receive AI-driven meal recommendations based on profile match  
- Search meals by ingredients  
- View current market prices  
- Detect & receive alerts on price instability  
- View price trends & forecasts  
- Ask nutritionists questions via Q&A and teleconsultation  

---

## System Requirements
The system must provide:

- **Profile-Based Meal Planning**  
- **Daily Meal Plan Generator**  
- **Filter Search** (ingredients, budget, health conditions)  
- **Localized Recipe Database**  
- **Recipe Scoring & Suitability Matching**  
- **Ingredient-Based Search**  
- **Market Price Dashboard**  
- **Price Alerts & Notifications**  
- **Price Trend & Prediction** (short-term forecasts)  
- **Q&A Forum with Nutritionists**  
- **System Status & Health Monitoring**  

---

## Concept Summary
ForkCast is a **Personalized Meal Planner** app that:  
- Generates daily meal plans using a **rule-based engine** informed by user profile (age, sex, weight, height, NCDs, budget, PAX, time-to-cook).  
- Applies **FNRI/PDRI nutrition standards** and recipe tags (e.g., “low sodium”, “budget-friendly”).  
- Suggests recipes suited to the following conditions:  
  - Diabetes  
  - Hypertension  
  - Obesity / Overweight  
  - Underweight / Malnutrition  
  - Heart Disease / High Cholesterol  
  - Anemia (Iron-deficiency)  
  - Osteoporosis (Calcium deficiency)  
  - None (healthy profile)  

**Exclusions:**  
- Pregnant women (no specialized planning)  
- Severe/complex medical conditions (e.g., cancer, kidney disease)  

**Dynamic Recipes:**  
- Ingredient amounts auto-scale based on PAX (e.g., family of 4).  

**Daily Nutrition Facts & Reminders:**  
- Push notifications with nutrition tips (e.g., “Malunggay contains 7× Vitamin C of oranges”).  

**Ingredient-Driven Search:**  
- Users can search recipes by ingredients on hand.  
- Offers suggested substitutions (e.g., tofu → egg).  

**Meal Refreshing:**  
- Users can refresh specific meals (e.g., breakfast) or the entire plan.  
- Suggestions adapt to NCD profile.  

**Localized Recipe DB:**  
- Filipino recipes with verified nutrition values (FNRI/PDRI-based).  

**Market Price Monitoring & Forecasts:**  
- Live market prices (Quezon City public markets).  
- Short-term forecasts (7-day/weekly) using regression.  
- Price alerts for instability (increase/decrease or stagnation).  

**Q&A Forum + Teleconsultation:**  
- Free Q&A board for nutritionist advice.  
- Paid teleconsult bookings with scheduling/calendar.  

**Offline-first Support:**  
- Local storage of recipes & meal plans for low-connectivity usage.  

---

## Development Workflow (Android-Only)

### Build & Run Commands

# Debug mode (hot reload enabled)
flutter run

# Run on specific device (e.g., Android emulator)
flutter run -d emulator-5554

# Release build for Android
flutter build apk --release
flutter build appbundle --release   # for Play Store upload

# Clean & rebuild project
flutter clean
flutter pub get

# Testing & Analysis
flutter test               # Run widget/unit tests
flutter analyze            # Static code analysis
flutter doctor             # Check Flutter/Android SDK setup

# Emulator & Device Setup
-- Test on multiple screen sizes (small, medium, large).
-- Test on at least Android 10+ (API 29+) for compatibility.

# Debugging
-- Use flutter logs for device logs.
-- Use Flutter DevTools for widget tree, performance, and network inspection.

---

# Pages & Folder Structure (Flutter)

## User Role – Pages

### Auth Flow
- `lib/features/auth/login_page.dart`
- `lib/features/auth/signup_page.dart`
- `lib/features/auth/signin_page.dart`
- `lib/features/auth/forgot_password/forgot_password_page.dart`
- `lib/features/auth/forgot_password/otp_code_page.dart`
- `lib/features/auth/forgot_password/create_new_password_page.dart`
- `lib/features/auth/forgot_password/all_set_page.dart`

### Profile Setup Flow
- `lib/features/profile_setup/name_entry_page.dart`
- `lib/features/profile_setup/gender_selection_page.dart`
- `lib/features/profile_setup/birthday_entry_page.dart`
- `lib/features/profile_setup/height_input_page.dart`
- `lib/features/profile_setup/weight_input_page.dart`
- `lib/features/profile_setup/weekly_budget_page.dart`
- `lib/features/profile_setup/household_size_page.dart`
- `lib/features/profile_setup/medical_conditions_page.dart`

### Core Features
- `lib/features/bmi/bmi_calculator_page.dart`
- `lib/features/home/user_dashboard_page.dart`
- `lib/features/profile/user_profile_page.dart`
- `lib/features/settings/account_settings_page.dart`

### Meal Planning
- `lib/features/meal_planner/meal_plan_page.dart`
- `lib/features/meal_planner/meal_page.dart`  
  (includes “Log It” → set amount & measurement, view nutrition facts)

### Market Prices
- `lib/features/market/market_price_dashboard_page.dart`

### Q&A Forum
- `lib/features/forum/forum_page.dart`  
  (post text, comment, save posts)

### Teleconsultation
- `lib/features/teleconsult/teleconsultation_page.dart` (list of professionals, booked appointments)
- `lib/features/teleconsult/book_consultation_page.dart`
- `lib/features/teleconsult/book_confirmation_page.dart`

---

## Admin Role – Pages

### User Management
- `lib/features/admin/user_management/manage_users_page.dart`
- `lib/features/admin/user_management/user_profiles_page.dart`

### Recipe & Content Management
- `lib/features/admin/content_management/manage_recipes_page.dart`
- `lib/features/admin/content_management/manage_ingredients_page.dart`
- `lib/features/admin/content_management/approve_recipes_page.dart`

### Market Data Management
- `lib/features/admin/market_data/manage_market_data_page.dart`
- `lib/features/admin/market_data/approve_price_forecasts_page.dart`

### Forum Management
- `lib/features/admin/forum_management/moderate_posts_page.dart`
- `lib/features/admin/forum_management/manage_reported_content_page.dart`

### Consultation Management
- `lib/features/admin/consultation_management/manage_professionals_page.dart`
- `lib/features/admin/consultation_management/approve_bookings_page.dart`

### System Dashboard
- `lib/features/admin/system_dashboard/app_analytics_page.dart`
- `lib/features/admin/system_dashboard/status_logs_page.dart`

---

## Professional Role – Pages

### Consultation Dashboard
- `lib/features/professional/consultations/consultation_dashboard_page.dart`
- `lib/features/professional/consultations/upcoming_schedules_page.dart`
- `lib/features/professional/consultations/patient_notes_page.dart`

### Profile Management
- `lib/features/professional/profile/update_profile_page.dart`
- `lib/features/professional/profile/manage_availability_page.dart`

---
