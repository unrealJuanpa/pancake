import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseFactory? _databaseFactory;

  static DatabaseFactory get databaseFactory {
    if (_databaseFactory != null) return _databaseFactory!;

    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI for desktop platforms
      sqfliteFfiInit();
      _databaseFactory = databaseFactoryFfi;
    } else {
      // Use the default factory for mobile platforms
      _databaseFactory = databaseFactory;
    }

    return _databaseFactory!;
  }

  static Future<String> getDatabasePath(String name) async {
    String path;
    
    if (Platform.isWindows || Platform.isLinux) {
      // For desktop, use documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      path = join(documentsDir.path, 'pancake', name);
      
      // Create directory if it doesn't exist
      final dir = Directory(dirname(path));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      // For mobile, use the default path
      path = join(await getDatabasesPath(), name);
    }
    
    print('Database path: $path');
    return path;
  }
}
