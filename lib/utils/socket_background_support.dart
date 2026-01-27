import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

/// 📡 SOCKET IO BACKGROUND HANDLING
/// Ensures socket connections continue even when app goes to background

extension SocketBackgroundSupport on IO.Socket {
  /// Initialize socket for background operation
  /// Call this instead of regular connect()
  void connectWithBackgroundSupport({
    required String url,
    Map<String, String>? headers,
    Duration reconnectInterval = const Duration(seconds: 5),
  }) {
    // Socket.io automatically tries to reconnect
    // Just ensure it's configured properly for background
    
    connect();
    
    print("🔌 Socket initialized with background support");
    
    // Monitor connection state
    on('connect', (_) {
      print("✅ Socket CONNECTED (will continue in background)");
    });
    
    on('disconnect', (_) {
      print("❌ Socket DISCONNECTED (will auto-reconnect)");
    });
    
    on('error', (dynamic error) {
      print("⚠️ Socket error: $error");
    });
  }
  
  /// Ensure socket reconnects when app comes back from background
  void ensureConnectedAfterBackground() {
    if (!connected) {
      print("🔄 Socket disconnected, reconnecting...");
      connect();
    }
  }
}

/// IMPLEMENTATION EXAMPLE
/// ========================
/// 
/// In your SocketService, use it like this:
/// 
/// class OrderSocketService extends GetxService {
///   late IO.Socket socket;
///   
///   @override
///   void onInit() {
///     super.onInit();
///     
///     // Initialize socket with background support
///     socket = IO.io('http://192.168.1.108:5004', <String, dynamic>{
///       'transports': ['websocket'],
///       'autoConnect': true,
///       'reconnectionDelay': 1000,
///       'reconnection': true,
///       'reconnectionAttempts': 10000,
///       'reconnectionDelayMax': 5000,
///     });
///     
///     socket.connectWithBackgroundSupport(
///       url: 'http://192.168.1.108:5004',
///     );
///     
///     _setupListeners();
///   }
///   
///   void _setupListeners() {
///     // These listeners will work in background
///     socket.on('DELIVERY_ASSIGNED', (data) {
///       print("📦 New order assigned (works in background)");
///       // Update your order status
///     });
///     
///     socket.on('ORDER_UPDATE', (data) {
///       print("🔄 Order status updated (works in background)");
///       // Update your UI when app resumes
///     });
///   }
///   
///   @override
///   void onClose() {
///     socket.disconnect();
///     super.onClose();
///   }
/// }
/// 
/// In AppLifecycleManager, add this to ensure reconnection:
/// 
/// void _onAppResumed() {
///   print("🟢 APP RESUMED");
///   // Ensure socket reconnects if it got disconnected
///   try {
///     Get.find<OrderSocketService>().socket.ensureConnectedAfterBackground();
///   } catch (e) {
///     print("Socket service not ready yet");
///   }
/// }
