import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/themes.dart';
import 'services/ai_service.dart';
import 'services/database_service.dart';
import 'services/database_factory.dart';
import 'services/permission_service.dart';
import 'services/personality_service.dart';
import 'services/theme_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database factory for web platform
  initializeDatabaseFactory();
  
  // Initialize services
  await DatabaseService.instance.initialize();
  
  // Initialize PersonalityService and load personalities
  final personalityService = PersonalityService();
  await personalityService.loadPersonalities();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp(personalityService: personalityService));
}

class MyApp extends StatelessWidget {
  final PersonalityService personalityService;
  
  const MyApp({super.key, required this.personalityService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AIService()),
        ChangeNotifierProvider.value(value: personalityService),
        Provider(create: (_) => PermissionService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'AI Chatbot',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}