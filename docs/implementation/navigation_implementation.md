# Navigation Implementation

**Last Updated**: 2025-07-10
**Priority**: HIGH
**Estimated Time**: 2 hours

## Overview

Implement app-wide navigation using Navigator 2.0 with go_router for:
- Type-safe routing
- Deep linking support
- Bottom navigation
- Nested navigation
- Route guards

## Implementation Steps

### Step 1: Add go_router Dependency

Update `pubspec.yaml`:

```yaml
dependencies:
  # ... existing dependencies
  go_router: ^13.0.0
```

### Step 2: Create Route Configuration

Create `lib/config/routes.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/personalities/personalities_screen.dart';
import '../screens/personalities/personality_detail_screen.dart';
import '../screens/personalities/create_personality_screen.dart';
import '../screens/personalities/edit_personality_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/home/home_screen.dart';
import '../models/personality.dart';
import '../models/conversation.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String personalities = '/personalities';
  static const String personalityDetail = '/personalities/:id';
  static const String createPersonality = '/personalities/create';
  static const String editPersonality = '/personalities/:id/edit';
  static const String chat = '/chat/:conversationId';
  static const String settings = '/settings';
  static const String about = '/settings/about';
  static const String permissions = '/settings/permissions';
  static const String archived = '/settings/archived';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Home with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          // Personalities Tab
          GoRoute(
            path: AppRoutes.personalities,
            builder: (context, state) => const PersonalitiesScreen(),
            routes: [
              // Create Personality
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreatePersonalityScreen(),
              ),
              
              // Personality Detail
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final personality = state.extra as Personality?;
                  if (personality == null) {
                    return const ErrorScreen(message: 'Personality not found');
                  }
                  return PersonalityDetailScreen(personality: personality);
                },
                routes: [
                  // Edit Personality
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final personality = state.extra as Personality?;
                      if (personality == null) {
                        return const ErrorScreen(message: 'Personality not found');
                      }
                      return EditPersonalityScreen(personality: personality);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Settings Tab
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              // About
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutScreen(),
              ),
              
              // Permissions
              GoRoute(
                path: 'permissions',
                builder: (context, state) => const PermissionsScreen(),
              ),
              
              // Archived Personalities
              GoRoute(
                path: 'archived',
                builder: (context, state) => const ArchivedPersonalitiesScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Chat Screen (Full Screen)
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          if (extras == null) {
            return const ErrorScreen(message: 'Chat data not found');
          }
          
          final conversation = extras['conversation'] as Conversation;
          final personality = extras['personality'] as Personality;
          
          return ChatScreen(
            conversation: conversation,
            personality: personality,
          );
        },
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => ErrorScreen(
      message: state.error?.toString() ?? 'Page not found',
    ),
    
    // Redirect logic
    redirect: (context, state) {
      // Add any authentication or onboarding checks here
      return null;
    },
  );
}

// Error Screen
class ErrorScreen extends StatelessWidget {
  final String message;
  
  const ErrorScreen({super.key, required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.personalities),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 3: Create Home Screen with Bottom Navigation

Create `lib/screens/home/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final Widget child;
  
  const HomeScreen({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Personalities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
  
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location.startsWith('/settings')) {
      return 1;
    }
    return 0;
  }
  
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/personalities');
        break;
      case 1:
        context.go('/settings');
        break;
    }
  }
}
```

### Step 4: Update Main App

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/themes.dart';
import 'config/routes.dart';
import 'services/ai_service.dart';
import 'services/database_service.dart';
import 'services/permission_service.dart';
import 'services/personality_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await DatabaseService.instance.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AIService()),
        ChangeNotifierProvider(create: (_) => PersonalityService()),
        Provider(create: (_) => PermissionService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp.router(
            title: 'AI Chatbot',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeService.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
```

### Step 5: Navigation Usage Examples

#### Navigate to Routes

```dart
// Simple navigation
context.go('/personalities');

// Navigation with parameters
context.go('/personalities/${personality.id}', extra: personality);

// Navigate to chat
context.go(
  '/chat/${conversation.id}',
  extra: {
    'conversation': conversation,
    'personality': personality,
  },
);

// Push route (adds to stack)
context.push('/personalities/create');

// Pop route
context.pop();

// Pop with result
context.pop(personality);
```

#### Update Screen Navigation

Update all Navigator.push/pop calls to use go_router:

**Before:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => CreatePersonalityScreen(),
  ),
);
```

**After:**
```dart
context.push('/personalities/create');
```

### Step 6: Deep Linking Configuration

#### Android

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep linking -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data
            android:scheme="aichatbot"
            android:host="app"/>
    </intent-filter>
</activity>
```

#### iOS

Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>aichatbot</string>
        </array>
    </dict>
</array>
```

### Step 7: Route Guards

Add authentication or onboarding checks:

```dart
redirect: (context, state) {
  final isFirstLaunch = // Check if first launch
  final isModelDownloaded = // Check if AI model is downloaded
  
  // Redirect to splash if model not downloaded
  if (!isModelDownloaded && state.location != '/') {
    return '/';
  }
  
  // Add more guards as needed
  return null;
},
```

## Testing Navigation

1. **Test all routes work correctly**
2. **Test deep links**: `aichatbot://app/personalities`
3. **Test back button behavior**
4. **Test state preservation**
5. **Test error handling**

## Common Issues

1. **Missing extra data**: Always check for null
2. **Route not found**: Ensure paths match exactly
3. **Back button**: Use `context.pop()` not `Navigator.pop()`
4. **State loss**: Pass data through `extra` parameter

## Next Steps

After implementing navigation:
1. Update all screens to use go_router
2. Test deep linking
3. Add route animations if desired
4. Implement route guards for protected screens