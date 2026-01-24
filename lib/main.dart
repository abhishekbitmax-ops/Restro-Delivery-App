import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';

import 'package:restro_deliveryapp/Auth/view/SocketService.dart';
import 'package:restro_deliveryapp/Auth/view/Splash.dart';

Future<void> main() async {
  /// ✅ MUST BE FIRST
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ STATUS BAR
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B0000),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  Get.put<AuthController>(AuthController(), permanent: true);

  /// ✅ REGISTER SOCKET SERVICE (NOT CONNECT YET)
  Get.put<OrderSocketService>(OrderSocketService(), permanent: true);

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
