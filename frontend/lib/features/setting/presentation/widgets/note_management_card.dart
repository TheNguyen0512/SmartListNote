import 'package:flutter/material.dart';
import 'package:smartlist/localization/app_localizations.dart';

class NoteManagementCard extends StatefulWidget {
  const NoteManagementCard({
    super.key,
    required this.defaultPriority,
    required this.dueDateFormat,
    required this.noteSorting,
    required this.showDropdown,
    required this.onPriorityChange,
    required this.onDateFormatChange,
    required this.onSortingChange,
    required this.toggleDropdown,
  });

  final String defaultPriority;
  final String dueDateFormat;
  final String noteSorting;
  final String? showDropdown;
  final void Function(String) onPriorityChange;
  final void Function(String) onDateFormatChange;
  final void Function(String) onSortingChange;
  final void Function(String) toggleDropdown;

  @override
  State<NoteManagementCard> createState() => _NoteManagementCardState();
}

class _NoteManagementCardState extends State<NoteManagementCard> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Text(
              localizations.getString('taskManagement'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          Column(
            children: [
              ListTile(
                title: Text(
                  localizations.getString('defaultTaskPriority'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.defaultPriority == 'high'
                            ? Colors.red
                            : widget.defaultPriority == 'medium'
                                ? Colors.yellow
                                : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      capitalize(widget.defaultPriority),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.showDropdown == 'priority'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onPressed: () => widget.toggleDropdown('priority'),
                    ),
                  ],
                ),
                onTap: () => widget.toggleDropdown('priority'),
              ),
              if (widget.showDropdown == 'priority')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ['high', 'medium', 'low'].map((priority) {
                      return ListTile(
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: priority == 'high'
                                ? Colors.red
                                : priority == 'medium'
                                    ? Colors.yellow
                                    : Colors.green,
                          ),
                        ),
                        title: Text(
                          capitalize(priority),
                          style: TextStyle(
                            color: widget.defaultPriority == priority ? Colors.blue : Colors.black,
                          ),
                        ),
                        tileColor: widget.defaultPriority == priority ? Colors.blue[50] : null,
                        onTap: () => widget.onPriorityChange(priority),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                ),
              ListTile(
                title: Text(
                  localizations.getString('taskDueDateFormat'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.dueDateFormat,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.showDropdown == 'dateFormat'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onPressed: () => widget.toggleDropdown('dateFormat'),
                    ),
                  ],
                ),
                onTap: () => widget.toggleDropdown('dateFormat'),
              ),
              if (widget.showDropdown == 'dateFormat')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'].map((format) {
                      return ListTile(
                        title: Text(
                          format,
                          style: TextStyle(
                            color: widget.dueDateFormat == format ? Colors.blue : Colors.black,
                          ),
                        ),
                        tileColor: widget.dueDateFormat == format ? Colors.blue[50] : null,
                        onTap: () => widget.onDateFormatChange(format),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                ),
              ListTile(
                title: Text(
                  localizations.getString('taskSortingPreferences'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.noteSorting,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.showDropdown == 'sorting'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onPressed: () => widget.toggleDropdown('sorting'),
                    ),
                  ],
                ),
                onTap: () => widget.toggleDropdown('sorting'),
              ),
              if (widget.showDropdown == 'sorting')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ['due date', 'priority', 'title', 'created date'].map((sorting) {
                      return ListTile(
                        title: Text(
                          sorting,
                          style: TextStyle(
                            color: widget.noteSorting == sorting ? Colors.blue : Colors.black,
                          ),
                        ),
                        tileColor: widget.noteSorting == sorting ? Colors.blue[50] : null,
                        onTap: () => widget.onSortingChange(sorting),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}