import 'package:restro_deliveryapp/utils/forgroundservice.dart';

/// 🚀 START LOCATION TRACKING - Call this when delivery starts
Future<void> startDeliveryTracking(String authToken, String orderId) async {
  print("\n🚀 STARTING DELIVERY LOCATION TRACKING");
  print("   Token: ${authToken.substring(0, 30)}...");
  print("   OrderId: $orderId\n");
  
  await startLocationTracking(authToken, orderId);
}

/// 🛑 STOP LOCATION TRACKING - Call this when delivery ends
Future<void> stopDeliveryTracking() async {
  print("\n🛑 STOPPING DELIVERY LOCATION TRACKING\n");
  
  await stopLocationTracking();
}
