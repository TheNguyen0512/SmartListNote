import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartlist/core/networking/hive/hive_service.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AnalyticsProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<Note> _notes = [];
  String? _errorMessage;
  bool _isLoading = false;
  DateTime _currentMonth = DateTime.now();

  List<Note> get notes => _notes;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AnalyticsProvider() {
    loadAnalyticsData();
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> loadAnalyticsData({DateTime? month}) async {
    _isLoading = true;
    if (month != null) {
      _currentMonth = DateTime(month.year, month.month, 1);
    }
    notifyListeners();

    try {
      _notes = await _hiveService.loadNotes();
      if (!await _isOnline()) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'userNotLoggedIn';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final token = await user.getIdToken(true);
      if (token == null) {
        _errorMessage = 'failedToGetToken';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5102/api/Analytics/month/${_currentMonth.year}/${_currentMonth.month}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _notes =
            (data['tasks'] as List)
                .map((json) => Note.fromJson(json, id: json['id']))
                .toList();
        await _hiveService.saveNotes(_notes);
        _errorMessage = null;
      } else {
        _errorMessage = 'failedToLoadAnalytics';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading analytics data: $e');
      }
      _errorMessage = 'failedToLoadAnalytics';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Note>> getNotesForDate(DateTime date) async {
    final localDate = date.toLocal();
    if (kDebugMode) {
      print('Fetching tasks for local date: $localDate');
    } // Debug log

    if (!await _isOnline()) {
      if (kDebugMode) {
        print('Using cached notes for $localDate');
      }
      final offlineTasks =
          _notes.where((note) {
            if (note.dueDate == null) return false;
            final noteDate = note.dueDate!.toLocal();
            return noteDate.year == localDate.year &&
                noteDate.month == localDate.month &&
                noteDate.day == localDate.day;
          }).toList();
      if (kDebugMode) {
        print(
        'Offline tasks for $localDate: ${offlineTasks.map((note) => note.toJson()).toList()}',
      );
      }
      return offlineTasks;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final token = await user.getIdToken(true);
    if (token == null) return [];

    // Use the local date's year, month, day, normalized to UTC for the API
    final apiDate = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    if (kDebugMode) {
      print('Sending API request for date: $apiDate');
    }

    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:5102/api/Analytics/date/${apiDate.year}/${apiDate.month}/${apiDate.day}',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (kDebugMode) {
        print('API response for $apiDate: $data');
      }
      final tasks =
          (data as List)
              .map((json) => Note.fromJson(json, id: json['id']))
              .toList();

      // Filter tasks to match the local date
      final filteredTasks =
          tasks.where((note) {
            if (note.dueDate == null) return false;
            final noteDate = note.dueDate!.toLocal();
            return noteDate.year == localDate.year &&
                noteDate.month == localDate.month &&
                noteDate.day == localDate.day;
          }).toList();

      if (kDebugMode) {
        print(
        'Parsed and filtered tasks for $localDate: ${filteredTasks.map((note) => note.toJson()).toList()}',
      );
      }
      return filteredTasks;
    }
    if (kDebugMode) {
      print(
      'Failed to fetch tasks for $apiDate: ${response.statusCode}, ${response.body}',
    );
    }
    return [];
  }

  Map<String, int> getMonthlyOverview(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final monthlyNotes =
        _notes.where((note) {
          return note.dueDate != null &&
              note.dueDate!.isAfter(
                startOfMonth.subtract(const Duration(days: 1)),
              ) &&
              note.dueDate!.isBefore(endOfMonth.add(const Duration(days: 1)));
        }).toList();

    return {
      'highPrio':
          monthlyNotes.where((note) => note.priority == Priority.high).length,
      'mediumPrio':
          monthlyNotes.where((note) => note.priority == Priority.medium).length,
      'lowPrio':
          monthlyNotes.where((note) => note.priority == Priority.low).length,
    };
  }

  @override
  void dispose() {
    _hiveService.dispose();
    super.dispose();
  }
}
