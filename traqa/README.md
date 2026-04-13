# Traqa - Family Health App

Your family's health, in words you understand.

## Setup Instructions

### Firebase Setup (Required)

1. **Create Firebase Project** at [console.firebase.google.com](https://console.firebase.google.com)
2. **Enable Services**:
   - Authentication (Google Sign-In)
   - Firestore Database
   - Firebase Storage
   - Cloud Functions
   - Firebase Cloud Messaging
   - Firebase Hosting (optional)

3. **Add Apps**:
   - **Android**: Package `com.traqa.health`
   - **iOS**: Bundle ID `com.traqa.health`

4. **Download Config Files**:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

### Firebase CLI Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
cd functions
npm install

# Configure Firebase project
firebase use --add

# Deploy functions
firebase deploy --only functions
```

### Environment Variables

Create `.env` file in `functions/` directory:

```env
GEMINI_API_KEY=your_gemini_api_key_from_aistudio.google.com
RAZORPAY_KEY_ID=rzp_test_your_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

### Flutter Setup

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Razorpay Setup

1. Create account at [razorpay.com](https://razorpay.com)
2. Get test API keys from Dashboard
3. Configure webhooks for payment verification

## Project Structure

```
traqa/
├── android/                 # Android specific files
├── ios/                    # iOS specific files
├── lib/
│   ├── main.dart           # App entry point
│   ├── firebase_options.dart # Firebase configuration
│   ├── app/                # App configuration
│   │   ├── app.dart        # Main app widget
│   │   ├── router.dart     # Navigation routes
│   │   └── theme.dart      # App theme and styling
│   ├── core/               # Core functionality
│   │   ├── constants/      # App constants and strings
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management
│   │   └── services/       # Business logic services
│   ├── features/           # Feature modules
│   │   ├── onboarding/     # Login and language selection
│   │   ├── home/           # Main app shell
│   │   ├── history/        # Health history and trends
│   │   ├── family/         # Family management
│   │   ├── streak/         # Health streaks
│   │   ├── profile/        # User profile
│   │   └── report/         # Report processing
│   └── shared/             # Shared components
│       ├── widgets/        # Reusable widgets
│       └── utils/          # Utility functions
├── assets/                 # Static assets
│   ├── logo/              # App logos
│   ├── animations/        # Lottie animations
│   └── sounds/            # App sounds
├── functions/             # Firebase Cloud Functions
└── pubspec.yaml           # Flutter dependencies
```

## Build for Production

### Android (Play Store)
```bash
# Generate release build
flutter build appbundle

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (App Store)
```bash
# Generate iOS archive
flutter build ipa
```

## Features

- ✅ Multi-language support (12 Indian languages)
- ✅ AI-powered report analysis (Google Gemini)
- ✅ Family health tracking
- ✅ Real-time notifications
- ✅ Secure payments (Razorpay)
- ✅ Offline support
- ✅ Dark theme
- ✅ Professional healthcare design

## Dependencies

- **Firebase**: Auth, Firestore, Storage, Functions, FCM
- **Google Gemini**: AI report analysis
- **Razorpay**: Payment processing
- **Flutter**: Cross-platform mobile development

## Support

For issues and questions, please check:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Razorpay Documentation](https://razorpay.com/docs)