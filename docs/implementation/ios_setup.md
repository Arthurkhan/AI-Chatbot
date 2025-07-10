# iOS Setup Guide

**Last Updated**: 2025-07-10
**Priority**: MEDIUM
**Estimated Time**: 1-2 hours

## Overview

Complete setup guide for configuring the iOS version of the AI Chatbot app, including permissions, configurations, and App Store preparation.

## Prerequisites

- macOS with Xcode installed
- Apple Developer Account (for device testing)
- CocoaPods installed (`sudo gem install cocoapods`)

## Step 1: Update iOS Platform Version

Update `ios/Podfile`:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# Add at the top of the file
$FirebaseAnalyticsWithoutAdIdSupport = true

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'
```

## Step 2: Configure Permissions

### Update Info.plist

Edit `ios/Runner/Info.plist` to add all permission descriptions:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing configuration -->
    
    <!-- Permissions -->
    <!-- Calendar -->
    <key>NSCalendarsUsageDescription</key>
    <string>AI Chatbot needs access to your calendar to help manage events and schedules on your behalf.</string>
    
    <!-- Contacts -->
    <key>NSContactsUsageDescription</key>
    <string>AI Chatbot needs access to your contacts to help you communicate and manage your relationships.</string>
    
    <!-- Camera -->
    <key>NSCameraUsageDescription</key>
    <string>AI Chatbot needs camera access to capture photos for visual assistance and analysis.</string>
    
    <!-- Location -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>AI Chatbot needs your location to provide location-based assistance and recommendations.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>AI Chatbot needs your location to provide location-based assistance even when the app is in the background.</string>
    
    <!-- Microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string>AI Chatbot needs microphone access to enable voice input and commands.</string>
    
    <!-- Photo Library -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>AI Chatbot needs access to your photos to help you organize and analyze your images.</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>AI Chatbot needs permission to save generated or edited images to your photo library.</string>
    
    <!-- Notifications -->
    <key>NSUserNotificationsUsageDescription</key>
    <string>AI Chatbot would like to send you helpful reminders and updates.</string>
    
    <!-- Speech Recognition (for future voice transcription) -->
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>AI Chatbot needs speech recognition to convert your voice to text.</string>
    
    <!-- File Access -->
    <key>NSDocumentsFolderUsageDescription</key>
    <string>AI Chatbot needs access to documents to help you manage and analyze your files.</string>
    <key>NSDownloadsFolderUsageDescription</key>
    <string>AI Chatbot needs access to downloads to help process downloaded files.</string>
    
    <!-- Network Configuration -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
    
    <!-- Background Modes (if needed) -->
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
    
    <!-- File Sharing -->
    <key>UIFileSharingEnabled</key>
    <true/>
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    
    <!-- Status Bar -->
    <key>UIStatusBarStyle</key>
    <string>UIStatusBarStyleDefault</string>
    
    <!-- Device Capabilities -->
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    
    <!-- Orientation Support -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

## Step 3: Configure Podfile for Permissions

Update `ios/Podfile` to include permission configurations:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Add permission handler settings
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        
        ## dart: PermissionGroup.calendar
        'PERMISSION_EVENTS=1',
        
        ## dart: PermissionGroup.reminders
        'PERMISSION_REMINDERS=1',
        
        ## dart: PermissionGroup.contacts
        'PERMISSION_CONTACTS=1',
        
        ## dart: PermissionGroup.camera
        'PERMISSION_CAMERA=1',
        
        ## dart: PermissionGroup.microphone
        'PERMISSION_MICROPHONE=1',
        
        ## dart: PermissionGroup.speech
        'PERMISSION_SPEECH_RECOGNIZER=1',
        
        ## dart: PermissionGroup.photos
        'PERMISSION_PHOTOS=1',
        
        ## dart: PermissionGroup.location
        'PERMISSION_LOCATION=1',
        
        ## dart: PermissionGroup.notification
        'PERMISSION_NOTIFICATIONS=1',
        
        ## dart: PermissionGroup.mediaLibrary
        'PERMISSION_MEDIA_LIBRARY=1',
        
        ## dart: PermissionGroup.sensors
        'PERMISSION_SENSORS=1',
        
        ## dart: PermissionGroup.bluetooth
        'PERMISSION_BLUETOOTH=1',
        
        ## dart: PermissionGroup.appTrackingTransparency
        'PERMISSION_APP_TRACKING_TRANSPARENCY=1',
        
        ## dart: PermissionGroup.criticalAlerts
        'PERMISSION_CRITICAL_ALERTS=1',
      ]
    end
  end
 end
```

