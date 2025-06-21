import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.currentChat == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Welcome to Pancake Chat',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a chat or create a new one to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Messages
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.currentMessages.isEmpty
                      ? const Center(
                          child: Text('Start a new conversation'),
                        )
                      : ListView.builder(
                          controller: provider.scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.currentMessages.length,
                          itemBuilder: (context, index) {
                            final message = provider.currentMessages[index];
                            return _buildMessageBubble(context, message);
                          },
                        ),
            ),
            
            // Input area
            _buildInputArea(context, provider),
          ],
        );
      },
    );
  }
  
  Widget _buildMessageBubble(BuildContext context, Message message) {
    final isUser = message.role == MessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            margin: const EdgeInsets.only(right: 12, top: 4),
            child: CircleAvatar(
              backgroundColor: isUser
                  ? colorScheme.primary
                  : colorScheme.secondary,
              child: Icon(
                isUser ? Icons.person : Icons.smart_toy,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with role and time
                Row(
                  children: [
                    Text(
                      isUser ? 'You' : 'Assistant',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUser
                            ? colorScheme.primary
                            : colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(message.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Message content
                if (message.role == MessageRole.assistant)
                  MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyLarge,
                      code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        backgroundColor: colorScheme.surfaceVariant,
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                else
                  Text(message.content),
                
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputArea(BuildContext context, ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Message input
          Expanded(
            child: TextField(
              controller: provider.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: provider.isGenerating ? null : provider.sendMessage,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => provider.sendMessage(),
              enabled: !provider.isGenerating,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
