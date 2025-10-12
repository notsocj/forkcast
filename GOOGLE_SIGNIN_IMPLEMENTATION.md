# Google Sign-In Implementation Guide for ForkCast

## ✅ Implementation Status: COMPLETE

Google Sign-In has been successfully integrated into both Sign-In and Sign-Up pages with full profile setup flow support.

---

## 📋 Overview

Users can now sign in/up with their Google account. The flow automatically:
- Creates a Firestore user document for new users
- Redirects to profile setup for incomplete profiles
- Navigates to appropriate dashboard for existing users
- Supports both **User** and **Professional** account types

---

## 🔧 Technical Implementation

### **1. Package Installation**

**Added to `pubspec.yaml`:**
```yaml
dependencies:
  google_sign_in: ^6.2.1
```

**Installation:**
```bash
flutter pub get
```

---

### **2. AuthService Enhancement**

**File:** `lib/services/auth_service.dart`

#### **New Methods Added:**

```dart
// Google Sign-In method
Future<UserCredential?> signInWithGoogle() async {
  // Triggers Google authentication flow
  // Returns UserCredential or null if cancelled
}

// Check if user has completed profile setup
Future<bool> hasCompletedProfile(String userId) async {
  // Checks if essential fields are filled in Firestore
}

// Get user role from Firestore
Future<String> getUserRole(String userId) async {
  // Returns 'user', 'professional', or 'admin'
}
```

#### **Updated Sign Out:**
```dart
Future<void> signOut() async {
  await _auth.signOut();
  await _googleSignIn.signOut(); // Now signs out from Google too
}
```

---

### **3. Sign-In Page Updates**

**File:** `lib/features/auth/sign_in_page.dart`

#### **Google Sign-In Button:**
```dart
_buildSocialIcon(Icons.g_mobiledata, _handleGoogleSignIn)
```

#### **Google Sign-In Handler:**
```dart
void _handleGoogleSignIn() async {
  setState(() => _isLoading = true);
  
  final userCredential = await authService.signInWithGoogle();
  
  if (userCredential == null) {
    // User cancelled
    return;
  }
  
  // Check if profile is complete
  final hasProfile = await authService.hasCompletedProfile(userId);
  
  if (!hasProfile) {
    // New user → Profile setup
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => _isProfessionalLogin 
            ? const ProfessionalNameEntryPage()
            : const NameEntryPage(),
      ),
      (route) => false,
    );
    return;
  }
  
  // Existing user → Dashboard
  // Validates role matches login type
  // Navigates to appropriate dashboard
}
```

---

### **4. Sign-Up Page Updates**

**File:** `lib/features/auth/sign_up_page.dart`

#### **Google Sign-Up Button:**
```dart
_buildSocialIcon(Icons.g_mobiledata, _handleGoogleSignUp)
```

#### **Google Sign-Up Handler:**
```dart
void _handleGoogleSignUp() async {
  final userCredential = await authService.signInWithGoogle();
  
  if (userCredential == null) {
    // User cancelled
    return;
  }
  
  // Check if user already exists
  final hasProfile = await authService.hasCompletedProfile(userId);
  
  if (hasProfile) {
    // Existing user → Sign in instead
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
    return;
  }
  
  // New user → Create Firestore document
  await userService.createUser(
    userId: userId,
    fullName: userCredential.user!.displayName ?? '',
    email: email,
    role: _isProfessionalSignup ? 'professional' : 'user',
    // ... other fields
  );
  
  // Navigate to profile setup
  if (_isProfessionalSignup) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfessionalNameEntryPage()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NameEntryPage()),
    );
  }
}
```

---

## 🔄 User Flow Diagrams

### **Sign-In with Google Flow:**

```
User clicks Google icon
     ↓
Google Sign-In popup
     ↓
User selects Google account
     ↓
Check if profile exists
     ├── NO → Navigate to Profile Setup (User/Professional)
     └── YES → Check role validity
              ├── Role mismatch → Show error, sign out
              └── Role valid → Navigate to Dashboard
```

