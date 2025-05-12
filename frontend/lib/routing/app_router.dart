// frontend/lib/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartlist/features/auth/domain/providers/auth_provider.dart';
import 'package:smartlist/features/auth/presentation/screens/login_screen.dart';
import 'package:smartlist/features/auth/presentation/screens/register_screen.dart';
import 'package:smartlist/features/notes/domain/entities/note.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';
import 'package:smartlist/features/notes/presentation/screens/add_note_screen.dart';
import 'package:smartlist/features/notes/presentation/screens/note_list_screen.dart';
import 'package:smartlist/features/setting/presentation/screens/help_center_screen.dart';
import 'package:smartlist/features/setting/presentation/screens/privacy_policy_screen.dart';
import 'package:smartlist/features/setting/presentation/screens/settings_screen.dart';
import 'package:smartlist/features/setting/presentation/screens/terms_of_service_screen.dart';
import 'package:smartlist/routing/navigation_observer.dart';
import 'package:smartlist/routing/route_paths.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: RoutePaths.noteList,
    observers: [NavigationObserver()],
    redirect: (BuildContext context, GoRouterState state) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;

      // Nếu chưa đăng nhập và cố truy cập các route ngoài login/register
      if (!isAuthenticated &&
          state.matchedLocation != RoutePaths.login &&
          state.matchedLocation != RoutePaths.register) {
        return RoutePaths.login;
      }

      // Nếu đã đăng nhập và cố truy cập login/register
      if (isAuthenticated &&
          (state.matchedLocation == RoutePaths.login ||
              state.matchedLocation == RoutePaths.register)) {
        return RoutePaths.noteList;
      }

      // Đảm bảo không chuyển hướng vô hạn khi trạng thái không rõ ràng
      if (state.matchedLocation == RoutePaths.login && !isAuthenticated) {
        return null; // Cho phép hiển thị login nếu chưa đăng nhập
      }

      return null; // Không chuyển hướng nếu không cần
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.noteList,
        builder: (context, state) => const NoteListScreen(),
      ),
      GoRoute(
        path: RoutePaths.addNote,
        builder: (context, state) {
          return AddNoteScreen(
            onShowSnackBar: (message, {actionLabel, onAction}) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  action:
                      actionLabel != null && onAction != null
                          ? SnackBarAction(
                            label: actionLabel,
                            onPressed: onAction,
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.editNote,
        builder: (context, state) {
          final noteId = state.pathParameters['id'];
          final noteProvider = Provider.of<NoteProvider>(
            context,
            listen: false,
          );
          final note = noteProvider.notes.firstWhere(
            (note) => note.id == noteId,
            orElse:
                () => Note(
                  id: noteId,
                  title: '',
                  description: '',
                  priority: Priority.medium,
                  isCompleted: false,
                ),
          );

          return AddNoteScreen(
            noteToEdit: note,
            onShowSnackBar: (message, {actionLabel, onAction}) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  action:
                      actionLabel != null && onAction != null
                          ? SnackBarAction(
                            label: actionLabel,
                            onPressed: onAction,
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'help-center',
            builder: (context, state) => const HelpCenterScreen(),
          ),
          GoRoute(
            path: 'privacy-policy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
          GoRoute(
            path: 'terms-of-service',
            builder: (context, state) => const TermsOfServiceScreen(),
          ),
        ],
      ),
    ],
  );
}
