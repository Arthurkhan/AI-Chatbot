import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String conversationId;
  final String content;
  final bool isUser;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  Message({
    String? id,
    required this.conversationId,
    required this.content,
    required this.isUser,
    DateTime? createdAt,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      content: map['content'] as String,
      isUser: (map['is_user'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'is_user': isUser ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    bool? isUser,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String getTimeString() {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get hasAttachments => metadata?.containsKey('attachments') ?? false;
  
  List<String> get attachments {
    if (!hasAttachments) return [];
    final attachmentsList = metadata!['attachments'] as List?;
    return attachmentsList?.cast<String>() ?? [];
  }

  // Getter for role to maintain compatibility
  String get role => isUser ? 'user' : 'assistant';
}