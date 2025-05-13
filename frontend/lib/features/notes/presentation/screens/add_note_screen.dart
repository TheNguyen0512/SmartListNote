import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smartlist/routing/route_paths.dart';

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
  bool _hasChanges = false;

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

    _titleController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _titleController.removeListener(_checkForChanges);
    _descriptionController.removeListener(_checkForChanges);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final initialNote = widget.noteToEdit;
    if (initialNote == null) {
      setState(() {
        _hasChanges =
            _titleController.text.isNotEmpty ||
            _descriptionController.text.isNotEmpty ||
            _dueDate != null ||
            _priority != Priority.medium;
      });
    } else {
      setState(() {
        _hasChanges =
            _titleController.text != initialNote.title ||
            _descriptionController.text != (initialNote.description) ||
            _dueDate != initialNote.dueDate ||
            _priority != initialNote.priority;
      });
    }
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
        _checkForChanges();
      });
    }
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final localizations = AppLocalizations.of(context)!;
      final isOnline = await _isOnline();

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
          if (noteProvider.errorMessage != null) {
            widget.onShowSnackBar(
              localizations.getString(noteProvider.errorMessage!),
            );
          } else {
            widget.onShowSnackBar(
              localizations.getString(
                isOnline
                    ? (noteProvider.syncStatus ?? 'noteAdded')
                    : 'savedOffline',
              ),
            );
            if (context.mounted) {
              context.go(
                RoutePaths.noteList,
              ); // Sử dụng GoRouter thay Navigator.pop
            }
          }
        } else {
          // Update existing note
          await noteProvider.updateNote(newNote);
          if (noteProvider.errorMessage != null) {
            widget.onShowSnackBar(
              localizations.getString(noteProvider.errorMessage!),
            );
          } else {
            widget.onShowSnackBar(
              localizations.getString(
                isOnline
                    ? (noteProvider.syncStatus ?? 'noteUpdated')
                    : 'savedOffline',
              ),
            );
            if (context.mounted) {
              context.go(
                RoutePaths.noteList,
              ); // Sử dụng GoRouter thay Navigator.pop
            }
          }
        }
      } catch (e) {
        debugPrint('Error saving note: $e');
        widget.onShowSnackBar(
          localizations.getString(
            isOnline ? 'failedToAddNote' : 'savedOffline',
          ),
        );
        if (!isOnline && context.mounted) {
          context.go(
            RoutePaths.noteList,
          ); // Sử dụng GoRouter thay Navigator.pop
        }
      }
    }
  }

  Future<void> _onPopInvoked(bool didPop) async {
    if (didPop) return; // If already popped, do nothing

    final localizations = AppLocalizations.of(context)!;
    if (!_hasChanges) {
      if (context.mounted) {
        context.go(RoutePaths.noteList);
      }
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.getString('confirmExit')),
            content: Text(localizations.getString('unsavedChanges')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: Text(localizations.getString('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'discard'),
                child: Text(
                  localizations.getString('discard'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'save'),
                child: Text(localizations.getString('save')),
              ),
            ],
          ),
    );

    if (result == 'save') {
      await _saveNote();
    } else if (result == 'discard' && context.mounted) {
      context.go(RoutePaths.noteList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.noteToEdit == null
                ? localizations.getString('addTask')
                : localizations.getString('editTask'),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onPopInvoked(false),
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
                              localizations.getString(
                                priority.name.capitalize(),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _priority = value;
                          _checkForChanges();
                        });
                      }
                    },
                  ),
                  SizedBox(height: AppSizes.spacingMedium(context)),
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
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
