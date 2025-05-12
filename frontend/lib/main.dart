import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartlist/core/networking/hive/hive_init.dart';
import 'app.dart'; // The refactored app widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await initHive(); // Initialize Hive for caching
    runApp(const App());
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize: ${e.toString()}'),
        ),
      ),
    ));
  }
}