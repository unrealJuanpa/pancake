import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:convert/convert.dart' show LineSplitter, utf8;
import '../models/chat.dart';
import '../models/message.dart';

class OllamaService {
  final String baseUrl;
  final Duration timeout;

  OllamaService({
    String? serverUrl,
    this.timeout = const Duration(seconds: 60),
  }) : baseUrl = _normalizeUrl(serverUrl ?? 'http://localhost:11434');

  static String _normalizeUrl(String url) {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    return url;
  }

  // Get list of available models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = (data['models'] as List)
            .map((model) => model['name'].toString())
            .toList();
        return models;
      } else {
        throw Exception('Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to Ollama: $e');
    }
  }

  // Generate a response using the chat API
  Future<String> generateResponse({
    required Chat chat,
    required List<Message> messages,
    required Function(String) onChunk,
    required Function() onDone,
  }) async {
    if (chat.useStreaming) {
      return _generateStreamingResponse(
        chat: chat,
        messages: messages,
        onChunk: onChunk,
        onDone: onDone,
      );
    } else {
      return _generateNonStreamingResponse(
        chat: chat,
        messages: messages,
      );
    }
  }

  Future<String> _generateNonStreamingResponse({
    required Chat chat,
    required List<Message> messages,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': chat.modelName,
          'messages': _formatMessagesForApi(chat, messages),
          'stream': false,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message']['content'] ?? '';
      } else {
        throw Exception('Failed to generate response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating response: $e');
    }
  }

  Future<String> _generateStreamingResponse({
    required Chat chat,
    required List<Message> messages,
    required Function(String) onChunk,
    required Function() onDone,
  }) async {
    final completer = Completer<String>();
    final buffer = StringBuffer();
    final client = http.Client();
    
    try {
      final url = Uri.parse('$baseUrl/api/chat');
      print('Sending streaming request to: $url');
      
      // Format messages for the chat API
      final formattedMessages = _formatMessagesForApi(chat, messages);
      
      // Create the request
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = json.encode({
          'model': chat.modelName,
          'messages': formattedMessages,
          'stream': true,
        });
      
      // Set up a timer to handle timeouts
      final timeoutTimer = Timer(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          completer.completeError('Request timed out after 60 seconds');
          client.close();
        }
      });
      
      // Send the request and process the stream
      final streamedResponse = await client.send(request);
      
      if (streamedResponse.statusCode != 200) {
        final error = await streamedResponse.stream.bytesToString();
        throw Exception('Failed to generate response: ${streamedResponse.statusCode} - $error');
      }
      
      // Process the stream
      await for (var chunk in const LineSplitter().bind(streamedResponse.stream.asBroadcastStream().cast<List<int>>().transform(utf8.decoder))) {
        if (chunk.trim().isEmpty) continue;
        
        try {
          // Cancel the timeout timer on first successful chunk
          timeoutTimer.cancel();
          
          final parsed = json.decode(chunk);
          
          // Handle both response formats for backward compatibility
          String content = '';
          if (parsed['message'] != null && parsed['message']['content'] != null) {
            content = parsed['message']['content'];
          } else if (parsed['response'] != null) {
            content = parsed['response'];
          }
          
          if (content.isNotEmpty) {
            buffer.write(content);
            onChunk(content);
          }
          
          if (parsed['done'] == true) {
            if (!completer.isCompleted) {
              completer.complete(buffer.toString());
              onDone();
            }
            break;
          }
        } catch (e) {
          print('Error processing response chunk: $e');
          print('Problematic chunk: $chunk');
          if (!completer.isCompleted) {
            completer.completeError('Error processing response: $e');
          }
          break;
        }
      }
      
      if (!completer.isCompleted) {
        completer.complete(buffer.toString());
      }
      
      return await completer.future;
    } catch (e) {
      print('Error in streaming request: $e');
      if (!completer.isCompleted) {
        completer.completeError('Failed to generate response: $e');
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  List<Map<String, dynamic>> _formatMessagesForApi(
    Chat chat,
    List<Message> messages,
  ) {
    // The first message should be the system prompt if it exists
    final formattedMessages = <Map<String, dynamic>>[];

    // Add system prompt as the first message if it exists
    if (chat.systemPrompt.isNotEmpty) {
      formattedMessages.add({
        'role': 'system',
        'content': chat.systemPrompt,
      });
    }

    // Add user and assistant messages
    for (final message in messages) {
      formattedMessages.add({
        'role': message.role == MessageRole.assistant ? 'assistant' : 'user',
        'content': message.content,
      });
    }

    return formattedMessages;
  }

  /// Formats messages into a single prompt string for the /api/generate endpoint
  String _formatPromptForGeneration(Chat chat, List<Message> messages) {
    final buffer = StringBuffer();
    
    // Add system prompt if it exists
    if (chat.systemPrompt.isNotEmpty) {
      buffer.writeln(chat.systemPrompt);
      buffer.writeln();
    }
    
    // Add conversation history
    for (final message in messages) {
      if (message.role == MessageRole.user) {
        buffer.writeln('User: ${message.content}');
      } else if (message.role == MessageRole.assistant) {
        buffer.writeln('Assistant: ${message.content}');
      } else if (message.role == MessageRole.system) {
        buffer.writeln('System: ${message.content}');
      }
      buffer.writeln();
    }
    
    // Add the assistant's response prefix
    buffer.write('Assistant:');
    
    return buffer.toString();
  }
}
