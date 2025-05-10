import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/tasks/domain/entities/task.dart';
import 'package:smartlist/features/tasks/domain/providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task? task;
  final void Function(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  })
  onShowSnackBar;

  const TaskCard({super.key, this.task, required this.onShowSnackBar});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (task == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Task data is unavailable'),
        ),
      );
    }

    return Card(
      child: InkWell(        
        child: ListTile(
          leading: IconButton(
            icon: Icon(
              task!.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color:
                  task!.isCompleted
                      ? AppColors.success
                      : theme.unselectedWidgetColor,
              size: AppSizes.iconMedium(context),
            ),
            onPressed: () async {
              if (task!.id != null) {
                try {
                  await taskProvider.toggleTaskStatus(task!.id!);
                } catch (e) {
                  onShowSnackBar(localizations.getString('updateFailed'));
                }
              }
            },
          ),
          title: Text(task!.title, style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontTitle,
            color: task!.isCompleted
                ? AppColors.success
                : theme.textTheme.bodyLarge?.color,
          )),
          subtitle:
              task!.description.isNotEmpty
                  ? Text(
                    task!.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                  : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (task!.id != null) {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(localizations.confirmDelete),
                        content: Text(localizations.deleteTaskConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(localizations.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(localizations.delete),
                          ),
                        ],
                      ),
                );

                if (shouldDelete == true) {
                  final deletedTask = task!;
                  await taskProvider.deleteTask(task!.id!);
                  onShowSnackBar(
                    localizations.taskDeleted,
                    actionLabel: localizations.undo,
                    onAction: () {
                      taskProvider.addTask(deletedTask);
                    },
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
