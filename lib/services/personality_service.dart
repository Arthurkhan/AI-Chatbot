import 'package:flutter/foundation.dart';
import '../models/personality.dart';
import '../models/conversation.dart';
import 'database_service.dart';

class PersonalityService extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  List<Personality> _personalities = [];
  Personality? _currentPersonality;
  bool _isLoading = false;
  String? _error;

  List<Personality> get personalities => _personalities;
  Personality? get currentPersonality => _currentPersonality;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  Future<void> loadPersonalities() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _personalities = await _db.getPersonalities();
      
      // Set current personality if not set
      if (_currentPersonality == null && _personalities.isNotEmpty) {
        _currentPersonality = _personalities.first;
      }
    } catch (e) {
      _error = 'Failed to load personalities: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPersonality({
    required String name,
    required String description,
    required String systemPrompt,
    required int avatarColor,
  }) async {
    try {
      _error = null;
      
      final personality = Personality(
        name: name,
        description: description,
        systemPrompt: systemPrompt,
        avatarColor: avatarColor,
      );

      await _db.createPersonality(personality);
      _personalities.add(personality);
      
      // Set as current if it's the first personality
      if (_personalities.length == 1) {
        _currentPersonality = personality;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create personality: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  Future<void> updatePersonality(Personality personality) async {
    try {
      _error = null;
      
      await _db.updatePersonality(personality);
      
      // Update in local list
      final index = _personalities.indexWhere((p) => p.id == personality.id);
      if (index != -1) {
        _personalities[index] = personality;
      }
      
      // Update current if it's the updated personality
      if (_currentPersonality?.id == personality.id) {
        _currentPersonality = personality;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update personality: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  Future<void> deletePersonality(String id) async {
    try {
      _error = null;
      
      await _db.deletePersonality(id);
      
      // Remove from local list
      _personalities.removeWhere((p) => p.id == id);
      
      // Update current personality if deleted
      if (_currentPersonality?.id == id) {
        _currentPersonality = _personalities.isNotEmpty ? _personalities.first : null;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete personality: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  Future<void> archivePersonality(String id) async {
    try {
      _error = null;
      
      final personality = _personalities.firstWhere((p) => p.id == id);
      final archived = personality.copyWith(isArchived: true);
      
      await _db.updatePersonality(archived);
      
      // Remove from active list
      _personalities.removeWhere((p) => p.id == id);
      
      // Update current personality if archived
      if (_currentPersonality?.id == id) {
        _currentPersonality = _personalities.isNotEmpty ? _personalities.first : null;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to archive personality: $e';
      debugPrint(_error);
      rethrow;
    }
  }

  void setCurrentPersonality(Personality personality) {
    _currentPersonality = personality;
    notifyListeners();
  }

  Future<Conversation> createConversation() async {
    if (_currentPersonality == null) {
      throw Exception('No personality selected');
    }

    final conversation = Conversation(
      personalityId: _currentPersonality!.id,
      title: 'New Chat',
    );

    await _db.createConversation(conversation);
    return conversation;
  }

  Future<List<Conversation>> getConversations() async {
    if (_currentPersonality == null) {
      return [];
    }

    return await _db.getConversations(_currentPersonality!.id);
  }
}