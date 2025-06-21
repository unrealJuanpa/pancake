import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
      child: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.currentChat == null) {
            return const Center(
              child: Text('Select a chat to view settings'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Chat Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Server URL
              TextField(
                controller: provider.serverUrlController,
                decoration: const InputDecoration(
                  labelText: 'Ollama Server URL',
                  hintText: 'http://localhost:11434',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  provider.updateServerUrl(value);
                  provider.updateCurrentChat();
                },
              ),
              const SizedBox(height: 16),

              // Model selection
              DropdownButtonFormField<String>(
                value: provider.selectedModel,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                items: provider.availableModels.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model),
                  );
                }).toList(),
                onChanged: (value) {
                  provider.updateModel(value);
                  provider.updateCurrentChat();
                },
              ),
              const SizedBox(height: 16),

              // System prompt
              const Text(
                'System Prompt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: provider.systemPromptController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'You are a helpful assistant...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => provider.updateCurrentChat(),
              ),
              const SizedBox(height: 16),

              // Max history length
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Context Length: ${provider.maxHistoryLength} messages',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: provider.maxHistoryLength.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: provider.maxHistoryLength.toString(),
                    onChanged: (value) {
                      provider.updateMaxHistory(value.toInt());
                      provider.updateCurrentChat();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Streaming toggle
              SwitchListTile(
                title: const Text('Stream Responses'),
                subtitle: const Text('Enable streaming for faster responses'),
                value: provider.useStreaming,
                onChanged: (value) {
                  provider.toggleStreaming(value);
                  provider.updateCurrentChat();
                },
              ),
              const SizedBox(height: 16),

              // Save button
              ElevatedButton(
                onPressed: provider.isLoading ? null : provider.updateCurrentChat,
                child: const Text('Save Settings'),
              ),
            ],
          );
        },
      ),
    );
  }
}
