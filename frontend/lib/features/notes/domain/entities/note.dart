
enum Priority { low, medium, high }

class Note {
  String? id;
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  Priority priority;
  DateTime createdAt;
  DateTime updatedAt;
  final String? audioUrl;

  Note({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    this.priority = Priority.medium,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.audioUrl,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    Priority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? audioUrl,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'dueDate': dueDate?.toUtc().toIso8601String(),
        'priority': priority.name,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'audioUrl': audioUrl,
      };

  factory Note.fromJson(Map<String, dynamic> json, {String? id}) {
    return Note(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      audioUrl: json['audioUrl'] as String?,
    );
  }
}