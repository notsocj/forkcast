# Google Sign-In Quick Reference Card

## 🚀 Quick Start

### **For Users Testing Google Sign-In:**

1. **Sign Up with Google:**
   - Open app → Get Started → Sign Up
   - Select User/Professional tab
   - Click Google icon (G)
   - Select Google account
   - Complete profile setup

2. **Sign In with Google:**
   - Open app → Get Started → Sign In
   - Select User/Professional tab
   - Click Google icon (G)
   - Select Google account
   - Auto-navigate to dashboard

---

## 🔧 Developer Setup (REQUIRED BEFORE TESTING)

### **Step 1: Enable Google Sign-In in Firebase**
```
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable "Google" provider
3. Add support email
4. Save
```

### **Step 2: Add SHA-1 Fingerprint**
```bash
# Get SHA-1 (run in project root)
cd android
./gradlew signingReport

# Copy SHA-1 from output
# Add to Firebase Console → Project Settings → Your apps → Add fingerprint
```

### **Step 3: Download Updated google-services.json**
```
1. Firebase Console → Project Settings → Your apps
2. Download google-services.json
3. Replace android/app/google-services.json
```

### **Step 4: Run Flutter App**
```bash
flutter pub get
flutter run
```

---

## 📋 Implementation Checklist

✅ **Code Changes:**
- [x] `pubspec.yaml` - Added `google_sign_in: ^6.2.1`
- [x] `auth_service.dart` - Google Sign-In methods
- [x] `sign_in_page.dart` - Google Sign-In handler
- [x] `sign_up_page.dart` - Google Sign-Up handler

✅ **Firebase Setup:**
- [ ] Google provider enabled in Firebase Console
- [ ] SHA-1 fingerprint added (Debug build)
- [ ] SHA-1 fingerprint added (Release build - for production)
- [ ] Support email configured
- [ ] `google-services.json` updated

✅ **Testing:**
- [ ] New user sign-up with Google (User role)
- [ ] New user sign-up with Google (Professional role)
- [ ] Existing user sign-in with Google
- [ ] Role mismatch detection
- [ ] Profile setup flow completion
- [ ] Dashboard navigation

---

## 🔄 User Flow Summary

### **Sign-In Flow:**
```
Google Icon Click
  ↓
Google Account Selection
  ↓
Profile Check
  ├── New User → Profile Setup
  └── Existing User → Dashboard
```

### **Sign-Up Flow:**
```
Google Icon Click
  ↓
Google Account Selection
  ↓
Account Check
  ├── Already Registered → Sign-In Page
  └── New → Create Account → Profile Setup
```

---

## 🐛 Troubleshooting

### **"sign_in_failed" Error**
```
Problem: SHA-1 not configured
Solution: Run gradlew signingReport and add SHA-1 to Firebase
```

### **"No GoogleSignIn configured"**
```
Problem: google-services.json missing/outdated
Solution: Download fresh google-services.json from Firebase Console
```

### **User stuck in profile setup**
```
Problem: fullName not saved properly
Solution: Verify UserService.createUser() is called correctly
```

---

## 📊 Key Features

| Feature | Description |
|---------|-------------|
| **One-Tap Sign-In** | Google authentication with single tap |
| **Profile Setup** | Automatic redirect for new users |
| **Role Validation** | Prevents unauthorized access |
| **Analytics** | Tracks Google sign-in events |
| **Error Handling** | Clean error messages |

---

## 📞 Support

**Documentation:** `GOOGLE_SIGNIN_IMPLEMENTATION.md`  
**Firebase Console:** https://console.firebase.google.com  
**Google Sign-In Docs:** https://pub.dev/packages/google_sign_in  

---

## ⚡ Quick Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Get SHA-1 fingerprint
cd android && ./gradlew signingReport

# Clean build
flutter clean && flutter pub get

# Hot reload (if app is running)
Press 'r' in terminal
```

---

**Status:** ✅ READY FOR TESTING  
**Last Updated:** October 12, 2025  
**Version:** 1.0.0
