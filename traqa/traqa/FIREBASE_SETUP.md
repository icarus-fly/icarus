# Firebase Setup Instructions for Traqa

## Prerequisites

1. Create a Firebase project at [https://console.firebase.google.com](https://console.firebase.google.com)
2. Enable the following services:
   - Authentication (with Google sign-in)
   - Firestore Database
   - Cloud Storage
   - Cloud Functions
   - Cloud Messaging (FCM)

## Android Setup

1. **Add Android app to Firebase:**
   - Package name: `com.traqa.health`
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

2. **Update Android build files:**
   - `android/build.gradle`:
     ```gradle
     dependencies {
         classpath 'com.google.gms:google-services:4.4.0'
     }
     ```

   - `android/app/build.gradle`:
     ```gradle
     apply plugin: 'com.google.gms.google-services'
     ```

## iOS Setup

1. **Add iOS app to Firebase:**
   - Bundle ID: `com.traqa.health`
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/GoogleService-Info.plist`

2. **Update iOS Podfile:**
   ```ruby
   # Add to top of Podfile
   platform :ios, '12.0'
   ```

## Firebase Configuration

Update `lib/firebase_options.dart` with your actual Firebase project credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_ANDROID_API_KEY',
  appId: 'YOUR_ACTUAL_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  storageBucket: 'YOUR_ACTUAL_STORAGE_BUCKET',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_IOS_API_KEY',
  appId: 'YOUR_ACTUAL_IOS_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  storageBucket: 'YOUR_ACTUAL_STORAGE_BUCKET',
  iosBundleId: 'com.traqa.health',
);
```

## Cloud Functions Setup

1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Initialize Functions:**
   ```bash
   cd functions
   npm install
   ```

4. **Set environment variables:**
   Update `functions/.env` with:
   ```
   GEMINI_API_KEY=your_actual_gemini_api_key
   RAZORPAY_KEY_ID=your_actual_razorpay_key_id
   RAZORPAY_KEY_SECRET=your_actual_razorpay_key_secret
   ```

5. **Deploy Functions:**
   ```bash
   firebase deploy --only functions
   ```

## Razorpay Setup

1. Create Razorpay account at [https://razorpay.com](https://razorpay.com)
2. Get API keys from Razorpay dashboard
3. Update environment variables in Cloud Functions

## Google Gemini Setup

1. Get Gemini API key from [Google AI Studio](https://makersuite.google.com)
2. Update environment variable in Cloud Functions

## Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /reports/{reportId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /payments/{paymentId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/reports/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Testing

1. Run the app:
   ```bash
   flutter run
   ```

2. Test Cloud Functions locally:
   ```bash
   cd functions
   npm run serve
   ```

## Troubleshooting

- Make sure all Firebase services are enabled in the console
- Verify API keys are correctly set in environment variables
- Check that the FlutterFire CLI has generated correct configuration
- Ensure proper permissions for Google Sign-in are configured