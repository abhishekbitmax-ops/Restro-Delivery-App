import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:restro_deliveryapp/Homeview/View/Globalnotifactio.dart';

class OrderSocketService extends GetxService {
  late IO.Socket socket;

  Rx<Map<String, dynamic>?> assignedOrder = Rx<Map<String, dynamic>?>(null);

  Map<String, dynamic>? _lastOrder; // 🔥 track previous

  @override
  void onInit() {
    super.onInit();

    // ⭐ LISTEN TO ANY CHANGE (API OR SOCKET)
    ever<Map<String, dynamic>?>(assignedOrder, (order) {
      if (order != null && _lastOrder == null) {
        // 🔔 PLAY NOTIFICATION ONLY WHEN NEW ORDER COMES
        GlobalNotificationService.show(
          title: "New Order Assigned 🚀",
          message: "A new delivery has been assigned!",
        );
      }

      _lastOrder = order;
    });
  }

  Future<OrderSocketService> init() async {
    final token = await SharedPre.getAccessToken();

    socket = IO.io(
      "https://sog.bitmaxtest.com/orders",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({"token": token})
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    socket.onConnect((_) {
      print("✅ SOCKET CONNECTED");
    });
    socket.on("CONNECTION_ESTABLISHED", (data) {
      print("🔥 CONNECTION_ESTABLISHED: $data");
    });

    socket.on("DELIVERY_ASSIGNED", (data) {
      print("🔥 NEW ORDER FROM SOCKET");
      assignedOrder.value = data["data"]; // 🔥 SAME PIPE
    });

    socket.onDisconnect((_) {
      print("❌ SOCKET DISCONNECTED");
    });

    return this;
  }
}
