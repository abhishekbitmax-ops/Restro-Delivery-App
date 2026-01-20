import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restro_deliveryapp/Auth/view/SocketService.dart';
import 'package:restro_deliveryapp/Auth/view/Splash.dart';

Future<void> main() async {
  // ✅ STEP 1: MUST be first
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ STEP 2: Status bar setup
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B0000),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ✅ STEP 3: Init socket service ONCE (GLOBAL)
  await Get.putAsync<OrderSocketService>(
    () async => await OrderSocketService().init(),
    permanent: true, // ⭐ VERY IMPORTANT
  );

  // ✅ STEP 4: Run app
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
