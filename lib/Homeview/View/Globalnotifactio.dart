import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

class GlobalNotificationService {
  static void show({
    required String title,
    required String message,
    Color bgColor = Colors.green,
  }) {
    // 🔔 PLAY NOTIFICATION SOUND (INSTANCE BASED)
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      volume: 1.0,
      looping: false,
      asAlarm: false,
    );

    // 📢 SHOW SNACKBAR
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
