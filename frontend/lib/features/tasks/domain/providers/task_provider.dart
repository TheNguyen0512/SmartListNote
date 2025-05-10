import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../entities/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'userNotLoggedIn';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .get();

      _tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Task.fromJson(data, id: doc.id);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'failedToLoadTasks';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'userNotLoggedIn';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final taskWithTimestamps = task.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add(taskWithTimestamps.toJson());

      await _loadTasks();
    } catch (e) {
      _errorMessage = e.toString().contains('permission-denied') ? 'permissionDenied' : 'failedToAddTask';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || task.id == null) return;

    try {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .update(task.toJson());
    } catch (e) {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
      _errorMessage = 'updateFailed';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'userNotLoggedIn';
      notifyListeners();
      return;
    }

    try {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index == -1) return;

      final originalTask = _tasks[index];
      final updatedTask = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
        updatedAt: DateTime.now(),
      );
      _tasks[index] = updatedTask;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(id)
          .update({
        'isCompleted': updatedTask.isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: !_tasks[index].isCompleted,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      _errorMessage = 'updateFailed';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index == -1) return;

      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(id)
          .delete();
    } catch (e) {
      _errorMessage = 'deleteFailed';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}