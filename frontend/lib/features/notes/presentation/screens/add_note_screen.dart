import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? noteToEdit;
  final Function(String message, {String? actionLabel, VoidCallback? onAction})
  onShowSnackBar;

  const AddNoteScreen({
    super.key,
    this.noteToEdit,
    required this.onShowSnackBar,
  });

  @override
  AddNoteScreenState createState() => AddNoteScreenState();
}

class AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  Priority _priority = Priority.medium;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.noteToEdit?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.noteToEdit?.description ?? '',
    );
    _dueDate = widget.noteToEdit?.dueDate;
    _priority = widget.noteToEdit?.priority ?? Priority.medium;
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

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final localizations = AppLocalizations.of(context)!;

      final newNote = Note(
        id: widget.noteToEdit?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: widget.noteToEdit?.isCompleted ?? false,
      );

      try {
        if (widget.noteToEdit == null) {
          // Add new note
          await noteProvider.addNote(newNote);
          widget.onShowSnackBar(localizations.getString('taskAdded'));
        } else {
          // Update existing note
          await noteProvider.updateNote(newNote);
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
          widget.noteToEdit == null
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
            onPressed: _saveNote,
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