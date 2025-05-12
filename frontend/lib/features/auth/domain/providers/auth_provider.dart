import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
    Future.delayed(const Duration(milliseconds: 100), () {
      _auth.authStateChanges().listen((User? user) {
        _user = user;
        if (kDebugMode) {
          print("Auth state changed: ${user?.uid}, email: ${user?.email}");
        }
        notifyListeners();
      });
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
        if (kDebugMode) {
          print(
            "Registration successful: ${_user?.uid}, email: ${_user?.email}, displayName: ${_user?.displayName}",
          );
        }
      } else {
        throw Exception("User creation failed: user is null");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Registration error: $e");
      }
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
      if (kDebugMode) {
        print(
        "Login successful: ${userCredential.user?.uid}, email: ${userCredential.user?.email}",
      );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login error: $e");
      }
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            _errorMessage = 'invalidEmail';
            break;
          case 'user-not-found':
          case 'wrong-password':
            _errorMessage = 'wrongCredentials';
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
      if (kDebugMode) {
        print(
          "Google sign-in successful: ${userCredential.user?.uid}, email: ${userCredential.user?.email}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Google sign-in error: $e");
      }
      _errorMessage = 'googleSignInFailed';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user logged in");
      }

      // Re-authenticate the user with their current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(newPassword.trim());
      if (kDebugMode) {
        print("Password changed successfully for user: ${user.uid}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Change password error: $e");
      }
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            _errorMessage = 'wrongCredentials';
            break;
          case 'weak-password':
            _errorMessage = 'weakPassword';
            break;
          case 'requires-recent-login':
            _errorMessage = 'requiresRecentLogin';
            break;
          default:
            _errorMessage = 'changePasswordFailed';
        }
      } else {
        _errorMessage = 'changePasswordFailed';
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email.trim());
      if (kDebugMode) {
        print("Password reset email sent to: $email");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Reset password error: $e");
      }
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            _errorMessage = 'invalidEmail';
            break;
          case 'user-not-found':
            _errorMessage = 'userNotFound';
            break;
          default:
            _errorMessage = 'resetPasswordFailed';
        }
      } else {
        _errorMessage = 'resetPasswordFailed';
      }
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

  Future<void> refreshAuthState() async {
    _user = _auth.currentUser;
    notifyListeners();
  }

  void reset() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}