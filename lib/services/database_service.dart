import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/personality.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../config/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create personalities table
    await db.execute('''
      CREATE TABLE personalities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        system_prompt TEXT NOT NULL,
        avatar_color INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_archived INTEGER DEFAULT 0,
        settings TEXT
      )
    ''');

    // Create conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        personality_id TEXT NOT NULL,
        title TEXT NOT NULL,
        last_message TEXT,
        last_message_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_archived INTEGER DEFAULT 0,
        metadata TEXT,
        FOREIGN KEY (personality_id) REFERENCES personalities(id) ON DELETE CASCADE
      )
    ''');

    // Create messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        content TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        metadata TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create model_cache table
    await db.execute('''
      CREATE TABLE model_cache (
        id TEXT PRIMARY KEY,
        model_name TEXT NOT NULL,
        model_version TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        downloaded_at INTEGER NOT NULL,
        last_used_at INTEGER NOT NULL,
        metadata TEXT
      )
    ''');

    // Create indices
    await db.execute('CREATE INDEX idx_personalities_archived ON personalities(is_archived)');
    await db.execute('CREATE INDEX idx_personalities_updated ON personalities(updated_at)');
    await db.execute('CREATE INDEX idx_conversations_personality ON conversations(personality_id)');
    await db.execute('CREATE INDEX idx_conversations_updated ON conversations(updated_at)');
    await db.execute('CREATE INDEX idx_conversations_archived ON conversations(is_archived)');
    await db.execute('CREATE INDEX idx_messages_conversation ON messages(conversation_id)');
    await db.execute('CREATE INDEX idx_messages_created ON messages(created_at)');
    await db.execute('CREATE INDEX idx_model_cache_name ON model_cache(model_name)');

    // Insert default personalities
    for (final defaultPersonality in AppConstants.defaultPersonalities) {
      final personality = Personality(
        name: defaultPersonality['name'] as String,
        description: defaultPersonality['description'] as String,
        systemPrompt: defaultPersonality['systemPrompt'] as String,
        avatarColor: defaultPersonality['avatarColor'] as int,
      );
      await db.insert('personalities', personality.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations
  }

  // Personality CRUD operations
  Future<String> createPersonality(Personality personality) async {
    final db = await database;
    await db.insert('personalities', personality.toMap());
    return personality.id;
  }

  Future<List<Personality>> getPersonalities({bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'personalities',
      where: includeArchived ? null : 'is_archived = ?',
      whereArgs: includeArchived ? null : [0],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => Personality.fromMap(map)).toList();
  }

  Future<Personality?> getPersonality(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'personalities',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Personality.fromMap(maps.first);
  }

  Future<void> updatePersonality(Personality personality) async {
    final db = await database;
    await db.update(
      'personalities',
      personality.toMap(),
      where: 'id = ?',
      whereArgs: [personality.id],
    );
  }

  Future<void> deletePersonality(String id) async {
    final db = await database;
    await db.delete(
      'personalities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Conversation CRUD operations
  Future<String> createConversation(Conversation conversation) async {
    final db = await database;
    await db.insert('conversations', conversation.toMap());
    return conversation.id;
  }

  Future<List<Conversation>> getConversations(String personalityId, {bool includeArchived = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: includeArchived ? 'personality_id = ?' : 'personality_id = ? AND is_archived = ?',
      whereArgs: includeArchived ? [personalityId] : [personalityId, 0],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => Conversation.fromMap(map)).toList();
  }

  Future<Conversation?> getConversation(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Conversation.fromMap(maps.first);
  }

  Future<void> updateConversation(Conversation conversation) async {
    final db = await database;
    await db.update(
      'conversations',
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }

  Future<void> deleteConversation(String id) async {
    final db = await database;
    await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message CRUD operations
  Future<String> createMessage(Message message) async {
    final db = await database;
    await db.insert('messages', message.toMap());
    
    // Update conversation's last message
    await db.rawUpdate('''
      UPDATE conversations 
      SET last_message = ?, last_message_at = ?, updated_at = ?
      WHERE id = ?
    ''', [
      message.content,
      message.createdAt.millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      message.conversationId,
    ]);
    
    return message.id;
  }

  Future<List<Message>> getMessages(String conversationId, {int? limit, int? offset}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => Message.fromMap(map)).toList();
  }

  Future<void> deleteMessage(String id) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Settings operations
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('conversations');
    await db.delete('personalities');
    await db.delete('settings');
    await db.delete('model_cache');
  }
}