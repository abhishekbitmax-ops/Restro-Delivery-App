import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 🔥 APP LIFECYCLE MANAGER
/// Manages app state transitions without cancelling background operations
class AppLifecycleManager {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();

  factory AppLifecycleManager() {
    return _instance;
  }

  AppLifecycleManager._internal();

  bool _isAppInBackground = false;
  bool _isAppPaused = false;

  bool get isAppInBackground => _isAppInBackground;
  bool get isAppPaused => _isAppPaused;

  /// Track app lifecycle
  void monitorAppLifecycle() {
    WidgetsBinding.instance.addObserver(
      _AppLifecycleObserver(
        onResumed: _onAppResumed,
        onPaused: _onAppPaused,
        onDetached: _onAppDetached,
        onInactive: _onAppInactive,
      ),
    );
  }

  void _onAppResumed() {
    print("🟢 APP RESUMED - Background operations continue");
    _isAppInBackground = false;
    _isAppPaused = false;
  }

  void _onAppPaused() {
    print("🟡 APP PAUSED - Background operations CONTINUE (not cancelled)");
    _isAppPaused = true;
  }

  void _onAppInactive() {
    print("🟠 APP INACTIVE - Background operations CONTINUE");
    _isAppInBackground = true;
  }

  void _onAppDetached() {
    print("🔴 APP DETACHED - Background services still running");
    _isAppInBackground = true;
  }
}

/// Lifecycle observer for the app
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final Function() onResumed;
  final Function() onPaused;
  final Function() onInactive;
  final Function() onDetached;

  _AppLifecycleObserver({
    required this.onResumed,
    required this.onPaused,
    required this.onInactive,
    required this.onDetached,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.hidden:
        onInactive();
        break;
    }
  }
}
