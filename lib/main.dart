import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pancake/providers/chat_provider.dart';
import 'package:pancake/widgets/chat_list.dart';
import 'package:pancake/widgets/chat_view.dart';
import 'package:pancake/widgets/settings_panel.dart';
import 'package:pancake/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop platforms
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }
  
  // Initialize database factory
  final dbFactory = DatabaseHelper.databaseFactory;
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: const PancakeApp(),
    ),
  );
}

class PancakeApp extends StatelessWidget {
  const PancakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pancake Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pancake Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          // Chat list
          const ChatList(),
          
          // Chat view
          const Expanded(
            child: ChatView(),
          ),
          
          // Settings panel
          if (_showSettings) const SettingsPanel(),
        ],
      ),
    );
  }
}
