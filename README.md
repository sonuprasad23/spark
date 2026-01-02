# 🔥 SPARK - Dating That Means More

<p align="center">
  <img src="assets/images/spark_logo.png" width="120" alt="SPARK Logo">
</p>

<p align="center">
  <strong>A curated dating app for meaningful connections</strong><br>
  5 weekly matches • 7-day connection rooms • Decision Day
</p>

---

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [Project Structure](#-project-structure)
3. [Prerequisites](#-prerequisites)
4. [Firebase Setup](#-firebase-setup)
5. [Android Configuration](#-android-configuration)
6. [iOS Configuration](#-ios-configuration)
7. [Codemagic CI/CD](#-codemagic-cicd)
8. [Environment Variables](#-environment-variables)
9. [Design System](#-design-system)
10. [Features Overview](#-features-overview)
11. [Troubleshooting](#-troubleshooting)

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-org/spark-app.git
cd spark-app

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Firebase (see Firebase Setup section)
flutterfire configure

# 4. Run the app
flutter run
```

---

## 📁 Project Structure

```
spark_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── constants/            # App constants
│   │   ├── models/               # Data models
│   │   ├── providers/            # Riverpod state management
│   │   ├── router/               # GoRouter navigation
│   │   └── theme/                # Design system & themes
│   ├── features/
│   │   ├── auth/                 # Login, OTP, Google Sign-In
│   │   ├── onboarding/           # User onboarding flow
│   │   ├── home/                 # Main app home
│   │   ├── matches/              # Match cards & reveal
│   │   ├── chat/                 # 7-day chat rooms
│   │   └── profile/              # Profile editor, premium
│   └── shared/
│       └── widgets/              # Reusable UI components
├── functions/                    # Firebase Cloud Functions
│   └── src/
│       ├── services/             # User, Matching, Chat services
│       └── scheduled/            # Weekly matches, room expiry
├── assets/
│   ├── images/                   # App images
│   ├── icons/                    # Custom icons
│   ├── animations/               # Lottie animations
│   └── fonts/                    # Outfit font family
├── android/                      # Android native code
├── ios/                          # iOS native code
├── codemagic.yaml               # CI/CD configuration
├── firebase.json                # Firebase project config
├── firestore.rules              # Database security rules
└── storage.rules                # Storage security rules
```

---

## ✅ Prerequisites

### Required Tools

| Tool | Version | Download |
|------|---------|----------|
| Flutter | 3.24.5+ | [flutter.dev](https://flutter.dev) |
| Dart | 3.8.0+ | Included with Flutter |
| Android Studio | 2024.1+ | [developer.android.com](https://developer.android.com/studio) |
| Xcode | 15.0+ | Mac App Store |
| Node.js | 18+ | [nodejs.org](https://nodejs.org) |
| Firebase CLI | Latest | `npm install -g firebase-tools` |
| FlutterFire CLI | Latest | `dart pub global activate flutterfire_cli` |

### Verify Installation

```bash
flutter doctor -v
firebase --version
node --version
```

---

## 🔥 Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"**
3. Name it `spark-dating` or similar
4. **Enable Google Analytics** (recommended)
5. Select or create an Analytics account

### Step 2: Enable Firebase Services

In your Firebase project, enable:

| Service | Location | Notes |
|---------|----------|-------|
| **Authentication** | Build > Authentication | Enable Phone & Google |
| **Cloud Firestore** | Build > Firestore Database | Start in **test mode** initially |
| **Storage** | Build > Storage | For photos & media |
| **Cloud Functions** | Build > Functions | Requires Blaze plan |
| **Cloud Messaging** | Engage > Messaging | For push notifications |

### Step 3: Configure Authentication

1. Go to **Authentication > Sign-in method**
2. Enable **Phone** authentication
3. Enable **Google** authentication
4. Add your **SHA-1 fingerprint** for Android:

```bash
# Debug SHA-1 (for development)
cd android
./gradlew signingReport
```

### Step 4: Configure Flutter with Firebase

```bash
# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure --project=your-project-id

# This creates:
# - lib/firebase_options.dart
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist
```

### Step 5: Deploy Cloud Functions

```bash
# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy to Firebase
firebase deploy --only functions
```

### Step 6: Deploy Security Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

---

## 🤖 Android Configuration

### File: `android/app/build.gradle`

```gradle
android {
    namespace "com.spark.dating"
    compileSdk 35  // Use latest

    defaultConfig {
        applicationId "com.spark.dating"
        minSdk 24       // Android 7.0+
        targetSdk 35
        versionCode 1
        versionName "1.0.0"
        
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### File: `android/app/src/main/AndroidManifest.xml`

Add these permissions and configurations:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <application
        android:label="SPARK"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:enableOnBackInvokedCallback="true">
        
        <!-- MainActivity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme">
            <!-- ... -->
        </activity>
        
        <!-- FCM Service -->
        <service
            android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT"/>
            </intent-filter>
        </service>
        
        <!-- Notification Channels -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="spark_messages"/>
            
    </application>
</manifest>
```

### Generate Keystore (Release Signing)

```bash
# Create keystore for release builds
keytool -genkey -v -keystore spark-release-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias spark-key
```

### File: `android/key.properties`

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=spark-key
storeFile=../spark-release-key.jks
```

> ⚠️ **Never commit key.properties or .jks files to git!**

---

## 🍎 iOS Configuration

### File: `ios/Runner/Info.plist`

Add these entries:

```xml
<!-- Camera & Photo Library -->
<key>NSCameraUsageDescription</key>
<string>SPARK needs camera access for profile photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>SPARK needs photo library access for profile photos</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>SPARK needs microphone for voice notes</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>SPARK needs location to find matches near you</string>

<!-- Notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Signing & Capabilities**
4. Select your **Team**
5. Set **Bundle Identifier**: `com.spark.dating`

---

## 🔧 Codemagic CI/CD

### Step 1: Connect Repository

1. Go to [Codemagic](https://codemagic.io)
2. Sign up/Login with GitHub
3. Click **"Add application"**
4. Select your repository

### Step 2: Configure Environment Groups

Create environment groups in Codemagic dashboard:

#### Group: `firebase_credentials`
| Variable | Value |
|----------|-------|
| `FIREBASE_CONFIG` | Base64 of `google-services.json` |
| `FIREBASE_IOS_CONFIG` | Base64 of `GoogleService-Info.plist` |

To encode:
```bash
base64 -i android/app/google-services.json
base64 -i ios/Runner/GoogleService-Info.plist
```

#### Group: `play_store`
| Variable | Value |
|----------|-------|
| `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | Service account JSON |

### Step 3: Configure Android Signing

1. Go to **Teams > Code signing identities**
2. Add **Android keystore**
3. Upload your `.jks` file
4. Name it: `spark_keystore`

### Step 4: Build Commands

```bash
# Manual build from Codemagic UI or:
# Push to main branch → triggers debug build
# Create tag v1.0.0 → triggers release build
git tag v1.0.0
git push origin v1.0.0
```

---

## 🔐 Environment Variables

### File: `.env`

```env
# Firebase (optional - usually auto-configured)
FIREBASE_PROJECT_ID=your-project-id

# Razorpay (Payments)
RAZORPAY_KEY_ID=rzp_test_xxxxx
RAZORPAY_KEY_SECRET=your_secret

# API Keys
GOOGLE_MAPS_API_KEY=your_maps_key
```

### Add to `.gitignore`

```gitignore
.env
*.jks
key.properties
google-services.json
GoogleService-Info.plist
```

---

## 🎨 Design System

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#FF6B6B` | Buttons, accents |
| Primary Dark | `#EE5A5A` | Pressed states |
| Background | `#0D0D1A` | Main background |
| Surface | `#1A1A2E` | Cards, dialogs |
| Text Primary | `#FFFFFF` | Headings |
| Text Secondary | `#A0A0B0` | Body text |
| Success | `#4ADE80` | Confirmations |
| Warning | `#FBBF24` | Alerts |
| Error | `#F87171` | Errors |
| Premium Gold | `#FFD700` | Premium features |

### Typography (Outfit Font)

Download **Outfit** font from [Google Fonts](https://fonts.google.com/specimen/Outfit)

Place files in `assets/fonts/`:
- `Outfit-Light.ttf` (300)
- `Outfit-Regular.ttf` (400)
- `Outfit-Medium.ttf` (500)
- `Outfit-SemiBold.ttf` (600)
- `Outfit-Bold.ttf` (700)
- `Outfit-ExtraBold.ttf` (800)

### Icons

Using **Phosphor Icons** - [phosphoricons.com](https://phosphoricons.com)

```dart
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

Icon(PhosphorIcons.heart_fill)
Icon(PhosphorIcons.chat_circle)
Icon(PhosphorIcons.user)
```

### Animations

Using **Flutter Animate** + **Lottie**

```dart
// Flutter Animate
Widget().animate().fade().slideY()

// Lottie (place .json in assets/animations/)
Lottie.asset('assets/animations/heart.json')
```

Recommended Lottie animations:
- `heart_pulse.json` - Match success
- `confetti.json` - Celebration
- `loading.json` - Loading states
- `empty_state.json` - Empty lists

Get free animations from [LottieFiles](https://lottiefiles.com)

---

## ✨ Features Overview

### Core Features

| Feature | Description | Day |
|---------|-------------|-----|
| **Weekly Matches** | 5-10 curated matches every Sunday | - |
| **Match Cards** | Flip animation reveal | - |
| **7-Day Rooms** | Temporary chat rooms | 1-7 |
| **Icebreakers** | Conversation starters | Day 1 |
| **Voice Notes** | Audio messages | Day 3+ |
| **Photo Sharing** | Image messages | Day 5+ |
| **Decision Day** | Connect/Pass/Extend | Day 7 |

### Premium Features

| Tier | Price | Features |
|------|-------|----------|
| **Plus** | ₹199/mo | 7 matches, see likes, read receipts |
| **Pro** | ₹499/mo | 10 matches, extensions, rewinds, boost |

---

## 🔔 Push Notifications

### Notification Channels (Android)

| Channel ID | Name | Description |
|------------|------|-------------|
| `spark_messages` | Messages | Chat messages |
| `spark_matches` | Matches | New match alerts |
| `spark_reminders` | Reminders | Decision day reminders |

### Setup FCM

1. Enable Cloud Messaging in Firebase Console
2. For iOS, upload APNs certificate/key
3. Test with Firebase Console → Messaging → Send test message

---

## 🐛 Troubleshooting

### Common Issues

#### "Firebase not configured"
```bash
flutterfire configure
```

#### "Gradle build failed"
```bash
cd android
./gradlew clean
flutter clean
flutter pub get
```

#### "CocoaPods not found"
```bash
sudo gem install cocoapods
cd ios && pod install
```

#### "Signing certificate not found" (iOS)
1. Open Xcode
2. Runner > Signing & Capabilities
3. Select your team

#### "google-services.json not found"
```bash
flutterfire configure
# Or download manually from Firebase Console
```

### Debug Commands

```bash
# Verbose build
flutter run -v

# Check for issues
flutter doctor -v

# Clean rebuild
flutter clean && flutter pub get && flutter run
```

---

## 📱 Build Commands

```bash
# Development
flutter run

# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# iOS (Release)
flutter build ipa --release
```

---

## 📄 License

Private & Confidential - SPARK Dating App © 2024

---

## 🤝 Support

For issues or questions:
- Create a GitHub issue
- Email: dev@sparkdating.app

