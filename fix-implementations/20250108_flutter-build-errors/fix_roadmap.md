# Fix Roadmap: Flutter Build Errors

Date: 2025-01-08
Author: CodeDiagnostics-CC

## Step-by-Step Resolution Plan

### 1. Verification
Before making changes, verify the environment:
```bash
# Check Flutter version
flutter --version

# Check Flutter doctor
flutter doctor -v

# Check available NDK versions
ls -la ~/Library/Android/sdk/ndk/

# Clean project state
flutter clean
flutter pub get
```

### 2. Dependency Updates

#### Update Android NDK (Priority: HIGH)
In `android/app/build.gradle.kts`, update line 11:
```kotlin
// Change from:
ndkVersion = flutter.ndkVersion

// To:
ndkVersion = "27.0.12077973"
```

#### Review flutter_gemma Package API
1. Check the actual API of flutter_gemma v0.2.0:
   - Visit https://pub.dev/packages/flutter_gemma
   - Review the example and API documentation
   - Identify correct class names and initialization patterns

### 3. Code Changes

#### Fix 1: Remove or Implement SplashScreen (Priority: HIGH)
**Option A - Quick Fix (Recommended for immediate build)**
In `lib/main.dart`:
```dart
// Remove line 12:
// import 'screens/splash/splash_screen.dart';

// Change line 49 from:
// home: const SplashScreen(),

// To:
home: const PersonalitiesScreen(), // or any existing screen
```

**Option B - Implement SplashScreen**
Create `lib/screens/splash/splash_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../personalities/personalities_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PersonalitiesScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            const Text('AI Chatbot', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
```

#### Fix 2: Resolve flutter_gemma API Issues (Priority: HIGH)
In `lib/services/ai_service.dart`:

1. **Add import alias to resolve Message conflict**:
```dart
// Change line 5:
import '../models/message.dart' as local_models;

// Remove the flutter_gemma Message import or alias it:
import 'package:flutter_gemma/flutter_gemma.dart' hide Message;
// OR
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
```

2. **Update type references** (based on actual flutter_gemma API):
```dart
// If flutter_gemma uses different class names, update accordingly
// Example (adjust based on actual API):
gemma.GemmaModel? _model;  // instead of InferenceModel
gemma.ModelManager? _modelManager;  // instead of ModelFileManager
```

3. **Fix Message usage on line 131**:
```dart
// Use the local Message model:
local_models.Message(
  content: fullPrompt,
  role: 'user',
  timestamp: DateTime.now(),
)
```

#### Fix 3: Update CardTheme Configuration (Priority: MEDIUM)
In `lib/config/themes.dart`:

Replace deprecated CardTheme usage:
```dart
// Lines 43-48, replace:
cardTheme: CardTheme(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  color: Colors.white,
),

// With:
cardTheme: CardThemeData(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  // Remove color property - it will use surface color from theme
),
```

Similarly update the dark theme CardTheme on lines 126-132.

### 4. Refactoring Suggestions

#### Create Asset Directories
```bash
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts
```

Or remove the asset declarations from `pubspec.yaml` if not needed:
```yaml
# Comment out or remove lines 64-67 if assets aren't ready
```

#### flutter_gemma Integration Pattern
Based on the documentation, consider this implementation pattern:
```dart
// Example pattern (adjust based on actual API):
class AIService {
  gemma.FlutterGemma? _gemma;
  
  Future<void> initialize() async {
    _gemma = gemma.FlutterGemma();
    await _gemma!.initialize(
      modelPath: await _downloadModel(),
    );
  }
  
  Future<String> generateResponse(String prompt) async {
    if (_gemma == null) await initialize();
    
    final response = await _gemma!.generateText(
      prompt: prompt,
      maxTokens: 500,
    );
    
    return response.text;
  }
}
```

### 5. Testing & Validation

After implementing fixes:
1. Run `flutter clean && flutter pub get`
2. Run `flutter analyze` to check for remaining issues
3. Run `flutter run` to test the build
4. If build succeeds, test:
   - App launches without crashes
   - Navigation works
   - AI service initializes (even if model isn't downloaded)

### Priority Order for Fixes
1. **HIGH**: Fix SplashScreen import (blocks compilation)
2. **HIGH**: Update NDK version in build.gradle.kts
3. **HIGH**: Resolve flutter_gemma API issues
4. **MEDIUM**: Fix CardTheme deprecation
5. **LOW**: Create asset directories or remove references
6. **LOW**: Address file_picker warnings (non-blocking)

### Estimated Time
- Quick fixes (remove SplashScreen, update NDK): 5 minutes
- flutter_gemma API investigation and fixes: 30-45 minutes
- Full implementation with testing: 1-2 hours

### Next Steps After Fixes
1. Implement remaining UI screens
2. Complete flutter_gemma integration with proper model downloading
3. Add error handling for model initialization
4. Implement proper loading states during model download
5. Test on physical Android device