import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_chatbot/main.dart';
import 'package:ai_chatbot/services/theme_service.dart';
import 'package:ai_chatbot/services/ai_service.dart';
import 'package:ai_chatbot/services/personality_service.dart';
import 'package:ai_chatbot/services/permission_service.dart';

void main() {
  testWidgets('App launches test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeService()),
          ChangeNotifierProvider(create: (_) => AIService()),
          ChangeNotifierProvider(create: (_) => PersonalityService()),
          Provider(create: (_) => PermissionService()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that app launches
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}