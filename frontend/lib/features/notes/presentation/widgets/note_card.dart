import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';

class NoteCard extends StatelessWidget {
  final Note? note;
  final void Function(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) onShowSnackBar;

  const NoteCard({super.key, this.note, required this.onShowSnackBar});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (note == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Note data is unavailable'),
        ),
      );
    }

    return Card(
      child: InkWell(
        child: ListTile(
          leading: IconButton(
            icon: Icon(
              note!.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color:
                  note!.isCompleted
                      ? AppColors.success
                      : theme.unselectedWidgetColor,
              size: AppSizes.iconMedium(context),
            ),
            onPressed: () async {
              if (note!.id != null) {
                try {
                  await noteProvider.toggleNoteStatus(note!.id!);
                } catch (e) {
                  onShowSnackBar(localizations.getString('updateFailed'));
                }
              }
            },
          ),
          title: Text(note!.title, style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.fontTitle,
            color: note!.isCompleted
                ? AppColors.success
                : theme.textTheme.bodyLarge?.color,
          )),
          subtitle:
              note!.description.isNotEmpty
                  ? Text(
                      note!.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (note!.id != null) {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(localizations.getString('confirmDelete')),
                        content: Text(localizations.getString('deleteNoteConfirmation')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(localizations.getString('cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(localizations.getString('delete')),
                          ),
                        ],
                      ),
                );

                if (shouldDelete == true) {
                  final deletedNote = note!;
                  try {
                    await noteProvider.deleteNote(note!.id!);
                    onShowSnackBar(
                      localizations.getString('noteDeleted'),
                      actionLabel: localizations.getString('undo'),
                      onAction: () async {
                        try {
                          await noteProvider.addNote(deletedNote);
                        } catch (e) {
                          onShowSnackBar(localizations.getString('undoFailed'));
                        }
                      },
                    );
                  } catch (e) {
                    onShowSnackBar(localizations.getString('deleteFailed'));
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }
}