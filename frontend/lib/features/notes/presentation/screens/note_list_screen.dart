// frontend/lib/features/notes/presentation/screens/note_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/core/constants/colors.dart';
import 'package:smartlist/core/constants/sizes.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/routing/route_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  NoteListScreenState createState() => NoteListScreenState();
}

class NoteListScreenState extends State<NoteListScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        Provider.of<NoteProvider>(context, listen: false).loadNotes();
        _isInitialized = true;
      }
    });
  }

  Future<bool> _onWillPop() async => true;

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
      setState(() => _selectedIndex = 0);
    } else if (index == 2) {
      context.go(RoutePaths.settings);
      setState(() => _selectedIndex = 0);
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
            (actionLabel != null && onAction != null)
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
          automaticallyImplyLeading: false,
        ),
        body: Consumer<NoteProvider>(
          builder: (context, provider, child) {
            // Show SnackBar for sync status
            if (provider.syncStatus == 'offlineSynced') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showSnackBar(localizations.getString('offlineSynced'));
                provider.clearSyncStatus();
              });
            }

            // Show loading only if no notes are available
            if (provider.isLoading && provider.notes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error only if no notes are available and there's an error
            if (provider.errorMessage != null && provider.notes.isEmpty) {
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
                      onPressed: () => provider.loadNotes(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(localizations.getString('retry')),
                    ),
                  ],
                ),
              );
            }

            // Show notes or empty state
            return RefreshIndicator(
              onRefresh: () async {
                final provider = Provider.of<NoteProvider>(
                  context,
                  listen: false,
                );
                final stopwatch = Stopwatch()..start();
                await provider.loadNotes();
                final elapsed = stopwatch.elapsed;
                if (elapsed < const Duration(seconds: 1)) {
                  await Future.delayed(const Duration(seconds: 1) - elapsed);
                }
              },
              child:
                  provider.notes.isEmpty
                      ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.note_outlined,
                                  size: AppSizes.iconLarge(context),
                                  color: Theme.of(context).disabledColor,
                                ),
                                SizedBox(
                                  height: AppSizes.spacingMedium(context),
                                ),
                                Text(
                                  localizations.getString('noTasks'),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : Padding(
                        padding: EdgeInsets.all(AppSizes.paddingMedium),
                        child: ListView.separated(
                          itemCount: provider.notes.length,
                          separatorBuilder:
                              (context, index) => SizedBox(
                                height: AppSizes.spacingMedium(context),
                              ),
                          itemBuilder: (context, index) {
                            final note = provider.notes[index];
                            if (note.id == null) return const SizedBox.shrink();

                            return GestureDetector(
                              onTap: () {
                                context.go(
                                  RoutePaths.editNote.replaceFirst(
                                    ':id',
                                    note.id!,
                                  ),
                                );
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
                                    GestureDetector(
                                      onTap: () {
                                        provider.toggleNoteStatus(note.id!);
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
                                              note.isCompleted
                                                  ? AppColors.primary
                                                  : Colors.transparent,
                                        ),
                                        child:
                                            note.isCompleted
                                                ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                                : null,
                                      ),
                                    ),
                                    SizedBox(
                                      width: AppSizes.spacingMedium(context),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  note.title,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        note.isCompleted
                                                            ? Colors
                                                                .grey
                                                                .shade400
                                                            : Colors
                                                                .grey
                                                                .shade800,
                                                    decoration:
                                                        note.isCompleted
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : null,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _getPriorityColor(
                                                    note.priority,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${localizations.getString('due')} ${_formatDate(note.dueDate)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            final localizations =
                                                AppLocalizations.of(context)!;
                                            return AlertDialog(
                                              title: Text(
                                                localizations.getString(
                                                  'confirmDeleteTitle',
                                                ),
                                              ),
                                              content: Text(
                                                localizations.getString(
                                                  'confirmDeleteMessage',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text(
                                                    localizations.getString(
                                                      'cancel',
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    final provider =
                                                        Provider.of<
                                                          NoteProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        );
                                                    await provider.deleteNote(
                                                      note.id!,
                                                    );
                                                    if (provider.errorMessage ==
                                                        null) {
                                                      _showSnackBar(
                                                        localizations.getString(
                                                          provider.syncStatus ??
                                                              'noteDeleted',
                                                        ),
                                                      );
                                                    } else {
                                                      _showSnackBar(
                                                        localizations.getString(
                                                          provider
                                                              .errorMessage!,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    localizations.getString(
                                                      'delete',
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go(RoutePaths.addNote);
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
              icon: const Icon(Icons.note),
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
