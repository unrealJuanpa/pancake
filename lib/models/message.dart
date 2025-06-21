enum MessageRole { system, user, assistant }

class Message {
  final String id;
  final String chatId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    MessageRole role;
    switch (map['role']) {
      case 'system':
        role = MessageRole.system;
        break;
      case 'assistant':
        role = MessageRole.assistant;
        break;
      case 'user':
      default:
        role = MessageRole.user;
    }
    
    return Message(
      id: map['id'],
      chatId: map['chatId'],
      role: role,
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'role': role.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
