import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';

import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/SocketService.dart';
import 'package:restro_deliveryapp/Auth/view/Splash.dart';

Future<void> main() async {
  /// 🔥 VERY IMPORTANT
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ STATUS BAR
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B0000),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  /// ✅ CONTROLLERS
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<OrderSocketService>(OrderSocketService(), permanent: true);

  /// 🔥 FOREGROUND TASK INIT (ONLY ONCE)
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'delivery_tracking',
      channelName: 'Delivery Tracking',
      channelDescription: 'Tracking delivery location in background',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,

      /// 🔴 IMPORTANT (Android 12+)
      enableVibration: false,
      playSound: false,
      showWhen: true,
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,
    ),

    /// 🔥 THIS IS THE KEY PART
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(10000), // ⏱️ 10 sec
      allowWakeLock: true,
      allowWifiLock: true,

      /// 👇 MUST for Maps / background
      autoRunOnBoot: false,
    ),

    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
