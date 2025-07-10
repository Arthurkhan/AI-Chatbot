class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'AI Chatbot';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // AI Model Configuration
  static const String defaultModelName = 'gemma-2b-it-gpu-int4';
  static const String modelDownloadUrl = 'https://kaggle.com/models/google/gemma/tfLite/gemma-2b-it-gpu-int4';
  static const int modelSizeInMB = 500;
  static const int maxTokens = 1024;
  static const double defaultTemperature = 0.7;
  static const int defaultTopK = 40;

  // Database
  static const String databaseName = 'ai_chatbot.db';
  static const int databaseVersion = 1;

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyModelDownloaded = 'model_downloaded';
  static const String keyLastUsedPersonality = 'last_used_personality';
  static const String keyAppLanguage = 'app_language';

  // Pagination
  static const int messagesPageSize = 50;
  static const int conversationsPageSize = 20;

  // UI Constants
  static const double chatBubbleMaxWidth = 0.75; // 75% of screen width
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration typingIndicatorDelay = Duration(milliseconds: 500);

  // File Paths
  static const String modelsDirectory = 'models';
  static const String backupsDirectory = 'backups';
  static const String exportsDirectory = 'exports';

  // Limits
  static const int maxPersonalities = 50;
  static const int maxConversationsPerPersonality = 100;
  static const int maxMessageLength = 4000;
  static const int maxPersonalityNameLength = 50;
  static const int maxPersonalityDescriptionLength = 200;
  static const int maxSystemPromptLength = 2000;

  // Default Personalities
  static const List<Map<String, dynamic>> defaultPersonalities = [
    {
      'name': 'Assistant',
      'description': 'A helpful, general-purpose AI assistant',
      'systemPrompt': 'You are a helpful AI assistant. Be concise, accurate, and friendly in your responses.',
      'avatarColor': 0xFF2196F3,
    },
    {
      'name': 'Creative Writer',
      'description': 'Helps with creative writing and storytelling',
      'systemPrompt': 'You are a creative writing assistant. Help users with storytelling, character development, and creative ideas. Be imaginative and encouraging.',
      'avatarColor': 0xFF9C27B0,
    },
    {
      'name': 'Code Helper',
      'description': 'Programming and technical assistance',
      'systemPrompt': 'You are a programming assistant. Help users with code, debugging, and technical questions. Provide clear explanations and working code examples.',
      'avatarColor': 0xFF4CAF50,
    },
  ];

  // Permission Messages
  static const Map<String, String> permissionMessages = {
    'calendar': 'Access your calendar to help manage events and schedules',
    'contacts': 'Access your contacts to help with communication tasks',
    'camera': 'Use your camera for visual input and photo features',
    'location': 'Access your location for location-based assistance',
    'microphone': 'Use your microphone for voice input',
    'storage': 'Access files to help with document-related tasks',
    'phone': 'Make phone calls on your behalf when requested',
    'sms': 'Read and send SMS messages when requested',
    'notifications': 'Send you helpful notifications and reminders',
  };

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection available.';
  static const String errorModelNotFound = 'AI model not found. Please download it first.';
  static const String errorPermissionDenied = 'Permission denied. Please enable it in settings.';
  static const String errorDatabaseError = 'Database error occurred. Please restart the app.';
  static const String errorAIResponse = 'Failed to generate response. Please try again.';

  // Success Messages
  static const String successModelDownloaded = 'AI model downloaded successfully!';
  static const String successPersonalityCreated = 'Personality created successfully!';
  static const String successPersonalityUpdated = 'Personality updated successfully!';
  static const String successConversationDeleted = 'Conversation deleted successfully!';
  static const String successBackupCreated = 'Backup created successfully!';
}