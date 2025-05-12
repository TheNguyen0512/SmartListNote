// frontend/lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartlist/core/networking/hive/hive_init.dart';
import 'package:smartlist/app.dart';
import 'package:smartlist/features/auth/domain/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await initHive();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider()..refreshAuthState(),
          ),
        ],
        child: const App(),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize: ${e.toString()}')),
        ),
      ),
    );
  }
}
