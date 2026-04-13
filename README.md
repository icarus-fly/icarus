# 🏥 Traqa - Your Family's Health, In Words You Understand

**AI-powered medical report simplification app for Indian families**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-9.0+-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 What is Traqa?

Traqa is a revolutionary health app that decodes complex medical reports, prescriptions, MRI scans, and X-rays into plain regional language explanations — with diagrams and audio — so even illiterate family members can understand their health condition.

**The emotional hook:** One person (usually the adult child) manages health for their entire family from one account. Reports from a parent in another city trigger real-time notifications to the family manager, with AI explanations in their regional language.

## ✨ Features

### 🏥 Medical Report Analysis
- **Multi-format Support**: Upload photos, scanned documents, or PDF reports
- **AI-Powered Analysis**: Google Gemini AI analyzes and simplifies medical jargon
- **12 Regional Languages**: Hindi, Tamil, Bengali, Telugu, Marathi, Gujarati, Kannada, Malayalam, Punjabi, Odia, Assamese, Urdu
- **Audio Explanations**: Text-to-speech in regional languages for illiterate users

### 👨‍👩‍👧‍👦 Family Health Management
- **Family Profiles**: Add and manage multiple family members
- **Real-time Alerts**: Get notified when family members upload reports
- **Cross-location Care**: Manage health for relatives in different cities
- **Relationship-based UI**: Color-coded avatars based on family relationships

### 🔔 Smart Notifications
- **Push Notifications**: Instant alerts for report readiness
- **Health Reminders**: Daily check-in reminders
- **Customizable Preferences**: Control what notifications you receive

### 💳 Premium Features
- **Family Slots**: ₹50/year per additional family member
- **Health Tracking**: ₹50/month for advanced health monitoring
- **Secure Payments**: Razorpay integration with proper verification

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart) - Latest stable version
- **Backend**: Firebase (Auth, Firestore, Storage, Functions, FCM)
- **AI**: Google Gemini 1.5 Flash API
- **Payments**: Razorpay Flutter SDK
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Notifications**: Firebase Cloud Messaging

## 🚀 Quick Start

### Prerequisites

1. **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
2. **Firebase Account**: [Create Firebase Project](https://console.firebase.google.com)
3. **Google Gemini API Key**: [Get from Google AI Studio](https://makersuite.google.com)
4. **Razorpay Account**: [Sign up at Razorpay](https://razorpay.com)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/traqa.git
   cd traqa
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize project
   firebase init
   ```

4. **Configure environment variables**
   
   Update `functions/.env`:
   ```env
   GEMINI_API_KEY=your_gemini_api_key
   RAZORPAY_KEY_ID=your_razorpay_key_id
   RAZORPAY_KEY_SECRET=your_razorpay_key_secret
   ```

5. **Deploy Cloud Functions**
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

```
traqa/
├── android/                 # Android specific files
├── ios/                   # iOS specific files
├── lib/                   # Flutter application code
│   ├── app/              # App configuration
│   ├── core/             # Core functionality
│   │   ├── constants/    # App constants and strings
│   │   ├── providers/    # Riverpod state providers
│   │   └── services/     # Business logic services
│   ├── features/         # Feature modules
│   │   ├── family/       # Family management
│   │   ├── history/      # Report history
│   │   ├── onboarding/   # Login and setup
│   │   ├── profile/      # User profile
│   │   ├── report/       # Report analysis flow
│   │   └── streak/       # Health tracking
│   └── shared/           # Shared components
├── functions/            # Firebase Cloud Functions
│   ├── index.js         # Main functions file
│   └── package.json     # Node.js dependencies
└── assets/              # Static assets
    └── logo/            # App logos and icons
```

## 🎨 UI/UX Features

- **Dark Theme**: Easy-on-eyes interface for medical content
- **Responsive Design**: Works on all mobile devices
- **Accessibility**: Large text, high contrast, audio support
- **Intuitive Navigation**: Smooth flow between features
- **Loading States**: Professional loading animations
- **Error Handling**: User-friendly error messages

## 🔒 Security

- **Firebase Security Rules**: Proper data isolation
- **Payment Verification**: Backend payment validation
- **API Key Protection**: Never exposed in client code
- **User Authentication**: Google Sign-in with proper scopes
- **Data Encryption**: Firebase Storage encryption

## 📊 Database Schema

### Firestore Collections

- `users/{userId}` - User profiles and preferences
- `users/{userId}/familyMembers` - Family member data
- `users/{userId}/reports` - Medical report analysis results
- `users/{userId}/payments` - Payment transaction history

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Test Cloud Functions locally
cd functions
npm run serve
```

## 📈 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📧 Email: support@traqa.health
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/traqa/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/your-username/traqa/discussions)

## 🙏 Acknowledgments

- Google Gemini AI for medical analysis
- Firebase for backend infrastructure
- Razorpay for payment processing
- Flutter team for the amazing framework
- Indian regional language communities

---

**Made with ❤️ for Indian Families**

*Your family's health, in words you understand.*