## Step 4: App Icons and Launch Screen

### App Icons

1. Create app icons in various sizes:
   - Use a tool like [App Icon Generator](https://appicon.co/)
   - Required sizes: 20pt, 29pt, 40pt, 60pt (in @2x and @3x)

2. Replace icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

3. Update `Contents.json` with proper icon references

### Launch Screen

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` > `Runner` > `LaunchScreen.storyboard`
3. Design your launch screen:
   - Add logo/icon
   - Set background color
   - Add app name

## Step 5: App Configuration

### Update Bundle Identifier

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` target
3. Change Bundle Identifier to your unique ID (e.g., `com.yourcompany.aichatbot`)

### Update Display Name

1. In Xcode, select `Runner` > `Info`
2. Change "Bundle display name" to "AI Chatbot"

### Configure Build Settings

```bash
# In ios/Runner.xcodeproj/project.pbxproj
# Ensure these settings:
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.aichatbot;
PRODUCT_NAME = "AI Chatbot";
MARKETING_VERSION = 1.0.0;
CURRENT_PROJECT_VERSION = 1;
```

## Step 6: Code Signing

### Development

1. Open Xcode
2. Select `Runner` target
3. Go to "Signing & Capabilities"
4. Enable "Automatically manage signing"
5. Select your team

### Production

1. Create App ID on Apple Developer Portal
2. Create provisioning profiles
3. Configure in Xcode

## Step 7: Deep Linking Configuration

Update `ios/Runner/Info.plist`:

```xml
<!-- URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>aichatbot</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.aichatbot</string>
    </dict>
</array>
```

## Step 8: Build and Test

### Install CocoaPods Dependencies

```bash
cd ios
pod install
cd ..
```

### Run on Simulator

```bash
flutter run -d ios
```

### Run on Device

1. Connect iOS device
2. Trust developer certificate on device
3. Run: `flutter run -d <device_id>`

## Step 9: Performance Optimization

### Build Settings

In Xcode, optimize build settings:

```
DEBUG_INFORMATION_FORMAT = dwarf-with-dsym;
ENABLE_BITCODE = NO;
STRIP_INSTALLED_PRODUCT = YES;
DEAD_CODE_STRIPPING = YES;
```

### Reduce App Size

1. Use App Thinning
2. Remove unused resources
3. Optimize images

## Step 10: App Store Preparation

### Screenshots

Required sizes:
- iPhone 6.7" (1290 x 2796)
- iPhone 6.5" (1242 x 2688)
- iPhone 5.5" (1242 x 2208)
- iPad 12.9" (2048 x 2732)

### App Store Information

1. **App Name**: AI Chatbot
2. **Subtitle**: Your Personal AI Assistant
3. **Description**: Focus on benefits, not features
4. **Keywords**: AI, chatbot, assistant, personal, offline
5. **Category**: Productivity
6. **Age Rating**: 4+

### Privacy Policy

Create a privacy policy covering:
- Data collection (none - all local)
- Permissions usage
- Data storage
- User rights

## Troubleshooting

### Common Issues

1. **Pod Install Fails**
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod cache clean --all
   pod install
   ```

2. **Build Fails**
   ```bash
   flutter clean
   cd ios
   rm -rf build
   cd ..
   flutter build ios
   ```

3. **Signing Issues**
   - Check Apple Developer account
   - Verify provisioning profiles
   - Clean derived data in Xcode

## Testing Checklist

- [ ] App launches correctly
- [ ] All permissions request properly
- [ ] Icons display correctly
- [ ] Launch screen appears
- [ ] Deep links work
- [ ] Orientation locks to portrait
- [ ] No crashes on device
- [ ] Performance is acceptable

## Next Steps

1. Test on multiple iOS versions
2. Submit for TestFlight beta
3. Gather feedback
4. Submit to App Store

## Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [iOS Permission Best Practices](https://developer.apple.com/design/human-interface-guidelines/ios/app-architecture/requesting-permission/)