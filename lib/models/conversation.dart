import 'package:uuid/uuid.dart';

class Conversation {
  final String id;
  final String personalityId;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final Map<String, dynamic>? metadata;

  Conversation({
    String? id,
    required this.personalityId,
    required this.title,
    this.lastMessage,
    this.lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isArchived = false,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      personalityId: map['personality_id'] as String,
      title: map['title'] as String,
      lastMessage: map['last_message'] as String?,
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_message_at'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isArchived: (map['is_archived'] as int) == 1,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personality_id': personalityId,
      'title': title,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_archived': isArchived ? 1 : 0,
      'metadata': metadata,
    };
  }

  Conversation copyWith({
    String? id,
    String? personalityId,
    String? title,
    String? lastMessage,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      personalityId: personalityId ?? this.personalityId,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (lastMessage != null && lastMessage!.isNotEmpty) {
      return lastMessage!.length > 30
          ? '${lastMessage!.substring(0, 30)}...'
          : lastMessage!;
    }
    return 'New Conversation';
  }

  String getRelativeTime() {
    if (lastMessageAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}