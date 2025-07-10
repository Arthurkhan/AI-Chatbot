import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'dart:async';
import '../models/personality.dart';
import '../models/message.dart';
import '../config/constants.dart';

class AIService extends ChangeNotifier {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  InferenceModel? _model;
  ModelFileManager? _modelManager;
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

      // Initialize model manager
      _modelManager = ModelFileManager();
      
      // Check if model is already downloaded
      final modelPath = await _getModelPath();
      if (modelPath != null) {
        await _loadModel(modelPath);
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

    try {
      _isLoading = true;
      _downloadProgress = 0.0;
      _error = null;
      notifyListeners();

      // Download model with progress updates
      await for (final progress in _modelManager!.installModelFromNetworkWithProgress(
        AppConstants.modelDownloadUrl,
      )) {
        _downloadProgress = progress / 100.0;
        notifyListeners();
      }

      // Load the downloaded model
      final modelPath = await _getModelPath();
      if (modelPath != null) {
        await _loadModel(modelPath);
      }
    } catch (e) {
      _error = 'Failed to download model: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _getModelPath() async {
    // This would check for the model in the app's storage
    // For now, returning null to indicate model needs downloading
    return null;
  }

  Future<void> _loadModel(String modelPath) async {
    try {
      _model = await _modelManager!.loadModel(
        modelPath,
        config: InferenceConfig(
          maxTokens: AppConstants.maxTokens,
          temperature: AppConstants.defaultTemperature,
          topK: AppConstants.defaultTopK,
        ),
      );
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to load model: $e';
      debugPrint(_error);
    }
  }

  Stream<String> generateResponse({
    required String prompt,
    required Personality personality,
    List<Message>? conversationHistory,
  }) async* {
    if (!_isInitialized || _model == null) {
      yield 'AI model not initialized. Please download the model first.';
      return;
    }

    try {
      // Build the full prompt with personality context
      final fullPrompt = _buildPrompt(
        systemPrompt: personality.systemPrompt,
        conversationHistory: conversationHistory,
        userMessage: prompt,
      );

      // Create inference session
      final session = await _model!.createSession();

      // Add the prompt
      await session.addQueryChunk(
        Message.text(text: fullPrompt, isUser: true),
      );

      // Stream the response
      String fullResponse = '';
      await for (final chunk in session.getResponseAsync()) {
        fullResponse += chunk;
        yield fullResponse;
      }

      // Close the session
      await session.close();
    } catch (e) {
      _error = 'Failed to generate response: $e';
      debugPrint(_error);
      yield 'Sorry, I encountered an error generating a response. Please try again.';
    }
  }

  String _buildPrompt({
    required String systemPrompt,
    List<Message>? conversationHistory,
    required String userMessage,
  }) {
    final buffer = StringBuffer();
    
    // Add system prompt
    buffer.writeln('System: $systemPrompt');
    buffer.writeln();
    
    // Add conversation history (limit to recent messages to fit context)
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      final recentMessages = conversationHistory.length > 10
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;
      
      buffer.writeln('Conversation history:');
      for (final message in recentMessages) {
        final role = message.isUser ? 'User' : 'Assistant';
        buffer.writeln('$role: ${message.content}');
      }
      buffer.writeln();
    }
    
    // Add current user message
    buffer.writeln('User: $userMessage');
    buffer.writeln('Assistant:');
    
    return buffer.toString();
  }

  void dispose() {
    _model?.dispose();
    super.dispose();
  }
}