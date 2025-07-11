import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import '../models/personality.dart';
import '../models/message.dart' as app_models;
import '../config/constants.dart';

class AIService extends ChangeNotifier {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  bool _isInitialized = false;
  bool _isLoading = false;
  double _downloadProgress = 0.0;
  String? _error;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  double get downloadProgress => _downloadProgress;
  String? get error => _error;
  bool get hasError => _error != null;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Skip AI initialization on web platform
      if (kIsWeb) {
        _error = 'AI features are not available on web platform. Please use the mobile app for AI functionality.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if model file exists
      final modelPath = await _getModelPath();
      if (modelPath != null) {
        // Initialize flutter_gemma with the model
        await FlutterGemmaPlugin.instance.init(
          modelPath: modelPath,
          maxTokens: 4096,
          temperature: 0.8,
          topK: 40,
        );
        _isInitialized = true;
      } else {
        // Model needs to be downloaded
        _error = 'Model not downloaded. Please download the AI model first.';
      }
    } catch (e) {
      _error = 'Failed to initialize AI service: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadModel() async {
    if (_isLoading) return;

    if (kIsWeb) {
      _error = 'Model download is not available on web platform.';
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      _downloadProgress = 0.0;
      _error = null;
      notifyListeners();

      // Try to find and setup model
      final modelPath = await _getModelPath();
      if (modelPath != null) {
        _downloadProgress = 1.0;
        notifyListeners();
        await initialize();
        return;
      }
      
      // If no model found, provide simple instructions
      _error = '''Model not found!

To use the AI:
1. Place your model.bin file in the Downloads folder
2. Tap this button again

The app will automatically copy it to the right place.''';
    } catch (e) {
      _error = 'Failed to download model: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _getModelPath() async {
    // Skip on web platform
    if (kIsWeb) {
      return null;
    }
    
    // Get app's documents directory for storing the model
    final appDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDir.path}/model.bin';
    final modelFile = File(modelPath);
    
    // Check if model already exists in app documents
    if (await modelFile.exists()) {
      debugPrint('Model found at: $modelPath');
      return modelPath;
    }
    
    // Try to copy from assets
    try {
      debugPrint('Copying model from assets...');
      final data = await rootBundle.load('assets/models/model.bin');
      final bytes = data.buffer.asUint8List();
      await modelFile.writeAsBytes(bytes);
      debugPrint('Model copied successfully to: $modelPath');
      return modelPath;
    } catch (e) {
      debugPrint('Model not found in assets: $e');
    }
    
    // For development: check Downloads folder
    if (Platform.isAndroid) {
      final downloadsPath = '/storage/emulated/0/Download/model.bin';
      if (await File(downloadsPath).exists()) {
        debugPrint('Found model in Downloads, copying to app directory...');
        await File(downloadsPath).copy(modelPath);
        return modelPath;
      }
    }
    
    return null;
  }

  Stream<String> generateResponse({
    required String prompt,
    required Personality personality,
    List<app_models.Message>? conversationHistory,
  }) async* {
    if (kIsWeb) {
      yield 'AI features are not available on web platform. Please use the mobile app for AI functionality.';
      return;
    }
    
    if (!_isInitialized) {
      yield 'AI model not initialized. Please download the model first.';
      return;
    }

    try {
      // Build conversation messages for flutter_gemma
      final messages = <Message>[];
      
      // Add system prompt as first message
      messages.add(Message(
        text: personality.systemPrompt,
        isUser: false,
      ));
      
      // Add conversation history
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentMessages = conversationHistory.length > 10
            ? conversationHistory.sublist(conversationHistory.length - 10)
            : conversationHistory;
        
        for (final msg in recentMessages) {
          messages.add(Message(
            text: msg.content,
            isUser: msg.isUser,
          ));
        }
      }
      
      // Add current user message
      messages.add(Message(
        text: prompt,
        isUser: true,
      ));

      // Generate response using flutter_gemma
      final responseStream = FlutterGemmaPlugin.instance.getChatResponseAsync(
        messages: messages,
        chatContextLength: 4,
      );

      await for (final chunk in responseStream) {
        if (chunk != null) {
          yield chunk;
        }
      }
    } catch (e) {
      _error = 'Failed to generate response: $e';
      debugPrint(_error);
      yield 'Sorry, I encountered an error generating a response. Please try again.';
    }
  }

  @override
  void dispose() {
    // flutter_gemma 0.2.4 doesn't have a dispose method
    super.dispose();
  }
}