### **Sign-Up with Google Flow:**

```
User clicks Google icon
     ↓
Google Sign-In popup
     ↓
User selects Google account
     ↓
Check if account exists
     ├── YES → Navigate to Sign-In page
     └── NO → Create Firestore user document
              ↓
              Set role (user/professional)
              ↓
              Navigate to Profile Setup (User/Professional)
```

---

## 🎯 Key Features

### **1. Profile Completion Check**
```dart
Future<bool> hasCompletedProfile(String userId) async {
  final userData = await userService.getUser(userId);
  
  if (userData == null || userData.fullName.isEmpty) {
    return false;
  }
  
  return userData.fullName.isNotEmpty && 
         userData.email.isNotEmpty;
}
```

### **2. Role Validation**
- Checks if user's Firestore role matches the selected login type (User/Professional)
- Signs out automatically if mismatch detected
- Shows appropriate error message

### **3. Automatic Firestore Document Creation**
```dart
await userService.createUser(
  userId: userId,
  fullName: userCredential.user!.displayName ?? '', // Uses Google display name
  email: email,
  passwordHash: '', // Google auth doesn't need password hash
  role: _isProfessionalSignup ? 'professional' : 'user',
  // ... other fields with default values
);
```

### **4. Firebase Analytics Integration**
```dart
// Records Google login activity
await AnalyticsService.recordUserActivity(
  userId: userCredential.user!.uid,
  userName: userData.fullName,
  action: 'User login via Google',
);
```

---

## 🔒 Security Considerations

### **1. Role-Based Access Control**
- Users must select correct login type (User/Professional)
- System validates Firestore role matches login selection
- Automatic sign-out if mismatch detected

### **2. Profile Completion Enforcement**
- New Google users must complete profile setup
- No access to dashboard until profile is complete
- Essential fields validated before proceeding

### **3. Google OAuth 2.0**
- Secure authentication flow managed by Google
- No password storage needed for Google accounts
- Token-based authentication with automatic refresh

---

## 🚀 Firebase Console Setup (Required)

### **Step 1: Enable Google Sign-In in Firebase Console**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **forkcast**
3. Navigate to **Authentication** → **Sign-in method**
4. Click **Google** → **Enable**
5. Add support email: `your-email@example.com`
6. Click **Save**

### **Step 2: Configure Android App**

**File:** `android/app/google-services.json`

Already configured with your Firebase project settings.

### **Step 3: Add SHA-1 Certificate Fingerprint**

#### **For Debug Build:**
```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 from `debug` variant and add it to Firebase Console:
- **Firebase Console** → **Project Settings** → **Your apps** → **Android app**
- Click **Add fingerprint**
- Paste SHA-1

#### **For Release Build:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### **Step 4: Update `build.gradle` (Already Done)**

**File:** `android/build.gradle.kts`
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.3.15")
}
```

**File:** `android/app/build.gradle.kts`
```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
}
```

---

## 📱 Testing Guide

### **Test Scenario 1: New User Sign-Up with Google**

1. Open app → **Get Started** → **Sign Up**
2. Select **User** tab
3. Click Google icon (G icon)
4. Select Google account
5. **Expected:** Navigate to `NameEntryPage` for profile setup

### **Test Scenario 2: New Professional Sign-Up with Google**

1. Open app → **Get Started** → **Sign Up**
2. Select **Professional** tab
3. Click Google icon
4. Select Google account
5. **Expected:** Navigate to `ProfessionalNameEntryPage` for professional setup

### **Test Scenario 3: Existing User Sign-In with Google**

1. Open app → **Get Started** → **Sign In**
2. Select **User** tab
3. Click Google icon
4. Select Google account (already registered)
5. **Expected:** Navigate to `MainNavigationWrapper` (User Dashboard)

### **Test Scenario 4: Role Mismatch Detection**

1. Create account as **User** with Google
2. Complete profile setup
3. Sign out
4. Try signing in with **Professional** login
5. **Expected:** Error message + automatic sign out

