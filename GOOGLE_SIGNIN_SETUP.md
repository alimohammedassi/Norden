# Google Sign-In Setup Guide

## Problem
Google Sign-In is failing with error: `Unknown calling package name 'com.google.android.gms'`

This happens because:
1. SHA-1 fingerprint is not registered in Firebase Console
2. Google Sign-In OAuth is not properly configured

## Your SHA-1 Fingerprint
```
SHA1: CA:D5:E6:02:90:47:FF:6D:9C:6F:AA:3D:7D:CB:73:3D:7B:04:33:B8
```

---

## Step 1: Add SHA-1 to Firebase Console

1. **Go to Firebase Console**: https://console.firebase.google.com

2. **Select your project**: "norden-e6024"

3. **Click the gear icon** (⚙️) next to "Project Overview" → **Project settings**

4. **Scroll down** to "Your apps" section

5. **Find your Android app**: `com.example.norden1`

6. **Click "Add fingerprint"**

7. **Paste this SHA-1**:
   ```
   CA:D5:E6:02:90:47:FF:6D:9C:6F:AA:3D:7D:CB:73:3D:7B:04:33:B8
   ```

8. **Click "Save"**

---

## Step 2: Enable Google Sign-In

1. **In Firebase Console**, go to **Authentication** (left sidebar)

2. **Click "Sign-in method" tab**

3. **Find "Google"** in the providers list

4. **Click on "Google"**

5. **Toggle "Enable"** to ON

6. **Enter a support email** (your email)

7. **Click "Save"**

---

## Step 3: Download New google-services.json

1. **Go back to Project Settings** (gear icon ⚙️)

2. **Scroll to "Your apps"**

3. **Click on your Android app**: `com.example.norden1`

4. **Click "google-services.json"** to download the updated file

5. **Replace the file** at: `android/app/google-services.json`

---

## Step 4: Rebuild the App

After completing all steps above, run:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Testing Google Sign-In

1. Open the app
2. Click "ENTER NORDEN" or "Sign In"
3. Click "Continue with Google"
4. Select your Google account
5. It should work! ✅

---

## Troubleshooting

### Still not working?
1. **Wait 5 minutes** after adding SHA-1 (Firebase needs time to propagate)
2. **Make sure you're using a real device or emulator with Google Play Services**
3. **Check that Google Sign-In is enabled** in Firebase Console
4. **Verify the package name** matches: `com.example.norden1`

### Error: "Developer error" or "10:"
- Your SHA-1 is not registered correctly
- Wait a few minutes and try again
- Make sure you downloaded the NEW google-services.json after adding SHA-1

### Using a physical device?
- You'll need to add the RELEASE SHA-1 too
- Get it from: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey`
- Password: `android`

---

## Quick Summary

✅ **SHA-1**: `CA:D5:E6:02:90:47:FF:6D:9C:6F:AA:3D:7D:CB:73:3D:7B:04:33:B8`  
✅ **Package**: `com.example.norden1`  
✅ **Project**: `norden-e6024`

**What you need to do:**
1. Add SHA-1 to Firebase (Step 1)
2. Enable Google Sign-In (Step 2)
3. Download new google-services.json (Step 3)
4. Rebuild app (Step 4)

---

## Alternative: Disable Google Sign-In (Quick Fix)

If you want to test the app without Google Sign-In:
- Use Email/Password login
- Use "Continue as Guest"
- Google Sign-In can be fixed later

The app will work fine without Google Sign-In for now!

