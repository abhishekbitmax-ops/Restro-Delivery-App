import 'dart:async';
import 'dart:convert';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:restro_deliveryapp/utils/background_http_client.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

/// ===============================
/// INIT FOREGROUND SERVICE
/// ===============================
void initForegroundService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      id: 888,
      channelId: 'location_tracking_service',
      channelName: 'Location Tracking',
      channelDescription: 'Real-time delivery location tracking',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      enableVibration: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(10000), // Every 10 seconds
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
  );
}

/// ===============================
/// START TRACKING
/// ===============================
Future<void> startLocationTracking(String token, String customOrderId) async {
  print("\n🚀 STARTING LOCATION TRACKING");

  // ❌ WRONG: await initForegroundService();
  // ✅ CORRECT:
  initForegroundService();

  await FlutterForegroundTask.saveData(key: 'token', value: token);
  await FlutterForegroundTask.saveData(key: 'customOrderId', value: customOrderId);

  await FlutterForegroundTask.startService(
    serviceId: 888,
    notificationTitle: '📍 DELIVERY TRACKING ACTIVE',
    notificationText: 'Sending location to server...',
    callback: startCallback,
  );

  print("✅ FOREGROUND SERVICE STARTED");
}

/// ===============================
/// STOP TRACKING
/// ===============================
Future<void> stopLocationTracking() async {
  print("\n🛑 STOPPING LOCATION TRACKING");
  await FlutterForegroundTask.stopService();
}

/// ===============================
/// TASK HANDLER
/// ===============================
@pragma('vm:entry-point')
class LocationTaskHandler extends TaskHandler {
  String? _token;
  String? _orderId;

  bool _isSending = false;
  static const int _maxRetries = 3;

  static const String _apiUrl = "https://sog.bitmaxtest.com/api/v1/location/update-location";

  Future<void> _updateNotificationSafe(String message) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: '📍 DELIVERY TRACKING',
        notificationText: message,
      );
    } catch (e) {
      print("⚠️ Notification update failed: $e");
    }
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _token = await FlutterForegroundTask.getData<String>(key: 'token');
    _orderId = await FlutterForegroundTask.getData<String>(key: 'customOrderId');

    print("\n🚀 FOREGROUND SERVICE STARTED");
    print("🪪 TOKEN => ${_token != null ? 'YES' : 'NO'}");
    print("📦 ORDER ID => $_orderId");
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    print("\n🔥 REPEAT EVENT @ $timestamp");

    if (_isSending) {
      print("⏳ API still running, skipping tick");
      return;
    }

    try {
      if (_token == null || _orderId == null) {
        print("⚠️ Missing token/orderId");
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _updateNotificationSafe('⚠️ GPS OFF');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _updateNotificationSafe('⚠️ Location permission denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print("📍 ${pos.latitude}, ${pos.longitude}");

      _isSending = true;

      // NON-BLOCKING
      _sendLocationUpdate(pos);

    } catch (e) {
      print("❌ Repeat error => $e");
      _isSending = false;
    }
  }

  Future<void> _sendLocationUpdate(Position pos, [int attempt = 1]) async {
    try {
      print("📤 Sending location (Attempt $attempt/$_maxRetries)");
      print("🌐 URL: $_apiUrl");
      print("🪪 TOKEN: ${_token?.substring(0, 20)}...");
      
      final requestBody = {
        "orderId": _orderId,
        "lat": pos.latitude,
        "lon": pos.longitude,
        "timestamp": DateTime.now().toIso8601String(),
      };
      
      print("📦 REQUEST BODY: ${jsonEncode(requestBody)}");
      final response = await BackgroundHttpClient().post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
        timeout: const Duration(seconds: 15),
      );

      print("📡 RESPONSE STATUS: ${response.statusCode}");
      print("📄 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ API SUCCESS ${response.statusCode}");
        await _updateNotificationSafe('✅ Lat:${pos.latitude.toStringAsFixed(4)} Lon:${pos.longitude.toStringAsFixed(4)}');
        _isSending = false;
      } else {
        print("⚠️ API ERROR ${response.statusCode}");

        if (attempt < _maxRetries) {
          print("🔄 Retrying in ${2 * attempt}s...");
          // Schedule retry without blocking
          Future.delayed(Duration(seconds: 2 * attempt), () {
            _sendLocationUpdate(pos, attempt + 1);
          });
        } else {
          print("❌ Max retries reached");
          _isSending = false;
        }
      }
    } catch (e) {
      print("❌ API exception => $e");

      if (attempt < _maxRetries) {
        print("🔄 Retrying in ${2 * attempt}s...");
        // Schedule retry without blocking
        Future.delayed(Duration(seconds: 2 * attempt), () {
          _sendLocationUpdate(pos, attempt + 1);
        });
      } else {
        print("❌ Max retries reached");
        _isSending = false;
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print("🛑 FOREGROUND SERVICE STOPPED");
  }
}
