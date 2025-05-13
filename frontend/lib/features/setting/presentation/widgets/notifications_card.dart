import 'package:flutter/material.dart';
import 'package:smartlist/localization/app_localizations.dart';

class NotificationsCard extends StatefulWidget {
  const NotificationsCard({
    super.key,
    required this.noteReminders,
    required this.upcomingAlerts,
    required this.notificationSound,
    required this.vibration,
    required this.showDropdown,
    required this.onReminderChange,
    required this.onUpcomingAlertChange,
    required this.onSoundChange,
    required this.onVibrationChange,
    required this.toggleDropdown,
  });

  final bool noteReminders;
  final bool upcomingAlerts;
  final String notificationSound;
  final bool vibration;
  final String? showDropdown;
  final void Function(bool) onReminderChange;
  final void Function(bool) onUpcomingAlertChange;
  final void Function(String) onSoundChange;
  final void Function(bool) onVibrationChange;
  final void Function(String) toggleDropdown;

  @override
  State<NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<NotificationsCard> {
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
              localizations.getString('notifications'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
          Column(
            children: [
              SwitchListTile(
                title: Text(
                  localizations.getString('taskDueReminders'),
                  style: const TextStyle(color: Colors.black),
                ),
                value: widget.noteReminders,
                onChanged: widget.onReminderChange,
              ),
              SwitchListTile(
                title: Text(
                  localizations.getString('upcomingTasksAlerts'),
                  style: const TextStyle(color: Colors.black),
                ),
                value: widget.upcomingAlerts,
                onChanged: widget.onUpcomingAlertChange,
              ),
              ListTile(
                title: Text(
                  localizations.getString('notificationSound'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.notificationSound,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.showDropdown == 'sound'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onPressed: () => widget.toggleDropdown('sound'),
                    ),
                  ],
                ),
                onTap: () => widget.toggleDropdown('sound'),
              ),
              if (widget.showDropdown == 'sound')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ['Chime', 'Bell', 'Ping', 'None'].map((sound) {
                      return ListTile(
                        title: Text(
                          sound,
                          style: TextStyle(
                            color: widget.notificationSound == sound ? Colors.blue : Colors.black,
                          ),
                        ),
                        tileColor: widget.notificationSound == sound ? Colors.blue[50] : null,
                        onTap: () => widget.onSoundChange(sound),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    }).toList(),
                  ),
                ),
              SwitchListTile(
                title: Text(
                  localizations.getString('vibration'),
                  style: const TextStyle(color: Colors.black),
                ),
                value: widget.vibration,
                onChanged: widget.onVibrationChange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}