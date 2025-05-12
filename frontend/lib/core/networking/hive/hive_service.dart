import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:smartlist/core/networking/hive/models/operation.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'dart:convert';

class HiveService {
  late Box<String> _operationBox;
  late Box<Note> _noteBox;
  bool _isInitialized = false;

  HiveService() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (!_isInitialized) {
        _operationBox = await Hive.openBox<String>('operations');
        _noteBox = await Hive.openBox<Note>('notes');
        _isInitialized = true;
        if (kDebugMode) {
          print('Hive boxes initialized: operations and notes');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Hive: $e');
      }
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    try {
      await _ensureBoxOpen();
      await _noteBox.clear();
      for (var note in notes) {
        if (note.id != null) {
          await _noteBox.put(note.id, note);
        }
      }
      if (kDebugMode) {
        print('Saved ${notes.length} notes to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notes to Hive: $e');
      }
      throw Exception('Failed to save notes to Hive: $e');
    }
  }

  Future<List<Note>> loadNotes() async {
    try {
      await _ensureBoxOpen();
      final notes = _noteBox.values.toList();
      if (kDebugMode) {
        print('Loaded ${notes.length} notes from Hive');
      }
      return notes;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading notes from Hive: $e');
      }
      return [];
    }
  }

  Future<void> addOperation(Operation operation) async {
    try {
      await _ensureBoxOpen();
      final json = jsonEncode(operation.toJson());
      await _operationBox.add(json);
      if (kDebugMode) {
        print('Added operation to Hive: ${operation.type}, ID: ${operation.note?.id ?? operation.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding operation to Hive: $e');
      }
      throw Exception('Failed to add operation to Hive: $e');
    }
  }

  Future<List<Operation>> getOperations() async {
    try {
      await _ensureBoxOpen();
      final operations = _operationBox.values
          .map((json) => Operation.fromJson(jsonDecode(json)))
          .toList();
      if (kDebugMode) {
        print('Loaded ${operations.length} operations from Hive');
      }
      return operations;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading operations from Hive: $e');
      }
      return [];
    }
  }

  Future<bool> deleteOperation(int index) async {
    try {
      await _ensureBoxOpen();
      if (index >= 0 && index < _operationBox.length) {
        await _operationBox.deleteAt(index);
        if (kDebugMode) {
          print('Deleted operation at index $index');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Invalid index for deleteOperation: $index, box length: ${_operationBox.length}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting operation at index $index: $e');
      }
      return false;
    }
  }

  Future<void> _ensureBoxOpen() async {
    if (!_isInitialized || !_operationBox.isOpen || !_noteBox.isOpen) {
      await _init();
    }
  }

  void dispose() {
    try {
      if (_isInitialized) {
        _operationBox.close();
        _noteBox.close();
        _isInitialized = false;
        if (kDebugMode) {
          print('Hive boxes closed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error closing Hive boxes: $e');
      }
    }
  }
}