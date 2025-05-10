import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/tasks/domain/entities/task.dart';
import 'package:smartlist/features/tasks/domain/providers/task_provider.dart';
import 'package:smartlist/features/tasks/presentation/screens/add_task_screen.dart';
import 'package:smartlist/features/tasks/presentation/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  Future<bool> _onWillPop() async {
    return true; // Allow app to exit when back is pressed
  }

  void _onTabTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Calendar tab - launch external link
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
        _selectedIndex = 0; // Return to Tasks tab
      });
    } else if (index == 2) {
      // Settings tab
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      setState(() {
        _selectedIndex = 0; // Return to Tasks tab after settings
      });
    }
  }

  void _showSnackBar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action:
            actionLabel != null && onAction != null
                ? SnackBarAction(label: actionLabel, onPressed: onAction)
                : null,
      ),
    );
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return '${date.day} ${_getMonthShort(date.month)}';
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.getString('taskListTitle')),
          automaticallyImplyLeading: false, // Remove back button
        ),
        body: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppSizes.iconLarge(context),
                      color: AppColors.error,
                    ),
                    SizedBox(height: AppSizes.spacingMedium(context)),
                    Text(
                      localizations.getString(provider.errorMessage!),
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSizes.spacingMedium(context)),
                    ElevatedButton(
                      onPressed: () => provider.loadTasks(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(localizations.getString('retry')),
                    ),
                  ],
                ),
              );
            }

            if (provider.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: AppSizes.iconLarge(context),
                      color: Theme.of(context).disabledColor,
                    ),
                    SizedBox(height: AppSizes.spacingMedium(context)),
                    Text(
                      localizations.getString('noTasks'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: ListView.separated(
                itemCount: provider.tasks.length,
                separatorBuilder:
                    (context, index) =>
                        SizedBox(height: AppSizes.spacingMedium(context)),
                itemBuilder: (context, index) {
                  final task = provider.tasks[index];
                  if (task.id == null)
                    return const SizedBox.shrink(); // Skip tasks with null IDs
                  return GestureDetector(
                    onTap: () async {
                      // Navigate to AddTaskScreen for editing
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddTaskScreen(
                                taskToEdit: task,
                                onShowSnackBar: _showSnackBar,
                              ),
                        ),
                      );
                      provider.loadTasks();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      child: Row(
                        children: [
                          // Checkbox for completion
                          GestureDetector(
                            onTap: () {
                              provider.toggleTaskStatus(task.id!);
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                color:
                                    task.isCompleted
                                        ? AppColors.primary
                                        : Colors.transparent,
                              ),
                              child:
                                  task.isCompleted
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                      : null,
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingMedium(context)),
                          // Task details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              task.isCompleted
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade800,
                                          decoration:
                                              task.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getPriorityColor(task.priority),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${localizations.getString('due')} ${_formatDate(task.dueDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              provider.deleteTask(task.id!);
                              _showSnackBar(
                                localizations.getString('taskDeleted'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final taskProvider = Provider.of<TaskProvider>(
              context,
              listen: false,
            );
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddTaskScreen(onShowSnackBar: _showSnackBar),
              ),
            );
            taskProvider.loadTasks();
          },
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
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
      ),
    );
  }
}
