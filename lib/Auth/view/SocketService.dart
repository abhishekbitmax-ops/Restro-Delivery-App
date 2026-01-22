import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';

import 'package:restro_deliveryapp/Homeview/View/Assignordermodel.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:restro_deliveryapp/Homeview/View/Globalnotifactio.dart';

class OrderSocketService extends GetxService {
  late IO.Socket socket;

  /// 🔥 SINGLE SOURCE OF TRUTH (Rx)
  final Rx<AssignedOrderResponse?> assignedOrder = Rx<AssignedOrderResponse?>(
    null,
  );

  AssignedOrderResponse? _lastOrder;
  Timer? _heartbeatTimer;

  // ----------------------------------------------------
  // INIT
  // ----------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    /// 🔔 Notification only when NEW order arrives
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

  // ----------------------------------------------------
  // SOCKET CONNECT
  // ----------------------------------------------------
  Future<OrderSocketService> init() async {
    final token = await SharedPre.getAccessToken();

    socket = IO.io(
      "http://192.168.1.108:5004/orders",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({"token": token})
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    socket.onConnect((_) {
      debugPrint("✅ SOCKET CONNECTED");
      _startHeartbeat(); // ❤️ start 10s heartbeat
    });

    socket.on("CONNECTION_ESTABLISHED", (data) {
      debugPrint("🔥 CONNECTION_ESTABLISHED: $data");
    });

    /// 🔥 SERVER → CLIENT (IMPORTANT FIX)
    socket.on("DELIVERY_ASSIGNED", (data) {
      debugPrint("🔥 DELIVERY_ASSIGNED SOCKET → $data");

      // ✅ ALWAYS CREATE NEW INSTANCE (FOR Obx)
      assignedOrder.value = AssignedOrderResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
    });

    socket.onDisconnect((_) {
      debugPrint("❌ SOCKET DISCONNECTED");
      _stopHeartbeat();
    });

    return this;
  }

  // ----------------------------------------------------
  // ❤️ HEARTBEAT (EVERY 10 SEC)
  // ----------------------------------------------------
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _emitLocation();
    });

    debugPrint("❤️ HEARTBEAT STARTED (10 sec)");
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  // ----------------------------------------------------
  // 📡 EMIT LOCATION ONLY (CLEAN & SAFE)
  // ----------------------------------------------------
  Future<void> _emitLocation() async {
    try {
      final pos = await _getSafeLocation();
      if (pos == null) return;

      final currentOrder = assignedOrder.value;

      socket.emit("UPDATE_LOCATION", {
        "role": "DELIVERY_PARTNER",
        "location": {"lat": pos.latitude, "lng": pos.longitude},
        if (currentOrder != null && currentOrder.data != null)
          "assignedOrder": currentOrder.data!.toJson(),
      });

      // 📡 LOCATION LOG
      debugPrint(
        "📡 UPDATE_LOCATION → lat:${pos.latitude}, lng:${pos.longitude}",
      );

      // 📦 ASSIGNED ORDER LOG
      if (currentOrder != null) {
        debugPrint("📦 ASSIGNED_ORDER → ${currentOrder.toJson()}");
      } else {
        debugPrint("📦 ASSIGNED_ORDER → null");
      }
    } catch (e) {
      debugPrint("❌ HEARTBEAT ERROR: $e");
    }
  }

  // ----------------------------------------------------
  // API → SOCKET BRIDGE
  // ----------------------------------------------------
  void pushOrderFromApi(AssignedOrderResponse order) {
    /// ✅ FORCE NEW INSTANCE (Obx trigger)
    assignedOrder.value = AssignedOrderResponse.fromJson(order.toJson());
  }

  // ----------------------------------------------------
  // SAFE LOCATION
  // ----------------------------------------------------
  Future<Position?> _getSafeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
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
