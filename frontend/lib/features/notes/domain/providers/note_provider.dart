import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smartlist/core/networking/hive/hive_service.dart';
import 'package:smartlist/core/networking/hive/models/operation.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  String? _errorMessage;
  bool _isLoading = false;
  String? _syncStatus;
  Timer? _debounce;
  Timer? _toggleDebounce;
  final HiveService _hiveService = HiveService();

  List<Note> get notes => _notes;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get syncStatus => _syncStatus;

  NoteProvider() {
    loadNotes();
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:5102/api/Note'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      if (kDebugMode) {
        print('Connectivity check failed: $e');
      }
      return false;
    }
  }

  Future<void> loadNotes() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
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

    try {
      _notes = await _hiveService.loadNotes();
      if (kDebugMode) {
        print('Loaded ${_notes.length} notes from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading notes from Hive: $e');
      }
      _errorMessage = 'failedToLoadNotes';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = false;
    notifyListeners();

    if (!await _isOnline()) {
      if (kDebugMode) {
        print('Offline: Using cached notes');
      }
      _errorMessage = null;
      return;
    }

    for (int attempt = 1; attempt <= 3; attempt++) {
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

        final response = await http.get(
          Uri.parse('http://10.0.2.2:5102/api/Note'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          _notes = data.map((json) => Note.fromJson(json, id: json['id'])).toList();
          await _hiveService.saveNotes(_notes);
          await _syncOperations();
          _isLoading = false;
          notifyListeners();
          return;
        } else if (response.statusCode == 401) {
          _errorMessage = 'userNotLoggedIn';
          if (attempt == 3) {
            _isLoading = false;
            notifyListeners();
            return;
          }
        } else {
          _errorMessage = 'failedToLoadNotes';
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        if (attempt == 3) {
          _errorMessage = 'failedToLoadNotes';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _syncOperations() async {
    if (!await _isOnline()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await user.getIdToken(true);
    if (token == null) return;

    final operations = await _hiveService.getOperations();
    if (operations.isEmpty) return;

    final indicesToDelete = <int>[];
    int initialOperationCount = operations.length;

    for (var i = 0; i < operations.length; i++) {
      final operation = operations[i];
      if (operation.synced) {
        if (kDebugMode) {
          print('Skipping already synced operation: ${operation.type}, ID: ${operation.note?.id ?? operation.id}');
        }
        indicesToDelete.add(i);
        continue;
      }

      try {
        if (kDebugMode) {
          print('Syncing operation: ${operation.type}, ID: ${operation.note?.id ?? operation.id}');
        }
        switch (operation.type) {
          case OperationType.add:
            if (operation.note != null) {
              // Kiểm tra xem ghi chú đã được đồng bộ chưa
              final existingNote = _notes.firstWhere(
                (n) => n.id == operation.note!.id,
                orElse: () => operation.note!,
              );
              if (existingNote.id != operation.note!.id) {
                if (kDebugMode) {
                  print('Skipping already synced note with temp ID: ${operation.note!.id}, new ID: ${existingNote.id}');
                }
                indicesToDelete.add(i);
                continue;
              }

              final response = await http.post(
                Uri.parse('http://10.0.2.2:5102/api/Note'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode(operation.note!.toJson()),
              );
              if (response.statusCode == 201) {
                final newNote = Note.fromJson(jsonDecode(response.body), id: jsonDecode(response.body)['id']);
                final index = _notes.indexWhere((n) => n.id == operation.note!.id);
                if (index != -1) {
                  _notes[index] = newNote;
                } else {
                  _notes.add(newNote);
                }
                indicesToDelete.add(i);
                if (kDebugMode) {
                  print('Successfully synced add operation, new ID: ${newNote.id}');
                }
              }
            }
            break;
          case OperationType.update:
            if (operation.note != null) {
              final response = await http.put(
                Uri.parse('http://10.0.2.2:5102/api/Note/${operation.note!.id}'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode(operation.note!.toJson()),
              );
              if (response.statusCode == 200) {
                final index = _notes.indexWhere((n) => n.id == operation.note!.id);
                if (index != -1) {
                  _notes[index] = operation.note!.copyWith(updatedAt: DateTime.now());
                }
                indicesToDelete.add(i);
                if (kDebugMode) {
                  print('Successfully synced update operation for ID: ${operation.note!.id}');
                }
              }
            }
            break;
          case OperationType.delete:
            if (operation.id != null) {
              final response = await http.delete(
                Uri.parse('http://10.0.2.2:5102/api/Note/${operation.id}'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
              if (response.statusCode == 204) {
                _notes.removeWhere((note) => note.id == operation.id);
                indicesToDelete.add(i);
                if (kDebugMode) {
                  print('Successfully synced delete operation for ID: ${operation.id}');
                }
              }
            }
            break;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error syncing operation at index $i: $e');
        }
      }
    }

    // Xóa các thao tác đã xử lý
    try {
      for (var index in indicesToDelete.reversed.toList()) {
        final success = await _hiveService.deleteOperation(index);
        if (!success) {
          if (kDebugMode) {
            print('Failed to delete operation at index $index, marking for retry');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during operation deletion: $e');
      }
    }

    // Lưu danh sách ghi chú
    try {
      await _hiveService.saveNotes(_notes);
      if (kDebugMode) {
        print('Saved ${_notes.length} notes to Hive after sync');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notes during sync: $e');
      }
    }

    // Cập nhật trạng thái đồng bộ
    final remainingOperations = await _hiveService.getOperations();
    if (initialOperationCount != remainingOperations.length) {
      _syncStatus = 'offlineSynced';
    } else {
      _syncStatus = null;
    }
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final newNote = note.copyWith(id: tempId, createdAt: DateTime.now());

    try {
      _notes.add(newNote);
      await _hiveService.saveNotes(_notes);
      notifyListeners();

      if (!await _isOnline()) {
        await _hiveService.addOperation(Operation(
          type: OperationType.add,
          note: newNote,
          timestamp: DateTime.now(),
          synced: false,
        ));
        _syncStatus = 'savedOffline';
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'userNotLoggedIn';
        notifyListeners();
        return;
      }

      final token = await user.getIdToken(true);
      if (token == null) {
        _errorMessage = 'failedToGetToken';
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5102/api/Note'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newNote.toJson()),
      );

      if (response.statusCode == 201) {
        final serverNote = Note.fromJson(jsonDecode(response.body), id: jsonDecode(response.body)['id']);
        final index = _notes.indexWhere((n) => n.id == tempId);
        if (index != -1) {
          _notes[index] = serverNote;
          await _hiveService.saveNotes(_notes);
          _errorMessage = null;
          _syncStatus = 'noteAdded';
        }
      } else {
        _errorMessage = 'failedToAddNote';
        _notes.removeWhere((n) => n.id == tempId);
        await _hiveService.saveNotes(_notes);
        await _hiveService.addOperation(Operation(
          type: OperationType.add,
          note: newNote,
          timestamp: DateTime.now(),
          synced: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding note: $e');
      }
      await _hiveService.addOperation(Operation(
        type: OperationType.add,
        note: newNote,
        timestamp: DateTime.now(),
        synced: false,
      ));
      _syncStatus = 'savedOffline';
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      try {
        _notes[index] = note.copyWith(updatedAt: DateTime.now());
        await _hiveService.saveNotes(_notes);
        notifyListeners();

        if (!await _isOnline()) {
          await _hiveService.addOperation(Operation(
            type: OperationType.update,
            note: note,
            timestamp: DateTime.now(),
            synced: false,
          ));
          _syncStatus = 'savedOffline';
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _errorMessage = 'userNotLoggedIn';
          notifyListeners();
          return;
        }

        final token = await user.getIdToken(true);
        if (token == null) {
          _errorMessage = 'failedToGetToken';
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
          _errorMessage = null;
          _syncStatus = 'noteUpdated';
        } else {
          _errorMessage = 'failedToUpdateNote';
          await _hiveService.addOperation(Operation(
            type: OperationType.update,
            note: note,
            timestamp: DateTime.now(),
            synced: false,
          ));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating note: $e');
        }
        await _hiveService.addOperation(Operation(
          type: OperationType.update,
          note: note,
          timestamp: DateTime.now(),
          synced: false,
        ));
        _syncStatus = 'savedOffline';
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final note = _notes[index];
      try {
        _notes.removeAt(index);
        await _hiveService.saveNotes(_notes);
        notifyListeners();

        if (!await _isOnline()) {
          await _hiveService.addOperation(Operation(
            type: OperationType.delete,
            id: id,
            timestamp: DateTime.now(),
            synced: false,
          ));
          _syncStatus = 'savedOffline';
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _errorMessage = 'userNotLoggedIn';
          notifyListeners();
          return;
        }

        final token = await user.getIdToken(true);
        if (token == null) {
          _errorMessage = 'failedToGetToken';
          notifyListeners();
          return;
        }

        final response = await http.delete(
          Uri.parse('http://10.0.2.2:5102/api/Note/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 204) {
          _errorMessage = null;
          _syncStatus = 'noteDeleted';
        } else {
          _errorMessage = 'deleteFailed';
          _notes.add(note);
          await _hiveService.saveNotes(_notes);
          await _hiveService.addOperation(Operation(
            type: OperationType.delete,
            id: id,
            timestamp: DateTime.now(),
            synced: false,
          ));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting note: $e');
        }
        await _hiveService.addOperation(Operation(
          type: OperationType.delete,
          id: id,
          timestamp: DateTime.now(),
          synced: false,
        ));
        _syncStatus = 'savedOffline';
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleNoteStatus(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final note = _notes[index];
      final updatedNote = note.copyWith(
        isCompleted: !note.isCompleted,
        updatedAt: DateTime.now(),
      );
      try {
        _notes[index] = updatedNote;
        await _hiveService.saveNotes(_notes);
        notifyListeners();

        if (!await _isOnline()) {
          await _hiveService.addOperation(Operation(
            type: OperationType.update,
            note: updatedNote,
            timestamp: DateTime.now(),
            synced: false,
          ));
          _syncStatus = 'savedOffline';
          return;
        }

        if (_toggleDebounce?.isActive ?? false) _toggleDebounce?.cancel();
        _toggleDebounce = Timer(const Duration(milliseconds: 300), () {
          _updateNoteInBackground(updatedNote);
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error toggling note status: $e');
        }
        await _hiveService.addOperation(Operation(
          type: OperationType.update,
          note: updatedNote,
          timestamp: DateTime.now(),
          synced: false,
        ));
        _syncStatus = 'savedOffline';
      }
    }
  }

  Future<void> _updateNoteInBackground(Note note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final token = await user.getIdToken(true);
      if (token == null) return;

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5102/api/Note/${note.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(note.toJson()),
      );

      if (response.statusCode == 200) {
        _syncStatus = 'noteUpdated';
      } else {
        await _hiveService.addOperation(Operation(
          type: OperationType.update,
          note: note,
          timestamp: DateTime.now(),
          synced: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating note in background: $e');
      }
      await _hiveService.addOperation(Operation(
        type: OperationType.update,
        note: note,
        timestamp: DateTime.now(),
        synced: false,
      ));
    }
  }

  Future<void> clearSyncStatus() async {
    _syncStatus = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _toggleDebounce?.cancel();
    _hiveService.dispose();
    super.dispose();
  }
}