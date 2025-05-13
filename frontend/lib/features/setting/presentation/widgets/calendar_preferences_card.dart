import 'package:flutter/material.dart';
import 'package:smartlist/localization/app_localizations.dart';

class CalendarPreferencesCard extends StatefulWidget {
  const CalendarPreferencesCard({
    super.key,
    required this.calendarView,
    required this.timeFormat,
    required this.firstDayOfWeek,
    required this.showDropdown,
    required this.onCalendarViewChange,
    required this.onFirstDayChange,
    required this.onTimeFormatChange,
    required this.toggleDropdown,
  });

  final String calendarView;
  final bool timeFormat;
  final String firstDayOfWeek;
  final String? showDropdown;
  final void Function(String) onCalendarViewChange;
  final void Function(String) onFirstDayChange;
  final void Function(bool) onTimeFormatChange;
  final void Function(String) toggleDropdown;

  @override
  State<CalendarPreferencesCard> createState() => _CalendarPreferencesCardState();
}

class _CalendarPreferencesCardState extends State<CalendarPreferencesCard> {
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
              localizations.getString('calendarPreferences'),
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
                  localizations.getString('calendarView'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      capitalize(widget.calendarView),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.showDropdown == 'calendarView'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onPressed: () => widget.toggleDropdown('calendarView'),
                    ),
                  ],
                ),
                onTap: () => widget.toggleDropdown('calendarView'),
              ),
              if (widget.showDropdown == 'calendarView')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ['day', 'week', 'month'].map((view) {
                      return ListTile(
                        title: Text(
                          capitalize(view),
                          style: TextStyle(
                            color: widget.calendarView == view ? Colors.blue : Colors.black,
                          ),
                        ),
                        tileColor: widget.calendarView == view ? Colors.blue[50] : null,
                        onTap: () => widget.onCalendarViewChange(view),
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
                  widget.timeFormat ? '24h' : '12h',
                  style: const TextStyle(color: Colors.grey),
                ),
                value: widget.timeFormat,
                onChanged: widget.onTimeFormatChange,
                secondary: Text(
                  localizations.getString('timeFormat'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  localizations.getString('firstDayOfWeek'),
                  style: const TextStyle(color: Colors.black),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.firstDayOfWeek,
                      style: const TextStyle(color: Colors.blue),
                    ),
                    IconButton(
                      icon: Icon(
                        widget.showDropdown == 'firstDay'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      onPressed: () => widget.toggleDropdown('firstDay'),
                    ),
                  ],
                ),
                onTap: () => widget.toggleDropdown('firstDay'),
              ),
              if (widget.showDropdown == 'firstDay')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ['Sunday', 'Monday', 'Saturday'].map((day) {
                      return ListTile(
                        title: Text(
                          day,
                          style: TextStyle(
                            color: widget.firstDayOfWeek == day ? Colors.blue : Colors.black,
                          ),
                        ),
                        tileColor: widget.firstDayOfWeek == day ? Colors.blue[50] : null,
                        onTap: () => widget.onFirstDayChange(day),
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