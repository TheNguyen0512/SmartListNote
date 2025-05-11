import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  String? _errorMessage;
  bool _isLoading = false;
  Timer? _debounce;
  Timer? _toggleDebounce; // Add a debounce timer for toggle

  List<Note> get notes => _notes;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _loadNotes();
    });
  }

  Future<void> _loadNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
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

        final token = await user.getIdToken(true);
        if (token == null) {
          print("Failed to get ID token on attempt $attempt");
          _errorMessage = 'failedToGetToken';
          _isLoading = false;
          notifyListeners();
          return;
        }

        print("Full ID Token: $token"); // Log the full token for debugging

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
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5102/api/Note'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(note.toJson()),
      );

      if (response.statusCode == 201) {
        final newNote = Note.fromJson(
          jsonDecode(response.body),
          id: jsonDecode(response.body)['id'],
        );
        _notes.add(newNote);
        notifyListeners();
      } else {
        _errorMessage = 'failedToAddTask';
      }
    } catch (e) {
      _errorMessage = 'failedToAddTask';
      print("Error adding note: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
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
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5102/api/Note/${note.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(note.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = note.copyWith(updatedAt: DateTime.now());
          notifyListeners();
        }
      } else {
        _errorMessage = 'failedToUpdateTask';
      }
    } catch (e) {
      _errorMessage = 'failedToUpdateTask';
      print("Error updating note: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'userNotLoggedIn';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error message
      notifyListeners();

      final token = await user.getIdToken(true);
      if (token == null) {
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print("Full ID Token for delete: $token"); // Log the token for debugging

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
        // Backend returns 204 No Content on successful deletion
        _notes.removeWhere((note) => note.id == id);
        _errorMessage = null; // Ensure error message is cleared on success
        print("Successfully deleted note $id");
      } else {
        _errorMessage = 'deleteFailed';
        print(
          "Failed to delete note $id: ${response.statusCode}, ${response.body}",
        );
      }
    } catch (e) {
      _errorMessage = 'deleteFailed';
      print("Error deleting note $id: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleNoteStatus(String id) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final note = _notes[index];
      final updatedNote = note.copyWith(
        isCompleted: !note.isCompleted,
        updatedAt: DateTime.now(),
      );
      _notes[index] = updatedNote;
      notifyListeners();

      // Debounce the backend update
      if (_toggleDebounce?.isActive ?? false) _toggleDebounce?.cancel();
      _toggleDebounce = Timer(const Duration(milliseconds: 500), () {
        _updateNoteInBackground(updatedNote);
      });
    }
  }

  Future<void> _updateNoteInBackground(Note note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final token = await user.getIdToken(true);
      if (token == null) return;

      print(
        "Full ID Token for update: $token",
      ); // Log the full token for debugging

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5102/api/Note/${note.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(note.toJson()),
      );

      if (response.statusCode != 200) {
        print(
          "Background update failed for note ${note.id}: ${response.statusCode}, ${response.body}",
        );
      }
    } catch (e) {
      print("Background update error for note ${note.id}: $e");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _toggleDebounce?.cancel(); // Clean up toggle debounce
    super.dispose();
  }
}
