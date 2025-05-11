import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../entities/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NoteProvider() {
    loadNotes();
  }

  Timer? _debounce;
  Future<void> loadNotes() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _loadNotes();
    });
  }

  Future<void> _loadNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      _errorMessage = 'userNotLoggedIn';
      _isLoading = false;
      notifyListeners();
      return;
    }

    print("User logged in: ${user.uid}, email: ${user.email}");
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        final token = await user.getIdToken(true); // Force refresh
        if (token == null) {
          print("Failed to get ID token on attempt $attempt");
          _errorMessage = 'failedToGetToken';
          _isLoading = false;
          notifyListeners();
          return;
        }

        print(
          "Full ID Token (first 20 chars): ${token.length > 20 ? token.substring(0, 20) : token}...",
        );

        final response = await http.get(
          Uri.parse('http://10.0.2.2:5102/api/Note'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print(
          "GET /api/Note response: status=${response.statusCode}, body=${response.body}",
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _notes =
              data.map((json) => Note.fromJson(json, id: json['id'])).toList();
          print("Loaded ${_notes.length} notes");
          _isLoading = false;
          notifyListeners();
          return;
        } else if (response.statusCode == 401) {
          print("Unauthorized response on attempt $attempt: ${response.body}");
          _errorMessage = 'userNotLoggedIn';
          if (attempt == 3) {
            _isLoading = false;
            notifyListeners();
            return;
          }
        } else {
          final errorData = jsonDecode(response.body);
          _errorMessage = errorData['error'] ?? 'failedToLoadTasks';
          print(
            "Error response on attempt $attempt: ${_errorMessage}, details: ${errorData['details'] ?? 'No details'}",
          );
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        print("Error in loadNotes on attempt $attempt: $e");
        if (attempt == 3) {
          _errorMessage = 'failedToLoadTasks';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> addNote(Note note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in for addNote");
      _errorMessage = 'userNotLoggedIn';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final noteWithTimestamps = note.copyWith(
        createdAt: DateTime.now().toUtc(), // Convert to UTC
        updatedAt: DateTime.now().toUtc(), // Convert to UTC
      );

      final token = await user.getIdToken(true);
      if (token == null) {
        print("Failed to get ID token for addNote");
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final requestBody = jsonEncode({
        'title': noteWithTimestamps.title,
        'description': noteWithTimestamps.description,
        'isCompleted': noteWithTimestamps.isCompleted,
        'dueDate': noteWithTimestamps.dueDate?.toIso8601String(),
        'priority': noteWithTimestamps.priority.toString().split('.').last,
        'createdAt':
            noteWithTimestamps.createdAt.toIso8601String(), // Non-nullable
        'updatedAt':
            noteWithTimestamps.updatedAt.toIso8601String(), // Non-nullable
      });

      print("Sending POST /api/Note with token: ${token.substring(0, 20)}...");
      print("Request body: $requestBody");

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5102/api/Note'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print(
        "POST /api/Note response: status=${response.statusCode}, body=${response.body}",
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final newNote = Note.fromJson(json, id: json['id']);
        _notes.add(newNote);
        print(
          "Added note to local list: ${newNote.id}, title: ${newNote.title}",
        );
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['error'] ?? 'failedToAddTask';
        print(
          "Error response: ${_errorMessage}, details: ${errorData['details'] ?? 'No details'}",
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error in addNote: $e");
      _errorMessage =
          e.toString().contains('permission-denied')
              ? 'permissionDenied'
              : 'failedToAddTask';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || note.id == null) {
      print("No user logged in or invalid note ID for updateNote");
      _errorMessage = 'userNotLoggedIn';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedNote = note.copyWith(updatedAt: DateTime.now());

      final token = await user.getIdToken(true);
      if (token == null) {
        print("Failed to get ID token for updateNote");
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print(
        "Sending PUT /api/Note/${note.id} with token: ${token.substring(0, 20)}...",
      );
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5102/api/Note/${note.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': updatedNote.id,
          'title': updatedNote.title,
          'description': updatedNote.description,
          'isCompleted': updatedNote.isCompleted,
          'dueDate': updatedNote.dueDate?.toIso8601String(),
          'priority': updatedNote.priority.toString().split('.').last,
          'createdAt': updatedNote.createdAt?.toIso8601String(),
          'updatedAt': updatedNote.updatedAt?.toIso8601String(),
        }),
      );

      print(
        "PUT /api/Note/${note.id} response: status=${response.statusCode}, body=${response.body}",
      );

      if (response.statusCode == 200) {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = updatedNote;
        }
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['error'] ?? 'updateFailed';
        print(
          "Error response: ${_errorMessage}, details: ${errorData['details'] ?? 'No details'}",
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error in updateNote: $e");
      _errorMessage = 'updateFailed';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleNoteStatus(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in for toggleNoteStatus");
      _errorMessage = 'userNotLoggedIn';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final index = _notes.indexWhere((note) => note.id == id);
      if (index == -1) {
        print("Note with ID $id not found in local list");
        _isLoading = false;
        notifyListeners();
        return;
      }

      final token = await user.getIdToken(true);
      if (token == null) {
        print("Failed to get ID token for toggleNoteStatus");
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print(
        "Sending PATCH /api/Note/$id/toggle with token: ${token.substring(0, 20)}...",
      );
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:5102/api/Note/$id/toggle'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
        "PATCH /api/Note/$id/toggle response: status=${response.statusCode}, body=${response.body}",
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final updatedNote = Note.fromJson(json, id: json['id']);
        _notes[index] = updatedNote;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['error'] ?? 'updateFailed';
        print(
          "Error response: ${_errorMessage}, details: ${errorData['details'] ?? 'No details'}",
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error in toggleNoteStatus: $e");
      _errorMessage = 'updateFailed';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in for deleteNote");
      _errorMessage = 'userNotLoggedIn';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final token = await user.getIdToken(true);
      if (token == null) {
        print("Failed to get ID token for deleteNote");
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print(
        "Sending DELETE /api/Note/$id with token: ${token.substring(0, 20)}...",
      );
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:5102/api/Note/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
        "DELETE /api/Note/$id response: status=${response.statusCode}, body=${response.body}",
      );

      if (response.statusCode == 204) {
        _notes.removeWhere((note) => note.id == id);
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['error'] ?? 'deleteFailed';
        print(
          "Error response: ${_errorMessage}, details: ${errorData['details'] ?? 'No details'}",
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error in deleteNote: $e");
      _errorMessage = 'deleteFailed';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