### **Test Scenario 5: Cancelled Sign-In**

1. Click Google icon
2. Close Google sign-in popup without selecting account
3. **Expected:** Return to sign-in page, no error shown

---

## 🐛 Common Issues & Solutions

### **Issue 1: "PlatformException: sign_in_failed"**

**Cause:** SHA-1 fingerprint not added to Firebase Console

**Solution:**
```bash
cd android
./gradlew signingReport
```
Add SHA-1 to Firebase Console → Download new `google-services.json`

---

### **Issue 2: "GoogleSignIn not configured"**

**Cause:** Missing `google-services.json` or incorrect package name

**Solution:**
- Verify `google-services.json` is in `android/app/`
- Check package name matches Firebase Console:
  ```
  com.example.forkcast
  ```

---

### **Issue 3: User stuck in profile setup loop**

**Cause:** `fullName` field not properly saved

**Solution:**
Check `hasCompletedProfile()` logic:
```dart
return userData.fullName.isNotEmpty && 
       userData.email.isNotEmpty;
```

---

### **Issue 4: "FirebaseAuthException: account-exists-with-different-credential"**

**Cause:** Email already used with different provider (e.g., email/password)

**Solution:**
- Link accounts using `linkWithCredential()`
- Or use different email for Google sign-in

---

## 📊 Analytics Tracking

Google Sign-In events are automatically logged:

```dart
// New user registration via Google
await AnalyticsService.recordUserActivity(
  userId: userId,
  userName: displayName,
  action: 'New user registration',
);

// Existing user login via Google
await AnalyticsService.recordUserActivity(
  userId: userId,
  userName: userData.fullName,
  action: 'User login via Google',
);
```

**Tracked Metrics:**
- Total Google sign-ups
- Google sign-in success rate
- Profile completion rate for Google users
- Role type distribution (user vs professional)

---

## 🔄 Future Enhancements

### **1. Google One Tap Sign-In**
```dart
// Auto-prompt Google One Tap on app launch
await _googleSignIn.signInSilently();
```

### **2. Account Linking**
```dart
// Link Google account to existing email/password account
await user.linkWithCredential(googleCredential);
```

### **3. Profile Picture Sync**
```dart
// Sync Google profile picture to user profile
final photoUrl = userCredential.user?.photoURL;
await userService.updateProfilePicture(userId, photoUrl);
```

### **4. Email Verification Skip**
```dart
// Google accounts are pre-verified
if (user.providerData.any((p) => p.providerId == 'google.com')) {
  // Skip email verification
}
```

---

## ✅ Checklist for Production

- [ ] SHA-1 fingerprint added to Firebase Console (Debug & Release)
- [ ] Google Sign-In enabled in Firebase Authentication
- [ ] Support email configured in Firebase Console
- [ ] `google-services.json` updated with production credentials
- [ ] Tested on physical Android device
- [ ] Verified role-based navigation works correctly
- [ ] Tested profile setup flow for new Google users
- [ ] Analytics tracking validated
- [ ] Privacy policy updated to mention Google Sign-In
- [ ] Terms of service include Google OAuth consent

---

## 📝 Summary

**What was implemented:**
✅ Google Sign-In integration in `AuthService`  
✅ Google Sign-In handlers in Sign-In page  
✅ Google Sign-Up handlers in Sign-Up page  
✅ Profile completion checking  
✅ Role-based navigation  
✅ Automatic Firestore document creation  
✅ Analytics integration  
✅ Error handling and user feedback  

**User experience:**
- One-tap Google sign-in/up
- Seamless profile setup for new users
- Automatic dashboard navigation for existing users
- Role validation prevents unauthorized access
- Clean error messages with automatic recovery

**Next steps:**
1. Run `flutter pub get` (already done)
2. Test on Android emulator/device
3. Add SHA-1 to Firebase Console
4. Test all user flows end-to-end
5. Deploy to production 🚀
