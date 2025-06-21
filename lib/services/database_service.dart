import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'database_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  final Uuid _uuid = const Uuid();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbFactory = DatabaseHelper.databaseFactory;
    final databasePath = await DatabaseHelper.getDatabasePath('pancake_chat.db');

    return await dbFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDb,
        onConfigure: (db) async {
          // Enable foreign keys
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }


  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chats(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        modelName TEXT NOT NULL,
        systemPrompt TEXT NOT NULL,
        maxHistoryLength INTEGER NOT NULL,
        serverUrl TEXT NOT NULL,
        useStreaming INTEGER NOT NULL
      )
    ''');


    await db.execute('''
      CREATE TABLE messages(
        id TEXT PRIMARY KEY,
        chatId TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (chatId) REFERENCES chats (id) ON DELETE CASCADE
      )
    ''');
  }


  // Chat CRUD operations
  Future<String> createChat({
    required String title,
    required String modelName,
    required String systemPrompt,
    required int maxHistoryLength,
    required String serverUrl,
    required bool useStreaming,
  }) async {
    final db = await database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    await db.insert('chats', {
      'id': id,
      'title': title,
      'createdAt': now,
      'modelName': modelName,
      'systemPrompt': systemPrompt,
      'maxHistoryLength': maxHistoryLength,
      'serverUrl': serverUrl,
      'useStreaming': useStreaming ? 1 : 0,
    });
    
    return id;
  }

  Future<Chat> getChat(String id) async {
    final db = await database;
    final maps = await db.query(
      'chats',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      throw Exception('Chat not found');
    }
    
    return Chat.fromMap(maps.first);
  }

  Future<List<Chat>> getAllChats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chats', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Chat.fromMap(maps[i]));
  }

  Future<void> updateChat(Chat chat) async {
    final db = await database;
    await db.update(
      'chats',
      chat.toMap(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }

  Future<void> deleteChat(String id) async {
    final db = await database;
    await db.delete('chats', where: 'id = ?', whereArgs: [id]);
  }

  // Message CRUD operations
  Future<String> addMessage({
    required String chatId,
    required String role,
    required String content,
  }) async {
    final db = await database;
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    
    await db.insert('messages', {
      'id': id,
      'chatId': chatId,
      'role': role,
      'content': content,
      'timestamp': now,
    });
    
    return id;
  }

  Future<List<Message>> getMessagesForChat(String chatId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp',
    );
    
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  Future<void> deleteMessagesForChat(String chatId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
  }

  // Close the database when done
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
