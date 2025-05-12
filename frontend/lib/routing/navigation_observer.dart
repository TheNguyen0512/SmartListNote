// frontend/lib/routing/navigation_observer.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) {
      print('Navigated to: ${route.settings.name}');
      print('Previous route: ${previousRoute?.settings.name}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) {
      print('Popped: ${route.settings.name}');
      print('Returned to: ${previousRoute?.settings.name}');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode) {
      print('Removed: ${route.settings.name}');
      print('Current route: ${previousRoute?.settings.name}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (kDebugMode) {
      print('Replaced: ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
    }
  }
}