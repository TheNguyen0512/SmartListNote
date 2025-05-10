import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart'; // <- The refactored app widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    runApp(const App());
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize Firebase: ${e.toString()}'),
        ),
      ),
    ));
  }
}
