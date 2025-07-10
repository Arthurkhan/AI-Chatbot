import 'package:uuid/uuid.dart';

class Personality {
  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final int avatarColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final Map<String, dynamic>? settings;

  Personality({
    String? id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.avatarColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isArchived = false,
    this.settings,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Personality.fromMap(Map<String, dynamic> map) {
    return Personality(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      systemPrompt: map['system_prompt'] as String,
      avatarColor: map['avatar_color'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isArchived: (map['is_archived'] as int) == 1,
      settings: map['settings'] != null
          ? Map<String, dynamic>.from(map['settings'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'system_prompt': systemPrompt,
      'avatar_color': avatarColor,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_archived': isArchived ? 1 : 0,
      'settings': settings,
    };
  }

  Personality copyWith({
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    int? avatarColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    Map<String, dynamic>? settings,
  }) {
    return Personality(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      avatarColor: avatarColor ?? this.avatarColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isArchived: isArchived ?? this.isArchived,
      settings: settings ?? this.settings,
    );
  }

  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return words.take(2).map((w) => w.substring(0, 1).toUpperCase()).join();
  }
}