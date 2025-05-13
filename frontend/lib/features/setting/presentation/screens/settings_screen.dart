import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/features/setting/presentation/widgets/about_help_card.dart';
import 'package:smartlist/features/setting/presentation/widgets/account_settings_card.dart';
import 'package:smartlist/features/setting/presentation/widgets/appearance_card.dart';
import 'package:smartlist/features/setting/presentation/widgets/calendar_preferences_card.dart';
import 'package:smartlist/features/setting/presentation/widgets/note_management_card.dart';
import 'package:smartlist/features/setting/presentation/widgets/notifications_card.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
  }

  Future<void> _fetchAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = '${packageInfo.version} (Build ${packageInfo.buildNumber})';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _appVersion = 'Unknown';
      });
      // Thay print bằng comment hoặc logging framework trong production
      // logger.e("Error fetching app version: $e"); // Nếu dùng package logger
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch calendar URL')),
        );
      }
      if (!mounted) return;
      setState(() {
        _selectedIndex = 2; // Return to Setting tab
      });
    } else if (index == 0) {
      if (!mounted) return;
      context.go(RoutePaths.noteList); // Sử dụng GoRouter thay Navigator.push
      if (!mounted) return;
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

  void handleTextSizeChange(int value) {
    setState(() {
      textSize = value;
    });
  }

  void handleReminderChange(bool value) {
    setState(() {
      noteReminders = value;
    });
  }

  void handleUpcomingAlertChange(bool value) {
    setState(() {
      upcomingAlerts = value;
    });
  }

  void handleVibrationChange(bool value) {
    setState(() {
      vibration = value;
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
            AccountSettingsCard(),
            CalendarPreferencesCard(
              calendarView: calendarView,
              timeFormat: timeFormat,
              firstDayOfWeek: firstDayOfWeek,
              showDropdown: showDropdown,
              onCalendarViewChange: handleCalendarViewChange,
              onFirstDayChange: handleFirstDayChange,
              onTimeFormatChange: (value) => setState(() => timeFormat = value),
              toggleDropdown: toggleDropdown,
            ),
            NoteManagementCard(
              defaultPriority: defaultPriority,
              dueDateFormat: dueDateFormat,
              noteSorting: noteSorting,
              showDropdown: showDropdown,
              onPriorityChange: handlePriorityChange,
              onDateFormatChange: handleDateFormatChange,
              onSortingChange: handleSortingChange,
              toggleDropdown: toggleDropdown,
            ),
            NotificationsCard(
              noteReminders: noteReminders,
              upcomingAlerts: upcomingAlerts,
              notificationSound: notificationSound,
              vibration: vibration,
              showDropdown: showDropdown,
              onReminderChange: handleReminderChange,
              onUpcomingAlertChange: handleUpcomingAlertChange,
              onSoundChange: handleSoundChange,
              onVibrationChange: handleVibrationChange,
              toggleDropdown: toggleDropdown,
            ),
            AppearanceCard(
              theme: theme,
              textSize: textSize,
              onThemeChange: handleThemeChange,
              onTextSizeChange: handleTextSizeChange,
            ),
            AboutHelpCard(appVersion: _appVersion),
            // Logout Button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
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
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.getString(
                              authProvider.errorMessage != null
                                  ? authProvider.errorMessage!
                                  : 'logoutSuccess',
                            ),
                          ),
                        ),
                      );
                      context.go(RoutePaths.login);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.getString(
                              authProvider.errorMessage ?? 'logoutFailed',
                            ),
                          ),
                        ),
                      );
                      context.go(RoutePaths.login);
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
              color: theme == themeValue ? AppColors.primary : Colors.grey.shade200,
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