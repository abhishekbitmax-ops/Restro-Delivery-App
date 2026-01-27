import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';

import 'package:restro_deliveryapp/Homeview/View/Assignordermodel.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:restro_deliveryapp/Homeview/View/Globalnotifactio.dart';

class OrderSocketService extends GetxService {
  late IO.Socket socket;

  /// 🔥 SINGLE SOURCE OF TRUTH
  final Rxn<AssignedOrderResponse> assignedOrder = Rxn<AssignedOrderResponse>();

  AssignedOrderResponse? _lastOrder;
  Timer? _heartbeatTimer;
  bool _isConnected = false;

  @override
  void onInit() {
    super.onInit();

    ever<AssignedOrderResponse?>(assignedOrder, (order) {
      if (order != null && _lastOrder == null) {
        GlobalNotificationService.show(
          title: "New Order Assigned 🚀",
          message: "A new delivery has been assigned!",
        );
      }
      _lastOrder = order;
    });
  }

  Future<OrderSocketService> init() async {
    if (_isConnected) {
      debugPrint("⚠️ SOCKET ALREADY CONNECTED");
      return this;
    }

    final token = await SharedPre.getAccessToken();
    if (token.isEmpty) {
      debugPrint("❌ SOCKET INIT FAILED: TOKEN EMPTY");
      return this;
    }

    _isConnected = true;

    socket = IO.io(
      "http://192.168.1.108:5004/orders",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({"token": token})
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    socket.onConnect((_) async {
      debugPrint("✅ SOCKET CONNECTED");
      _startHeartbeat();

      /// 🔥 API SYNC ON CONNECT
      final auth = Get.find<AuthController>();
      await auth.getAssignedOrderFromApi();
    });

    socket.on("DELIVERY_ASSIGNED", (data) {
      debugPrint("🔥 DELIVERY_ASSIGNED SOCKET → $data");

      final mappedData = {
        "order": {
          "id": data["orderId"],
          "orderId": data["customOrderId"],
          "status": data["status"],
          "total": data["price"]?["grandTotal"],
        },
        "customer": data["customer"],
        "deliveryAddress": data["location"], // rename
        "items": (data["items"] as List).map((item) {
          return {
            "itemId": {
              "_id": item["itemId"], // 🔥 STRING → MAP
              "name": item["name"],
            },
            "name": item["name"],
            "quantity": item["quantity"],
            "basePrice": item["basePrice"],
            "addons": item["addons"],
            "finalItemPrice": item["finalItemPrice"],
          };
        }).toList(),
        "assignedAt": data["assignedAt"],
      };

      assignedOrder.value = AssignedOrderResponse.fromJson({
        "success": true,
        "data": mappedData,
      });
    });

    socket.onDisconnect((_) {
      debugPrint("❌ SOCKET DISCONNECTED");
      _isConnected = false;
      _stopHeartbeat();
    });

    return this;
  }

  // ❤️ HEARTBEAT
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _emitLocation();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _emitLocation() async {
    try {
      final pos = await _getSafeLocation();
      if (pos == null) {
        debugPrint("⚠️ LOCATION NULL, SKIPPING EMIT");
        return;
      }

      final currentOrder = assignedOrder.value;

      socket.emit("UPDATE_LOCATION", {
        "role": "DELIVERY_PARTNER",
        "location": {"lat": pos.latitude, "lng": pos.longitude},
        if (currentOrder?.data != null)
          "assignedOrder": currentOrder!.data!.toJson(),
      });
    } catch (e) {
      debugPrint("❌ HEARTBEAT ERROR: $e");
    }
  }

  /// 🔥 API → SOCKET BRIDGE (FIXED)
  void pushOrderFromApi(AssignedOrderResponse order) {
    assignedOrder.value = order;
  }

  Future<Position?> _getSafeLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  void onClose() {
    _stopHeartbeat();
    socket.dispose();
    super.onClose();
  }
}
