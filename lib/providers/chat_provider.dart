import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/database_service.dart';
import '../services/ollama_service.dart';

class ChatProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  late OllamaService _ollamaService;
  
  List<Chat> _chats = [];
  Chat? _currentChat;
  List<Message> _currentMessages = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String _error = '';
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _systemPromptController = TextEditingController();
  final TextEditingController _serverUrlController = TextEditingController();
  
  // Getters
  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  List<Message> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String get error => _error;
  TextEditingController get messageController => _messageController;
  ScrollController get scrollController => _scrollController;
  TextEditingController get systemPromptController => _systemPromptController;
  TextEditingController get serverUrlController => _serverUrlController;
  
  // Default values
  String _selectedModel = 'llama3';
  int _maxHistoryLength = 10;
  bool _useStreaming = true;
  
  String get selectedModel => _selectedModel;
  int get maxHistoryLength => _maxHistoryLength;
  bool get useStreaming => _useStreaming;
  
  // Available models
  List<String> _availableModels = [];
  List<String> get availableModels => _availableModels;
  
  ChatProvider() {
    _systemPromptController.text = '';
    _init();
  }
  
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Initialize database and load chats
      await _loadChats();
      
      // Initialize Ollama service with default URL
      _serverUrlController.text = 'http://localhost:11434';
      _updateOllamaService();
      
      // Load available models
      await _loadAvailableModels();
      
      // Ensure system prompt is empty by default
      _systemPromptController.clear();
    } catch (e) {
      _error = 'Error initializing: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _updateOllamaService() {
    _ollamaService = OllamaService(serverUrl: _serverUrlController.text);
  }
  
  Future<void> _loadChats() async {
    try {
      _chats = await _db.getAllChats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load chats: $e';
    }
  }
  
  Future<void> _loadAvailableModels() async {
    try {
      _availableModels = await _ollamaService.getAvailableModels();
      if (_availableModels.isNotEmpty && !_availableModels.contains(_selectedModel)) {
        _selectedModel = _availableModels.first;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load models: $e';
    }
  }
  
  Future<void> createNewChat({String? title}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final chatId = await _db.createChat(
        title: title ?? 'New Chat',
        modelName: _selectedModel,
        systemPrompt: _systemPromptController.text,
        maxHistoryLength: _maxHistoryLength,
        serverUrl: _serverUrlController.text,
        useStreaming: _useStreaming,
      );
      

      await _loadChats();
      await loadChat(chatId);
    } catch (e) {
      _error = 'Failed to create chat: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> showNewChatDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Chat name',
            hintText: 'Enter a name for this chat',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).pop(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: nameController,
            builder: (context, value, child) {
              final isEnabled = value.text.trim().isNotEmpty;
              return ElevatedButton(
                onPressed: isEnabled 
                    ? () => Navigator.of(context).pop(value.text.trim())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnabled 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                  foregroundColor: isEnabled 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                ),
                child: const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
    
    if (result != null) {
      await createNewChat(title: result);
    }
  }
  
  Future<void> loadChat(String chatId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _currentChat = await _db.getChat(chatId);
      _currentMessages = await _db.getMessagesForChat(chatId);
      
      // Update UI controllers
      _systemPromptController.text = _currentChat!.systemPrompt;
      _serverUrlController.text = _currentChat!.serverUrl;
      _selectedModel = _currentChat!.modelName;
      _maxHistoryLength = _currentChat!.maxHistoryLength;
      _useStreaming = _currentChat!.useStreaming;
      
      // Update service with current URL
      _updateOllamaService();
      
      _error = '';
    } catch (e) {
      _error = 'Failed to load chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateCurrentChat() async {
    if (_currentChat == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final updatedChat = _currentChat!.copyWith(
        modelName: _selectedModel,
        systemPrompt: _systemPromptController.text,
        maxHistoryLength: _maxHistoryLength,
        serverUrl: _serverUrlController.text,
        useStreaming: _useStreaming,
      );
      
      await _db.updateChat(updatedChat);
      _currentChat = updatedChat;
      await _loadChats();
    } catch (e) {
      _error = 'Failed to update chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteChat(String chatId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _db.deleteChat(chatId);
      
      if (_currentChat?.id == chatId) {
        _currentChat = null;
        _currentMessages = [];
      }
      
      await _loadChats();
    } catch (e) {
      _error = 'Failed to delete chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentChat == null) return;
    
    final userMessage = _messageController.text.trim();
    _messageController.clear();
    
    try {
      _isGenerating = true;
      notifyListeners();
      
      // Add user message to chat
      final userMessageId = await _db.addMessage(
        chatId: _currentChat!.id,
        role: 'user',
        content: userMessage,
      );
      
      // Add assistant's loading message
      final loadingMessageId = await _db.addMessage(
        chatId: _currentChat!.id,
        role: 'assistant',
        content: 'Thinking...',
      );
      
      // Reload messages to get the latest
      _currentMessages = await _db.getMessagesForChat(_currentChat!.id);
      notifyListeners();
      _scrollToBottom();
      
      // Get the assistant's message index
      final assistantMessageIndex = _currentMessages.indexWhere(
        (m) => m.id == loadingMessageId,
      );
      
      if (assistantMessageIndex == -1) {
        throw Exception('Failed to find assistant message');
      }
      
      // Get recent messages for context (respecting maxHistoryLength)
      final recentMessages = _currentMessages.length <= _currentChat!.maxHistoryLength
          ? _currentMessages
          : _currentMessages.sublist(_currentMessages.length - _currentChat!.maxHistoryLength);
      
      // Generate response
      String fullResponse = '';
      bool isFirstChunk = true;
      
      await _ollamaService.generateResponse(
        chat: _currentChat!,
        messages: recentMessages,
        onChunk: (chunk) {
          if (isFirstChunk) {
            // Replace the loading message with the first chunk
            fullResponse = chunk;
            isFirstChunk = false;
          } else {
            fullResponse += chunk;
          }
          
          _currentMessages[assistantMessageIndex] = _currentMessages[assistantMessageIndex].copyWith(
            content: fullResponse,
          );
          notifyListeners();
          _scrollToBottom();
        },
        onDone: () async {
          // Update the message in the database with the full response
          await _db.addMessage(
            chatId: _currentChat!.id,
            role: 'assistant',
            content: fullResponse.isEmpty ? 'No response generated' : fullResponse,
          );
          _isGenerating = false;
          notifyListeners();
        },
      );
      
      _error = '';
    } catch (e) {
      _error = 'Error sending message: $e';
      _isGenerating = false;
      notifyListeners();
      
      // Update the loading message with the error
      if (_currentChat != null) {
        final messages = await _db.getMessagesForChat(_currentChat!.id);
        final lastMessage = messages.lastWhere(
          (m) => m.role == 'assistant' && m.content == 'Thinking...',
          orElse: () => Message(
            id: '',
            chatId: _currentChat!.id,
            role: MessageRole.assistant,
            content: 'Thinking...',
            timestamp: DateTime.now(),
          ),
        );
        
        if (lastMessage.id.isNotEmpty) {
          await _db.addMessage(
            chatId: _currentChat!.id,
            role: 'assistant',
            content: 'Sorry, I encountered an error. Please try again.',
          );
          _currentMessages = await _db.getMessagesForChat(_currentChat!.id);
          notifyListeners();
        }
      }
    }
  }
  
  void updateModel(String? model) {
    if (model != null) {
      _selectedModel = model;
      notifyListeners();
    }
  }
  
  void updateMaxHistory(int value) {
    _maxHistoryLength = value;
    notifyListeners();
  }
  
  void toggleStreaming(bool value) {
    _useStreaming = value;
    notifyListeners();
  }
  
  void updateServerUrl(String url) {
    _serverUrlController.text = url;
    _updateOllamaService();
    _loadAvailableModels();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _systemPromptController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }
}
