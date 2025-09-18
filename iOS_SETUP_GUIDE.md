# iOS Setup Guide for Kasau Absence App

## Critical Issues Fixed ✅

### 1. iOS Permissions Added
All required iOS permission descriptions have been added to `ios/Runner/Info.plist`:
- Camera access for face recognition
- Location access for attendance verification  
- Photo library access for profile pictures
- Microphone access (required by camera)
- Face ID access for biometric authentication
- Notification access for reminders

## Remaining Steps to Make iOS Ready

### 2. Firebase iOS Configuration ⚠️ **REQUIRED**

**Current Issue**: Firebase is only configured for Android. iOS will crash on startup.

**Solution**: Run FlutterFire CLI to add iOS support:

```bash
# Install FlutterFire CLI (if not installed)
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Configure Firebase for iOS
flutterfire configure --project=kasau-notification-flutterfire
```

**What this does**:
- Creates `ios/Runner/GoogleService-Info.plist`
- Updates `lib/firebase_options.dart` with iOS configuration
- Configures iOS Firebase settings

### 3. iOS Development Setup

#### Prerequisites:
- macOS computer (required for iOS development)
- Xcode 14.0 or later
- iOS Developer Account (for device testing and App Store)
- CocoaPods installed: `sudo gem install cocoapods`

#### Setup Steps:

```bash
# 1. Navigate to iOS folder
cd ios

# 2. Install CocoaPods dependencies
pod install

# 3. Open workspace in Xcode (NOT .xcodeproj)
open Runner.xcworkspace
```

### 4. Xcode Configuration

In Xcode, configure the following:

#### 4.1 Team & Bundle Identifier
1. Select `Runner` project in navigator
2. Select `Runner` target
3. Go to "Signing & Capabilities" tab
4. Set your **Team** (requires Apple Developer Account)
5. Change **Bundle Identifier** to something unique: `com.yourcompany.kasau-absence`

#### 4.2 Deployment Target
- Verify **iOS Deployment Target** is set to `13.0` ✅ (Already configured)

#### 4.3 Add Required Capabilities
In "Signing & Capabilities", add:
- **Background Modes** (for location and notifications)
- **Push Notifications** (for Firebase messaging)

### 5. Build and Test

#### 5.1 Build for iOS Simulator
```bash
# From project root
flutter build ios --simulator
```

#### 5.2 Build for iOS Device
```bash
# From project root  
flutter build ios --release
```

#### 5.3 Run on Device
```bash
# Connect iOS device and run
flutter run -d ios
```

### 6. Testing Checklist

Test these features on iOS device:

- [ ] App launches without crashing
- [ ] Login functionality works
- [ ] Camera opens for face recognition
- [ ] Face detection works properly
- [ ] Location services work
- [ ] Check-in/Check-out process
- [ ] Firebase notifications
- [ ] Google Maps integration
- [ ] Photo library access

### 7. App Store Preparation

#### 7.1 Privacy Policy
Create a comprehensive privacy policy covering:
- Face recognition data usage
- Location data collection
- Camera and photo access
- Firebase/Google services usage

#### 7.2 App Store Assets
Prepare:
- App icons for all iOS sizes
- Screenshots for different device sizes
- App description and keywords
- Age rating and content warnings

#### 7.3 Build for App Store
```bash
flutter build ios --release
```

Then use Xcode to archive and upload to App Store Connect.

## Common iOS Issues & Solutions

### Issue: "No Firebase App '[DEFAULT]' has been created"
**Solution**: Ensure Firebase is properly configured for iOS (Step 2)

### Issue: Camera permission denied
**Solution**: Check Info.plist has NSCameraUsageDescription ✅ (Fixed)

### Issue: Location services not working  
**Solution**: Check Info.plist has location permissions ✅ (Fixed)

### Issue: Face detection not working on iOS
**Solution**: 
- Verify ML Kit is properly configured
- Test on physical device (not simulator)
- Check iOS-specific ML Kit requirements

### Issue: Build fails with CocoaPods errors
**Solution**:
```bash
cd ios
rm Podfile.lock
rm -rf Pods/
pod install --repo-update
```

## Estimated Timeline

- **Firebase Setup**: 30 minutes
- **Xcode Configuration**: 1-2 hours  
- **Testing & Debugging**: 4-8 hours
- **App Store Submission**: 2-4 hours
- **Total**: 1-2 days

## Next Steps

1. **IMMEDIATE**: Configure Firebase for iOS (Step 2)
2. Set up iOS development environment (Step 3)
3. Configure Xcode project (Step 4)
4. Build and test on iOS device (Step 5)
5. Prepare for App Store submission (Step 7)

**Note**: Without Firebase iOS configuration, the app will crash immediately on iOS devices.
