// frontend/lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartlist/core/constants/strings.dart';
import 'package:smartlist/localization/app_localizations.dart';
import 'package:smartlist/localization/locale_provider.dart';
import 'package:smartlist/features/auth/domain/providers/auth_provider.dart';
import 'package:smartlist/features/notes/domain/providers/note_provider.dart';
import 'package:smartlist/routing/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..refreshAuthState()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            locale: localeProvider.locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            title: 'To-do List App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
          );
        },
      ),
    );
  }
}