import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class Task {
  String? id;
  String title;
  String description;
  bool isCompleted; // Đảm bảo không nullable
  DateTime? dueDate;
  Priority priority;
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false, // Khởi tạo mặc định
    this.dueDate,
    this.priority = Priority.medium,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    Priority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'priority': priority.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory Task.fromJson(Map<String, dynamic> json, {String? id}) {
    return Task(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false, // Đảm bảo giá trị mặc định
      dueDate: json['dueDate'] != null ? (json['dueDate'] as Timestamp).toDate() : null,
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}