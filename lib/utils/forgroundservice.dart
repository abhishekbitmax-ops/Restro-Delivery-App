import 'dart:convert';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  String? _token;
  String? _orderId;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _token = await FlutterForegroundTask.getData<String>(key: 'token');
    _orderId = await FlutterForegroundTask.getData<String>(key: 'orderId');

    print("🚀 FOREGROUND SERVICE STARTED");
    print("🪪 TOKEN => ${_token != null}");
    print("📦 ORDER ID => $_orderId");
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    print("🔥 onRepeatEvent fired at $timestamp");

    try {
      if (_token == null || _orderId == null) {
        print("⚠️ Missing token/orderId");
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("⚠️ Location service OFF");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("⚠️ Location permission denied");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("📍 LOCATION => ${pos.latitude}, ${pos.longitude}");

      final uri = Uri.parse(
        "http://192.168.1.108:5004/api/v1/location/update-location",
      );

      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer $_token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "orderId": _orderId,
          "lat": pos.latitude,
          "lon": pos.longitude,
        }),
      );

      print("📡 API STATUS => ${response.statusCode}");
      print("📡 API BODY => ${response.body}");
    } catch (e) {
      print("❌ BG ERROR => $e");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print("🛑 FOREGROUND SERVICE STOPPED");
  }
}