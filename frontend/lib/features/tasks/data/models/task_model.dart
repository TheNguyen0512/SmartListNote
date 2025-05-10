import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartlist/features/tasks/domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required String super.id,
    required super.title,
    required super.description,
    required super.dueDate,
    required super.priority,
    required super.isCompleted,
    required DateTime super.createdAt,
    required DateTime super.updatedAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      priority: Priority.values.firstWhere(
        (e) => e.name == (data['priority'] ?? 'medium'),
        orElse: () => Priority.medium,
      ),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority.toString(),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}