import 'package:flutter/material.dart';
import '../core/constants/strings.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String getString(String key) {
    return AppStrings.get(key, locale);
  }

   String get appTitle => getString('appTitle');
  String get taskListTitle => getString('taskListTitle');
  String get addTask => getString('addTask');
  String get editTask => getString('editTask');
  String get deleteTask => getString('deleteTask');
  String get taskTitleHint => getString('taskTitleHint');
  String get taskDescriptionHint => getString('taskDescriptionHint');
  String get cancel => getString('cancel');
  String get save => getString('save');
  String get noTasks => getString('noTasks');
  String get analyticsTitle => getString('analyticsTitle');
  String get teamTitle => getString('teamTitle');
  String get priority => getString('priority');
  String get priorityLow => getString('priorityLow');
  String get priorityMedium => getString('priorityMedium');
  String get priorityHigh => getString('priorityHigh');
  String get titleRequired => getString('titleRequired');
  String get selectDueDate => getString('selectDueDate');
  String get noDueDate => getString('noDueDate');
  String get dueDate => getString('dueDate');
  String get settings => getString('settings');
  String get language => getString('language');
  String get english => getString('english');
  String get vietnamese => getString('vietnamese');
  String get confirmDeleteTitle => getString('confirmDeleteTitle');
  String get confirmDeleteMessage => getString('confirmDeleteMessage');
  String get loginTitle => getString('loginTitle');
  String get registerTitle => getString('registerTitle');
  String get emailHint => getString('emailHint');
  String get passwordHint => getString('passwordHint');
  String get loginButton => getString('loginButton');
  String get registerButton => getString('registerButton');
  String get logout => getString('logout');
  String get registerLink => getString('registerLink');
  String get loginLink => getString('loginLink');
  String get emailRequired => getString('emailRequired');
  String get passwordRequired => getString('passwordRequired');
  String get invalidEmail => getString('invalidEmail');
  String get weakPassword => getString('weakPassword');
  String get emailInUse => getString('emailInUse');
  String get wrongCredentials => getString('wrongCredentials');
  String get loginSuccess => getString('loginSuccess');
  String get registerSuccess => getString('registerSuccess');
  String get logoutSuccess => getString('logoutSuccess');
  String get retry => getString('retry');
  String get taskDeleted => getString('taskDeleted');
  String get undo => getString('undo');
  String get refresh => getString('refresh');
  String get deleteFailed => getString('deleteFailed');
  String get updateFailed => getString('updateFailed');
  String get userNotLoggedIn => getString('userNotLoggedIn');
  String get failedToLoadTasks => getString('failedToLoadTasks');
  String get failedToAddTask => getString('failedToAddTask');
  String get taskCompleted => getString('taskCompleted');
  String get taskNotCompleted => getString('taskNotCompleted');
  String get taskUpdated => getString('taskUpdated');
  String get taskAdded => getString('taskAdded');
  String get confirmDelete => getString('confirmDelete');
  String get deleteTaskConfirmation => getString('deleteTaskConfirmation');
  String get delete => getString('delete');
  String get taskAddedSuccess => getString('taskAddedSuccess');
  String get add => getString('add');
  String get confirmLogout => getString('confirmLogout');
  String get logoutConfirmation => getString('logoutConfirmation');
  String get welcomeBack => getString('welcomeBack');
  String get forgotPassword => getString('forgotPassword');
  String get noAccount => getString('noAccount');
  String get orContinueWith => getString('orContinueWith');
  String get termsAndPrivacy => getString('termsAndPrivacy');
  String get networkError => getString('networkError');
  String get tooManyRequests => getString('tooManyRequests');
  String get low => getString('low');
  String get medium => getString('medium');
  String get high => getString('high');
  String get taskUpdatedSuccess => getString('taskUpdatedSuccess');
  String get taskDeletedSuccess => getString('taskDeletedSuccess');
  String get confirmExit => getString('confirmExit');
  String get unsavedChanges => getString('unsavedChanges');
  String get discard => getString('discard');
  String get networkErrorDuringLogout => getString('networkErrorDuringLogout');
  String get googleSignInCancelled => getString('googleSignInCancelled');
  String get googleSignInFailed => getString('googleSignInFailed');
  String get facebookSignInFailed => getString('facebookSignInFailed');
  String get appleSignInCancelled => getString('appleSignInCancelled');
  String get appleSignInFailed => getString('appleSignInFailed');
  String get logoutFailed => getString('logoutFailed');
  String get authError => getString('authError');
  String get fullNameHint => getString('fullNameHint');
  String get confirmPasswordHint => getString('confirmPasswordHint');
  String get fullNameRequired => getString('fullNameRequired');
  String get confirmPasswordRequired => getString('confirmPasswordRequired');
  String get passwordStrength => getString('passwordStrength');
  String get passwordsNotMatch => getString('passwordsNotMatch');
  String get alreadyHaveAccount => getString('alreadyHaveAccount');
  String get due => getString('due');
  String get calendarPreferences => getString('calendarPreferences');
  String get calendarView => getString('calendarView');
  String get timeFormat => getString('timeFormat');
  String get firstDayOfWeek => getString('firstDayOfWeek');
  String get taskManagement => getString('taskManagement');
  String get defaultTaskPriority => getString('defaultTaskPriority');
  String get taskDueDateFormat => getString('taskDueDateFormat');
  String get taskSortingPreferences => getString('taskSortingPreferences');
  String get notifications => getString('notifications');
  String get taskDueReminders => getString('taskDueReminders');
  String get upcomingTasksAlerts => getString('upcomingTasksAlerts');
  String get notificationSound => getString('notificationSound');
  String get vibration => getString('vibration');
  String get appearance => getString('appearance');
  String get theme => getString('theme');  
  String get textSize => getString('textSize');
  String get accountSettings => getString('accountSettings');  
  String get changePassword => getString('changePassword');  
  String get syncWithCloud => getString('syncWithCloud');  
  String get exportData => getString('exportData');
  String get aboutHelp => getString('aboutHelp');
  String get helpCenter => getString('helpCenter');
  String get privacyPolicy => getString('privacyPolicy');
  String get termsOfService => getString('termsOfService');
  String get version => getString('version');
  String get errorSavingTask => getString('errorSavingTask');

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
