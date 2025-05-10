import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartlist/features/auth/domain/entities/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _token != null;

  static const String _baseUrl = 'http://10.0.2.2:5102/api/auth'; // For Android emulator
  // For physical device, use your machine's IP, e.g., 'http://192.168.1.100:5102/api/auth'
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      await _fetchUser();
    }
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Future<void> _fetchUser() async {
    if (_token == null) return;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/${_user?.id}'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _user = UserModel.fromJson(json);
      } else {
        await _clearToken();
        _user = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
      await _clearToken();
      _user = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Sending login request to: $_baseUrl/login');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final idToken = await credential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to obtain ID token');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'idToken': idToken}),
      );

      print('Login response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _user = UserModel.fromJson(json['user']);
        await _saveToken(json['token']);
      } else {
        _errorMessage = _mapHttpError(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e is firebase_auth.FirebaseAuthException ? _mapFirebaseAuthError(e) : 'authError';
      if (kDebugMode) {
        print('Login error: $e');
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Starting Google Sign-In');
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Replace with Web Client ID from google-services.json (client_type: 3)
        serverClientId: '815920931427-glq3neave4606sojtgb4hhf13jacnc4k.apps.googleusercontent.com',
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        _isLoading = false;
        _errorMessage = 'googleSignInCancelled';
        notifyListeners();
        return;
      }

      print('Google Sign-In successful, fetching authentication');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Google auth tokens: idToken=${googleAuth.idToken?.substring(0, 20)}..., accessToken=${googleAuth.accessToken?.substring(0, 20)}...');

      print('Sending Google Sign-In request to: $_baseUrl/google');
      final response = await http.post(
        Uri.parse('$_baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken,
        }),
      );

      print('Google Sign-In response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _user = UserModel.fromJson(json['user']);
        await _saveToken(json['token']);
      } else {
        _errorMessage = _mapHttpError(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e is PlatformException && e.code == 'sign_in_failed' ? 'googleSignInFailed' : 'authError';
      if (kDebugMode) {
        print('Google Sign-In error: $e');
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Sending register request to: $_baseUrl/register');
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
          'fullName': fullName.trim(),
        }),
      );

      print('Register response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        _user = UserModel.fromJson(json['user']);
        await _saveToken(json['token']);
      } else {
        _errorMessage = _mapHttpError(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'authError';
      print('Register error: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Sending logout request to: $_baseUrl/logout');
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {'Authorization': 'Bearer $_token'},
        body: jsonEncode({'userId': _user?.id}),
      );

      await GoogleSignIn().signOut();
      await _firebaseAuth.signOut();
      await _clearToken();
      _user = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'logoutFailed';
      print('Logout error: $e');
      notifyListeners();
      rethrow;
    }
  }

  String _mapHttpError(http.Response response) {
    final json = jsonDecode(response.body);
    final error = json['error']?['message'] ?? 'authError';
    switch (error) {
      case 'invalid-email':
        return 'invalidEmail';
      case 'wrongCredentials':
        return 'wrongCredentials';
      case 'email-already-in-use':
        return 'emailInUse';
      case 'weak-password':
        return 'weakPassword';
      case 'network-request-failed':
        return 'networkError';
      case 'too-many-requests':
        return 'tooManyRequests';
      case 'invalid-google-token':
        return 'invalidGoogleToken';
      case 'invalid-audience':
        return 'invalidAudience';
      default:
        return 'authError';
    }
  }

  String _mapFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'invalidEmail';
      case 'user-not-found':
      case 'wrong-password':
        return 'wrongCredentials';
      case 'email-already-in-use':
        return 'emailInUse';
      case 'weak-password':
        return 'weakPassword';
      case 'too-many-requests':
        return 'tooManyRequests';
      default:
        return 'authError';
    }
  }
}