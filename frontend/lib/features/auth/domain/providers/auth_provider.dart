import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
          print(
              "Auth state changed: ${user?.uid}, email: ${user?.email}, displayName: ${user?.displayName}");
        }
        notifyListeners();
      });
    });
  }

  // Centralized base URL determination
  String _getBaseUrl() {
    if (Platform.isAndroid && !const bool.fromEnvironment('dart.vm.product')) {
      // Running on Android emulator
      return 'http://10.0.2.2:5102/api/auth';
    } else {
      // Running on a physical device or iOS emulator (replace with actual IP)
      return 'http://192.168.1.x:5102/api/auth'; // Replace 192.168.1.x with your computer's IP
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        throw Exception("Email, password, and full name cannot be empty");
      }

      final baseUrl = _getBaseUrl();
      // Retry logic for network issues
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/register'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'email': email.trim(),
                  'password': password.trim(),
                  'fullName': fullName.trim(),
                }),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception(
                      "Registration timed out: Unable to connect to server");
                },
              );

          if (kDebugMode) {
            print("Register response status: ${response.statusCode}");
            print("Register response body: ${response.body}");
          }

          if (response.statusCode == 201) {
            final data = jsonDecode(response.body);
            // The backend creates the user in Firebase Auth and Firestore
            // Sign in the user on the client side to update auth state
            await _auth.signInWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );
            _user = _auth.currentUser;
            if (kDebugMode) {
              print(
                  "Registration successful: ${data['user']['id']}, email: ${data['user']['email']}, displayName: ${data['user']['displayName']}");
            }
            break; // Success, exit retry loop
          } else {
            String errorMessage = 'Failed to register';
            if (response.body.isNotEmpty) {
              try {
                final errorData = jsonDecode(response.body);
                errorMessage = errorData['error']['message'] ?? errorMessage;
              } catch (e) {
                if (kDebugMode) {
                  print("Invalid JSON error body: ${response.body}");
                }
                errorMessage = 'Invalid server response';
              }
            }
            throw Exception(errorMessage);
          }
        } catch (e) {
          if (attempt == 3) {
            if (e.toString().contains('email-already-in-use')) {
              _errorMessage = 'emailAlreadyInUse';
            } else if (e.toString().contains('invalid-email')) {
              _errorMessage = 'invalidEmail';
            } else if (e.toString().contains('weak-password')) {
              _errorMessage = 'weakPassword';
            } else if (e.toString().contains('Timeout')) {
              _errorMessage = 'networkTimeout';
            } else {
              _errorMessage = 'authError';
            }
            if (kDebugMode) {
              print("Final registration error: $e");
            }
            rethrow;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Registration error: $e");
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

      // First, sign in with Firebase to get the ID token
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception("Failed to obtain ID token");
      }

      final baseUrl = _getBaseUrl();
      // Call backend /api/auth/login endpoint with the ID token
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/login'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'email': email.trim(), 'idToken': idToken}),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception("Login timed out: Unable to connect to server");
                },
              );

          if (kDebugMode) {
            print("Login response status: ${response.statusCode}");
            print("Login response body: ${response.body}");
          }

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            _user = userCredential.user;
            if (kDebugMode) {
              print(
                  "Login successful: ${data['user']['id']}, email: ${data['user']['email']}");
            }
            break;
          } else {
            final errorData = jsonDecode(response.body);
            throw Exception(errorData['error']['message'] ?? 'Failed to login');
          }
        } catch (e) {
          if (attempt == 3) {
            if (e.toString().contains('invalid-email')) {
              _errorMessage = 'invalidEmail';
            } else if (e.toString().contains('wrongCredentials')) {
              _errorMessage = 'wrongCredentials';
            } else if (e.toString().contains('Timeout')) {
              _errorMessage = 'networkTimeout';
            } else {
              _errorMessage = 'authError';
            }
            if (kDebugMode) {
              print("Final login error: $e");
            }
            rethrow;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login error: $e");
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
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception("Failed to obtain ID token");
      }

      final baseUrl = _getBaseUrl();
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/google'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'idToken': idToken,
                  'accessToken': googleAuth.accessToken,
                }),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception(
                      "Google sign-in timed out: Unable to connect to server");
                },
              );

          if (kDebugMode) {
            print("Google sign-in response status: ${response.statusCode}");
            print("Google sign-in response body: ${response.body}");
          }

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            _user = userCredential.user;
            if (kDebugMode) {
              print(
                  "Google sign-in successful: ${data['user']['id']}, email: ${data['user']['email']}");
            }
            break;
          } else {
            final errorData = jsonDecode(response.body);
            throw Exception(
                errorData['error']['message'] ?? 'Failed to sign in with Google');
          }
        } catch (e) {
          if (attempt == 3) {
            if (e.toString().contains('invalid-google-token')) {
              _errorMessage = 'googleSignInFailed';
            } else if (e.toString().contains('Timeout')) {
              _errorMessage = 'networkTimeout';
            } else {
              _errorMessage = 'googleSignInFailed';
            }
            if (kDebugMode) {
              print("Final Google sign-in error: $e");
            }
            rethrow;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Google sign-in error: $e");
      }
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

      final baseUrl = _getBaseUrl();
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/change-password'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'userId': user.uid,
                  'currentPassword': currentPassword.trim(),
                  'newPassword': newPassword.trim(),
                }),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception(
                      "Password change timed out: Unable to connect to server");
                },
              );

          if (kDebugMode) {
            print("Change password response status: ${response.statusCode}");
            print("Change password response body: ${response.body}");
          }

          if (response.statusCode == 200) {
            await user.updatePassword(newPassword.trim());
            if (kDebugMode) {
              print("Password changed successfully for user: ${user.uid}");
            }
            break;
          } else {
            final errorData = jsonDecode(response.body);
            throw Exception(
                errorData['error']['message'] ?? 'Failed to change password');
          }
        } catch (e) {
          if (attempt == 3) {
            if (e.toString().contains('wrongCredentials')) {
              _errorMessage = 'wrongCredentials';
            } else if (e.toString().contains('weak-password')) {
              _errorMessage = 'weakPassword';
            } else if (e.toString().contains('requires-recent-login')) {
              _errorMessage = 'requiresRecentLogin';
            } else if (e.toString().contains('Timeout')) {
              _errorMessage = 'networkTimeout';
            } else {
              _errorMessage = 'changePasswordFailed';
            }
            if (kDebugMode) {
              print("Final change password error: $e");
            }
            rethrow;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Change password error: $e");
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

      final baseUrl = _getBaseUrl();
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/reset-password'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'email': email.trim()}),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception(
                      "Password reset timed out: Unable to connect to server");
                },
              );

          if (kDebugMode) {
            print("Reset password response status: ${response.statusCode}");
            print("Reset password response body: ${response.body}");
          }

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print("Password reset email sent to: $email");
            }
            break;
          } else {
            final errorData = jsonDecode(response.body);
            throw Exception(
                errorData['error']['message'] ??
                    'Failed to send password reset email');
          }
        } catch (e) {
          if (attempt == 3) {
            if (e.toString().contains('invalid-email')) {
              _errorMessage = 'invalidEmail';
            } else if (e.toString().contains('user-not-found')) {
              _errorMessage = 'userNotFound';
            } else if (e.toString().contains('Timeout')) {
              _errorMessage = 'networkTimeout';
            } else {
              _errorMessage = 'resetPasswordFailed';
            }
            if (kDebugMode) {
              print("Final reset password error: $e");
            }
            rethrow;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Reset password error: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print("No user logged in, proceeding with local cleanup");
        }
        _user = null;
        return;
      }

      final baseUrl = _getBaseUrl();
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/logout'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'userId': user.uid}),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception(
                      "Logout timed out: Unable to connect to server");
                },
              );

          if (kDebugMode) {
            print("Logout response status: ${response.statusCode}");
            print("Logout response body: ${response.body}");
          }

          if (response.statusCode == 200) {
            if (kDebugMode) {
              print("Backend logout successful for user: ${user.uid}");
            }
            break;
          } else {
            final errorData = jsonDecode(response.body);
            throw Exception(
                errorData['error']['message'] ?? 'Failed to logout');
          }
        } catch (e) {
          if (attempt == 3) {
            if (e.toString().contains('Timeout')) {
              _errorMessage = 'networkTimeout';
            } else {
              _errorMessage = 'logoutFailed';
            }
            // Continue with client-side logout even if backend fails
            if (kDebugMode) {
              print(
                  "Backend logout failed after all attempts, proceeding with client-side logout");
            }
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      // Perform client-side sign-out
      try {
        await _auth.signOut();
        await _googleSignIn.signOut();
        _user = null;
        if (kDebugMode) {
          print("User logged out successfully");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Client-side logout error: $e");
        }
        _errorMessage = 'logoutFailed';
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Logout error: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAuthState() async {
    try {
      _user = _auth.currentUser;
      if (_user != null) {
        await _user!.reload();
        _user = _auth.currentUser;
        if (kDebugMode) {
          print("Auth state refreshed: ${_user?.uid}, email: ${_user?.email}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing auth state: $e");
      }
      _errorMessage = 'authError';
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}