import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/features/analytics/domain/analytics_provider.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';
import 'package:smartlist/localization/app_localizations.dart';

class CalendarView extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarView({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  List<Map<String, dynamic>> _generateCalendarDays(BuildContext context) {
    final year = currentMonth.year;
    final month = currentMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final firstDayIndex = firstDay.weekday % 7; // Adjust for Sunday start
    final daysInMonth = lastDay.day;
    final days = <Map<String, dynamic>>[];

    // Add empty cells
    for (int i = 0; i < firstDayIndex; i++) {
      days.add({'day': null, 'date': null, 'tasks': []});
    }

    // Add days
    final provider = Provider.of<AnalyticsProvider>(context, listen: false);
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      // Use cached notes for calendar rendering
      final tasks = provider.notes.where((note) {
        if (note.dueDate == null) return false;
        // Convert note.dueDate to local time for comparison
        final noteDate = note.dueDate!.toLocal();
        final localDate = date.toLocal();
        return noteDate.year == localDate.year &&
            noteDate.month == localDate.month &&
            noteDate.day == localDate.day;
      }).toList();
      days.add({
        'day': day,
        'date': date,
        'tasks': tasks,
        'isToday': DateTime.now().toLocal().year == date.year &&
            DateTime.now().toLocal().month == date.month &&
            DateTime.now().toLocal().day == date.day,
        'isSelected': selectedDate.toLocal().year == date.year &&
            selectedDate.toLocal().month == date.month &&
            selectedDate.toLocal().day == date.day,
      });
    }

    return days;
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.yellow;
      case Priority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _generateCalendarDays(context);
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final localSelectedDate = selectedDate.toLocal();
    final localizations = AppLocalizations.of(context)!;
    if (kDebugMode) {
      print('Selected date for task display: $localSelectedDate');
    } // Debug log

    return Column(
      children: [
        // Weekday Headers
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
          child: Row(
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: AppSizes.spacingSmall(context)),
        // Calendar Grid
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: calendarDays.map((dayObj) {
            return GestureDetector(
              onTap: dayObj['date'] != null ? () => onDateSelected(dayObj['date']) : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: (dayObj['isSelected'] ?? false)
                      ? AppColors.primary.withOpacity(0.1)
                      : dayObj['tasks'].isNotEmpty
                          ? Colors.grey[50]
                          : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: dayObj['day'] != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dayObj['isToday'] ? AppColors.primary : null,
                            ),
                            child: Center(
                              child: Text(
                                '${dayObj['day']}',
                                style: TextStyle(
                                  color: dayObj['isToday'] ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          if (dayObj['tasks'].isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: (dayObj['tasks'] as List<Note>)
                                  .take(3)
                                  .map((task) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _getPriorityColor(task.priority),
                                        ),
                                      ))
                                  .toList(),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }).toList(),
        ),
        // Tasks for Selected Date
        Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${localizations.getString('tasksFor')} ${localSelectedDate.day}/${localSelectedDate.month}/${localSelectedDate.year}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: AppSizes.spacingSmall(context)),
              FutureBuilder<List<Note>>(
                future: Provider.of<AnalyticsProvider>(context, listen: false)
                    .getNotesForDate(localSelectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading tasks: ${snapshot.error}',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }
                  final tasks = snapshot.data ?? [];
                  if (tasks.isEmpty) {
                    return Center(
                      child: Text(
                        'No tasks scheduled for this day',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Provider.of<NoteProvider>(context, listen: false)
                                .toggleNoteStatus(task.id!);
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!, width: 2),
                              color: task.isCompleted ? AppColors.primary : null,
                            ),
                            child: task.isCompleted
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey[400] : Colors.grey[800],
                          ),
                        ),
                        trailing: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getPriorityColor(task.priority),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}