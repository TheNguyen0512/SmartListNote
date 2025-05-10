import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/tasks/domain/entities/task.dart';
import 'package:smartlist/features/tasks/domain/providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  final Function(String message, {String? actionLabel, VoidCallback? onAction})
  onShowSnackBar;

  const AddTaskScreen({
    super.key,
    this.taskToEdit,
    required this.onShowSnackBar,
  });

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  Priority _priority = Priority.medium;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.taskToEdit?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.taskToEdit?.description ?? '',
    );
    _dueDate = widget.taskToEdit?.dueDate;
    _priority = widget.taskToEdit?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final localizations = AppLocalizations.of(context)!;

      final newTask = Task(
        id: widget.taskToEdit?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: widget.taskToEdit?.isCompleted ?? false,
      );

      try {
        if (widget.taskToEdit == null) {
          // Add new task
          await taskProvider.addTask(newTask);
          widget.onShowSnackBar(localizations.getString('taskAdded'));
        } else {
          // Update existing task
          await taskProvider.updateTask(newTask);
          widget.onShowSnackBar(localizations.getString('taskUpdated'));
        }
        Navigator.pop(context);
      } catch (e) {
        widget.onShowSnackBar(localizations.getString('errorSavingTask'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.taskToEdit == null
              ? localizations.getString('addTask')
              : localizations.getString('editTask'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
            color: AppColors.primary,
            tooltip: localizations.getString('save'),
          ),
        ],
        elevation: 2,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: localizations.getString('taskTitleHint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    hintText: localizations.getString('taskTitleHint'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.getString('titleRequired');
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.spacingMedium(context)),
                // Priority
                DropdownButtonFormField<Priority>(
                  value: _priority,
                  decoration: InputDecoration(
                    labelText: localizations.getString('priority'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  items:
                      Priority.values.map((priority) {
                        return DropdownMenuItem<Priority>(
                          value: priority,
                          child: Text(
                            localizations.getString(priority.name.capitalize()),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _priority = value;
                      });
                    }
                  },
                ),
                SizedBox(height: AppSizes.spacingMedium(context)),
                // Due Date
                GestureDetector(
                  onTap: () => _selectDueDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: localizations.getString('dueDate'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                    ),
                    child: Text(
                      _dueDate != null
                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                          : localizations.getString('selectDueDate'),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.spacingMedium(context)),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: localizations.getString('taskDescriptionHint'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    hintText: localizations.getString('taskDescriptionHint'),
                  ),
                  maxLines: null, // Allows unlimited line breaks
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize enum names for display
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
