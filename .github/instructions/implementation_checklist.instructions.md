---
applyTo: '**'
---
# ForkCast Android Development Phases & Copilot Checklists

## Development Phases

### Phase 1: Planning & Requirements Gathering ( Done )
- Define user requirements
- Define system requirements
- Finalize feature list and pages
- Design Firebase schema & data model
- Create UI/UX mockups

### Phase 2: Project Setup & Architecture
- Initialize Flutter project (Android only)
- Set up folder structure:
  - `lib/features/auth/`
  - `lib/features/profile/`
  - `lib/features/meal_planner/`
  - `lib/features/market_price/`
  - `lib/features/qna/`
  - `lib/features/teleconsultation/`
  - `lib/models/`
  - `lib/services/`
  - `lib/widgets/`
- Configure Firebase authentication, Firestore, and storage
- Add dependencies (`firebase_auth`, `cloud_firestore`, `flutter_local_notifications`, etc.)
- Configure linter and project rules (`analysis_options.yaml`)

### Phase 3: Authentication & Profile Management
- Implement login, sign up, forgot password flows
- Implement user profile setup flow
- Connect authentication to Firestore `users` collection
- Handle roles: `user`, `admin`, `professional`

### Phase 4: Core Features Implementation
- [x] BMI Calculator
- Meal Planner & Daily Meal Plan Generator
  - Meal plan CRUD
  - Recipe subcollections
- Meal Page Logging & Nutrition Facts
- Ingredient-based Meal Search & Filtering
- Market Price Dashboard & Forecasting
- Price Alerts & Trends
- Q&A Forum
- Teleconsultation booking & management

### Phase 5: UI/UX Refinement
- Apply Material Design & consistent theming
- Ensure responsive layouts for Android
- Test all pages and navigation flows
- Integrate push notifications & micro-tips

### Phase 6: Testing & Quality Assurance
- Unit tests for models and services
- Widget tests for UI pages
- Integration tests for Firebase interactions
- Bug fixes & performance optimization

### Phase 7: Deployment & Maintenance
- Prepare APK build
- Conduct internal testing
- Release to Google Play Store (optional beta)
- Maintain documentation
- Monitor Firebase analytics & logs

---

## Copilot Implementation Checklist

 - [x] **Auth Features**
   - [x] `splash_screen.dart` (simple splash screen)
   - [x] `get_started_page.dart` (social login options)
   - [x] `sign_in_page.dart` (Firebase Auth, navigation to profile setup)
   - [x] `sign_up_page.dart` (validated)
   - [x] `forgot_password_flow` (OTP → Reset → Confirmation)
     - [x] `forgot_password_page.dart`
     - [x] `otp_code_page.dart`
     - [x] `create_new_password_page.dart`
     - [x] `all_set_page.dart`
 - [x] **Profile Features**
   - [x] Profile setup pages started
     - [x] `name_entry_page.dart` (progress bar, centered input with shadow, navigation from sign in)
     - [x] `gender_selection_page.dart` (progress 2/8, Male/Female/Prefer not to say options with green selection)
     - [x] `birthday_entry_page.dart` (progress 3/8, scrollable date pickers for Month/Day/Year)
     - [x] `height_input_page.dart` (progress 4/8, scrollable ruler with cm/ft toggle and connected input field)
     - [x] `weight_input_page.dart` (progress 5/8, scrollable ruler with kg/lb toggle and connected input field)
  - [x] `weekly_budget_page.dart` (progress 6/8, modern numeric input, +/- controls, custom dialog)
    - [x] Navigate medical conditions → BMI (profile flow navigation wired)
   - [ ] Profile connected to Firestore `users` collection
- [ ] **Meal Planner Features**
  - [ ] Meal Plan Page (`meal_plan_page.dart`) implemented
  - [ ] Meal Page logging & nutrition facts implemented (`meal_page.dart`)
  - [ ] Filtering by health, budget, ingredients functional
- [ ] **Market Prices**
  - [ ] Dashboard implemented (`market_price_dashboard.dart`)
  - [ ] Price alerts & trends functional
- [ ] **Q&A Forum**
  - [ ] Forum page implemented (`qna_forum_page.dart`)
  - [ ] Posting, commenting, saving posts functional
- [ ] **Teleconsultation**
  - [ ] Consultation page implemented (`teleconsultation_page.dart`)
  - [ ] Booking page functional (`book_consultation_page.dart`)
  - [ ] Confirmation page implemented (`book_confirmation_page.dart`)
- [ ] **Admin Features**
  - [ ] User management pages (`manage_users_page.dart`)
  - [ ] Recipe management pages (`manage_recipes_page.dart`)
  - [ ] Price data validation pages
  - [ ] Forum moderation pages
  - [ ] Teleconsultation approval pages
- [ ] **Professional Features**
  - [ ] Consultation dashboard (`professional_consultation_page.dart`)
  - [ ] Profile management & availability
- [ ] **Core Integrations**
  - [ ] Firebase Firestore read/write verified
  - [ ] Authentication & role management working
  - [ ] Push notifications implemented
  - [ ] Offline support tested
- [ ] **UI/UX**
  - [ ] All pages responsive
  - [ ] Material Design applied consistently
  - [ ] Colors, fonts, buttons, and inputs standardized
- [ ] **Testing**
  - [ ] Unit tests completed for models/services
  - [ ] Widget tests completed for all pages
  - [ ] Integration tests completed for Firebase interactions

---

### Notes for Copilot
- Update `implementation_checklist.instructions.md` automatically after adding a new feature or page.
- Each new page or service added should include checklist items under the relevant section.
- Use consistent naming: `snake_case` for files, `PascalCase` for classes, `camelCase` for variables.
- Validate Firebase fields against the defined schema when creating/updating documents.
