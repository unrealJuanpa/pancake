class Chat {
  final String id;
  final String title;
  final DateTime createdAt;
  final String modelName;
  final String systemPrompt;
  final int maxHistoryLength;
  final String serverUrl;
  final bool useStreaming;

  Chat({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.modelName,
    required this.systemPrompt,
    required this.maxHistoryLength,
    required this.serverUrl,
    required this.useStreaming,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.parse(map['createdAt']),
      modelName: map['modelName'],
      systemPrompt: map['systemPrompt'],
      maxHistoryLength: map['maxHistoryLength'],
      serverUrl: map['serverUrl'],
      useStreaming: map['useStreaming'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'modelName': modelName,
      'systemPrompt': systemPrompt,
      'maxHistoryLength': maxHistoryLength,
      'serverUrl': serverUrl,
      'useStreaming': useStreaming ? 1 : 0,
    };
  }

  Chat copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? modelName,
    String? systemPrompt,
    int? maxHistoryLength,
    String? serverUrl,
    bool? useStreaming,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      modelName: modelName ?? this.modelName,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      maxHistoryLength: maxHistoryLength ?? this.maxHistoryLength,
      serverUrl: serverUrl ?? this.serverUrl,
      useStreaming: useStreaming ?? this.useStreaming,
    );
  }
}
