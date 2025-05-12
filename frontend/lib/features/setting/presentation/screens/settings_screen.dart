// frontend/lib/features/notes/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/localization/locale_provider.dart';
import 'package:smartlist/features/auth/domain/providers/auth_provider.dart';
import 'package:smartlist/routing/route_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String calendarView = 'month';
  bool timeFormat = true; // true = 24h, false = 12h
  String firstDayOfWeek = 'Sunday';
  String defaultPriority = 'medium';
  String dueDateFormat = 'MM/DD/YYYY';
  String noteSorting = 'due date';
  bool noteReminders = true;
  bool upcomingAlerts = true;
  String notificationSound = 'Chime';
  bool vibration = true;
  String theme = 'light';
  int textSize = 2; // 1-4 scale
  String? showDropdown;
  int _selectedIndex = 2;

  String _appVersion = 'Loading...'; // Class-level variable for app version

  Future<void> _fetchAppVersion() async {

    @override
    void initState() {
      super.initState();
      _fetchAppVersion();
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion =
            '${packageInfo.version} (Build ${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Unknown';
      });
      print("Error fetching app version: $e");
    }
  }

  void _onTabTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      const url =
          'https://readdy.ai/home/93f9ccd5-e659-4e91-b6da-4f1c6c2c387c/234832b4-c196-4fdd-96f9-2cc5f32fdd0d';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch calendar URL')),
        );
      }
      setState(() {
        _selectedIndex = 2; // Return to Setting tab
      });
    } else if (index == 0) {
      context.go(RoutePaths.noteList); // Sử dụng GoRouter thay Navigator.push
      setState(() {
        _selectedIndex = 2; // Return to Setting tab after notes
      });
    }
  }

  void toggleDropdown(String dropdown) {
    setState(() {
      showDropdown = showDropdown == dropdown ? null : dropdown;
    });
  }

  void handleCalendarViewChange(String view) {
    setState(() {
      calendarView = view;
      showDropdown = null;
    });
  }

  void handleFirstDayChange(String day) {
    setState(() {
      firstDayOfWeek = day;
      showDropdown = null;
    });
  }

  void handlePriorityChange(String priority) {
    setState(() {
      defaultPriority = priority;
      showDropdown = null;
    });
  }

  void handleDateFormatChange(String format) {
    setState(() {
      dueDateFormat = format;
      showDropdown = null;
    });
  }

  void handleSortingChange(String sorting) {
    setState(() {
      noteSorting = sorting;
      showDropdown = null;
    });
  }

  void handleSoundChange(String sound) {
    setState(() {
      notificationSound = sound;
      showDropdown = null;
    });
  }

  void handleThemeChange(String newTheme) {
    setState(() {
      theme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.getString('settings'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            // Account Settings
            Card(
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
                      localizations.getString('accountSettings'),
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
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          authProvider.user?.displayName ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        subtitle: Text(
                          authProvider.user?.email ?? 'No email',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        ),
                      ),
                      ListTile(
                        title: Text(
                          localizations.getString('language'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: localeProvider.locale.languageCode,
                              items: [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text(
                                    localizations.getString('english'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'vi',
                                  child: Text(
                                    localizations.getString('vietnamese'),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  localeProvider.setLocale(
                                    Locale(value, value == 'en' ? 'US' : 'VN'),
                                  );
                                }
                              },
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.blue),
                              underline: const SizedBox.shrink(),
                              dropdownColor: Theme.of(context).cardColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      // Example snippet for SettingsScreen
                      ListTile(
                        title: Text(
                          localizations.getString('changePassword'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () async {
                          final currentPasswordController =
                              TextEditingController();
                          final newPasswordController = TextEditingController();

                          final shouldChange = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(
                                    localizations.getString('changePassword'),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: currentPasswordController,
                                        decoration: InputDecoration(
                                          labelText: localizations.getString(
                                            'currentPassword',
                                          ),
                                        ),
                                        obscureText: true,
                                      ),
                                      TextField(
                                        controller: newPasswordController,
                                        decoration: InputDecoration(
                                          labelText: localizations.getString(
                                            'newPassword',
                                          ),
                                        ),
                                        obscureText: true,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: Text(
                                        localizations.getString('cancel'),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text(
                                        localizations.getString('change'),
                                      ),
                                    ),
                                  ],
                                ),
                          );

                          if (shouldChange == true) {
                            try {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              await authProvider.changePassword(
                                currentPasswordController.text,
                                newPasswordController.text,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations.getString('passwordChanged'),
                                  ),
                                ),
                              );
                            } catch (e) {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations.getString(
                                      authProvider.errorMessage ??
                                          'changePasswordFailed',
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      ListTile(
                        title: Text(
                          localizations.getString('exportData'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Calendar Preferences
            Card(
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
                              capitalize(calendarView),
                              style: const TextStyle(color: Colors.blue),
                            ),
                            IconButton(
                              icon: Icon(
                                showDropdown == 'calendarView'
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              onPressed: () => toggleDropdown('calendarView'),
                            ),
                          ],
                        ),
                        onTap: () => toggleDropdown('calendarView'),
                      ),
                      if (showDropdown == 'calendarView')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children:
                                ['day', 'week', 'month'].map((view) {
                                  return ListTile(
                                    title: Text(
                                      capitalize(view),
                                      style: TextStyle(
                                        color:
                                            calendarView == view
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    tileColor:
                                        calendarView == view
                                            ? Colors.blue[50]
                                            : null,
                                    onTap: () => handleCalendarViewChange(view),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      SwitchListTile(
                        title: Text(
                          timeFormat ? '24h' : '12h',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        value: timeFormat,
                        onChanged:
                            (value) => setState(() => timeFormat = value),
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
                              firstDayOfWeek,
                              style: const TextStyle(color: Colors.blue),
                            ),
                            IconButton(
                              icon: Icon(
                                showDropdown == 'firstDay'
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              onPressed: () => toggleDropdown('firstDay'),
                            ),
                          ],
                        ),
                        onTap: () => toggleDropdown('firstDay'),
                      ),
                      if (showDropdown == 'firstDay')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children:
                                ['Sunday', 'Monday', 'Saturday'].map((day) {
                                  return ListTile(
                                    title: Text(
                                      day,
                                      style: TextStyle(
                                        color:
                                            firstDayOfWeek == day
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    tileColor:
                                        firstDayOfWeek == day
                                            ? Colors.blue[50]
                                            : null,
                                    onTap: () => handleFirstDayChange(day),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Note Management
            Card(
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
                                color:
                                    defaultPriority == 'high'
                                        ? Colors.red
                                        : defaultPriority == 'medium'
                                        ? Colors.yellow
                                        : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              capitalize(defaultPriority),
                              style: const TextStyle(color: Colors.blue),
                            ),
                            IconButton(
                              icon: Icon(
                                showDropdown == 'priority'
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              onPressed: () => toggleDropdown('priority'),
                            ),
                          ],
                        ),
                        onTap: () => toggleDropdown('priority'),
                      ),
                      if (showDropdown == 'priority')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children:
                                ['high', 'medium', 'low'].map((priority) {
                                  return ListTile(
                                    leading: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            priority == 'high'
                                                ? Colors.red
                                                : priority == 'medium'
                                                ? Colors.yellow
                                                : Colors.green,
                                      ),
                                    ),
                                    title: Text(
                                      capitalize(priority),
                                      style: TextStyle(
                                        color:
                                            defaultPriority == priority
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    tileColor:
                                        defaultPriority == priority
                                            ? Colors.blue[50]
                                            : null,
                                    onTap: () => handlePriorityChange(priority),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
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
                              dueDateFormat,
                              style: const TextStyle(color: Colors.blue),
                            ),
                            IconButton(
                              icon: Icon(
                                showDropdown == 'dateFormat'
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              onPressed: () => toggleDropdown('dateFormat'),
                            ),
                          ],
                        ),
                        onTap: () => toggleDropdown('dateFormat'),
                      ),
                      if (showDropdown == 'dateFormat')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children:
                                ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'].map((
                                  format,
                                ) {
                                  return ListTile(
                                    title: Text(
                                      format,
                                      style: TextStyle(
                                        color:
                                            dueDateFormat == format
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    tileColor:
                                        dueDateFormat == format
                                            ? Colors.blue[50]
                                            : null,
                                    onTap: () => handleDateFormatChange(format),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
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
                              noteSorting,
                              style: const TextStyle(color: Colors.blue),
                            ),
                            IconButton(
                              icon: Icon(
                                showDropdown == 'sorting'
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              onPressed: () => toggleDropdown('sorting'),
                            ),
                          ],
                        ),
                        onTap: () => toggleDropdown('sorting'),
                      ),
                      if (showDropdown == 'sorting')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children:
                                [
                                  'due date',
                                  'priority',
                                  'title',
                                  'created date',
                                ].map((sorting) {
                                  return ListTile(
                                    title: Text(
                                      sorting,
                                      style: TextStyle(
                                        color:
                                            noteSorting == sorting
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    tileColor:
                                        noteSorting == sorting
                                            ? Colors.blue[50]
                                            : null,
                                    onTap: () => handleSortingChange(sorting),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Notifications
            Card(
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
                        value: noteReminders,
                        onChanged:
                            (value) => setState(() => noteReminders = value),
                      ),
                      SwitchListTile(
                        title: Text(
                          localizations.getString('upcomingTasksAlerts'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        value: upcomingAlerts,
                        onChanged:
                            (value) => setState(() => upcomingAlerts = value),
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
                              notificationSound,
                              style: const TextStyle(color: Colors.blue),
                            ),
                            IconButton(
                              icon: Icon(
                                showDropdown == 'sound'
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              onPressed: () => toggleDropdown('sound'),
                            ),
                          ],
                        ),
                        onTap: () => toggleDropdown('sound'),
                      ),
                      if (showDropdown == 'sound')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children:
                                ['Chime', 'Bell', 'Ping', 'None'].map((sound) {
                                  return ListTile(
                                    title: Text(
                                      sound,
                                      style: TextStyle(
                                        color:
                                            notificationSound == sound
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    tileColor:
                                        notificationSound == sound
                                            ? Colors.blue[50]
                                            : null,
                                    onTap: () => handleSoundChange(sound),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      SwitchListTile(
                        title: Text(
                          localizations.getString('vibration'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        value: vibration,
                        onChanged: (value) => setState(() => vibration = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Appearance
            Card(
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
                      localizations.getString('appearance'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              localizations.getString('theme'),
                              style: const TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildThemeButton(
                                  'light',
                                  Icons.wb_sunny,
                                  'Light',
                                ),
                                _buildThemeButton(
                                  'dark',
                                  Icons.nightlight_round,
                                  'Dark',
                                ),
                                _buildThemeButton(
                                  'system',
                                  Icons.brightness_auto,
                                  'System',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  localizations.getString('textSize'),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                Text(
                                  textSize == 1
                                      ? 'Small'
                                      : textSize == 2
                                      ? 'Medium'
                                      : textSize == 3
                                      ? 'Large'
                                      : 'Extra Large',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: textSize.toDouble(),
                              min: 1,
                              max: 4,
                              divisions: 3,
                              label: textSize.toString(),
                              onChanged:
                                  (value) =>
                                      setState(() => textSize = value.toInt()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // About & Help
            Card(
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
                      localizations.getString('aboutHelp'),
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
                          localizations.getString('helpCenter'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          context.push(RoutePaths.helpCenter);
                        },
                      ),
                      ListTile(
                        title: Text(
                          localizations.getString('privacyPolicy'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          context.push(RoutePaths.privacyPolicy);
                        },
                      ),
                      ListTile(
                        title: Text(
                          localizations.getString('termsOfService'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          context.push(RoutePaths.termsOfService);
                        },
                      ),
                      ListTile(
                        title: Text(
                          localizations.getString('version'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          _appVersion,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(localizations.getString('confirmLogout')),
                          content: Text(
                            localizations.getString('logoutConfirmation'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(localizations.getString('cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(localizations.getString('logout')),
                            ),
                          ],
                        ),
                  );

                  if (shouldLogout == true) {
                    try {
                      await authProvider.logout();
                      if (authProvider.errorMessage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              localizations.getString('logoutSuccess'),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              localizations.getString(
                                    authProvider.errorMessage!,
                                  ) ??
                                  'logoutFailed',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.getString(
                              authProvider.errorMessage ?? 'logoutFailed',
                            ),
                          ),
                        ),
                      );
                    } finally {
                      context.go(
                        RoutePaths.login,
                      ); // Sử dụng GoRouter thay pushAndRemoveUntil
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red,
                  minimumSize: Size(
                    double.infinity,
                    AppSizes.buttonHeight(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(localizations.getString('logout')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade500,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.task),
            label: localizations.getString('tasks'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: localizations.getString('calendar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: localizations.getString('settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(String themeValue, IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => handleThemeChange(themeValue),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  theme == themeValue
                      ? AppColors.primary
                      : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(8),
            color: theme == themeValue ? Colors.blue[50] : null,
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(
                  icon,
                  color: theme == themeValue ? Colors.blue : Colors.grey,
                  size: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: theme == themeValue ? Colors.blue : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
