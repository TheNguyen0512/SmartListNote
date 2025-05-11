import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      print("Auth state changed: ${user?.uid}, email: ${user?.email}");
      notifyListeners();
    });
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = userCredential.user;

      if (_user != null) {
        // Update the user's display name
        await _user!.updateDisplayName(fullName.trim());
        // Refresh the user to ensure the display name is updated
        await _user!.reload();
        _user = _auth.currentUser;
        print(
          "Registration successful: ${_user?.uid}, email: ${_user?.email}, displayName: ${_user?.displayName}",
        );
      } else {
        throw Exception("User creation failed: user is null");
      }
    } catch (e) {
      print("Registration error: $e");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'emailAlreadyInUse';
            break;
          case 'invalid-email':
            _errorMessage = 'invalidEmail';
            break;
          case 'weak-password':
            _errorMessage = 'weakPassword';
            break;
          default:
            _errorMessage = 'authError';
        }
      } else {
        _errorMessage = 'authError';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = userCredential.user;
      print(
        "Login successful: ${userCredential.user?.uid}, email: ${userCredential.user?.email}",
      );
    } catch (e) {
      print("Login error: $e");
      _errorMessage =
          e.toString().contains('invalid-email')
              ? 'invalidEmail'
              : 'wrongCredentials';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _errorMessage = 'googleSignInCancelled';
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      print(
        "Google sign-in successful: ${userCredential.user?.uid}, email: ${userCredential.user?.email}",
      );
    } catch (e) {
      print("Google sign-in error: $e");
      _errorMessage = 'googleSignInFailed';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }

  void reset() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
