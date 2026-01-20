import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/Orderpickup.dart';
import 'package:restro_deliveryapp/Auth/view/Orders.dart';
import 'package:restro_deliveryapp/Auth/view/SocketService.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final OrderSocketService socketService = Get.find<OrderSocketService>();

  bool isOnline = true;
  Future<void> fetchAssignedOrderFromApi() async {
    await auth.getAssignedOrderFromApi();
  }

  Timer? _assignedOrderTimer;

  bool isLoading = true; // ⭐ NEW — shimmer controller

  final AuthController auth = Get.put(AuthController());

  String? userName;

  List<dynamic> activeOrdersData = [];
  List<dynamic> completedOrdersData = [];
  Future<void> _onRefresh() async {
    await loadOrderData();
  }

  int activeOrders = 0;
  int completedOrders = 0;
  int orderCount = 0;

  late FlutterRingtonePlayer ringtonePlayer;

  @override
  void initState() {
    super.initState();

    fetchUserName();
    loadOrderData();

    // 🔥 immediate hit (first time)
    fetchAssignedOrderFromApi();

    // 🔁 silent polling every 5 seconds
    startAssignedOrderPolling();
  }

  // ⭐ FETCH USERNAME
  void fetchUserName() async {
    var profile = await auth.getProfile();

    if (mounted) {
      setState(() {
        userName = profile?.data?.name ?? "";
      });
    }
  }

  Future<void> loadOrderData() async {
    setState(() => isLoading = true);

    final active = await auth.getActiveOrder();
    final completed = await auth.getCompletedOrder();
    final count = await auth.getOrderCount();

    if (!mounted) return;

    setState(() {
      activeOrdersData = active?["data"] ?? [];
      completedOrdersData = completed?["data"] ?? [];

      activeOrders = activeOrdersData.length;
      completedOrders = completedOrdersData.length;

      orderCount = count?["data"]?["activeOrders"] ?? 0;
      isLoading = false;
    });
  }

  // ⭐ STATUS CARD WIDGET
  Widget _statusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.06)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                blurRadius: 26,
                color: color.withOpacity(0.18),
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 20),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startAssignedOrderPolling() {
    _assignedOrderTimer?.cancel();

    _assignedOrderTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await auth.getAssignedOrderFromApi();
    });
  }

  @override
  void dispose() {
    _assignedOrderTimer?.cancel();
    super.dispose();
  }

  // ⭐ SHIMMER: HEADER
  Widget shimmerHeader(double topPadding) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Container(
        padding: EdgeInsets.only(
          top: topPadding + 18,
          bottom: 28,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7A0000), Color(0xFFB11212)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 120, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 80, color: Colors.white),
                  ],
                ),
                const Spacer(),
                Container(
                  height: 33,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 20, width: 160, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ⭐ SHIMMER: STATUS CARDS
  Widget shimmerStatusCards() {
    return Row(
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ⭐ SHIMMER: ORDER ASSIGNMENT
  Widget shimmerOrderCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF7A0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ColorFiltered(
      colorFilter: isOnline
          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
          : const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: isLoading
            ? Column(
                children: [
                  shimmerHeader(topPadding),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                      child: Column(
                        children: [
                          shimmerStatusCards(),
                          const SizedBox(height: 42),
                          shimmerOrderCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  /// ⭐ HEADER
                  Container(
                    padding: EdgeInsets.only(
                      top: topPadding + 18,
                      bottom: 28,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7A0000), Color(0xFFB11212)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 14,
                                    color: Colors.black.withOpacity(0.35),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/restro_logo.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Swaad of Grandmaa",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Delivery Partner Dashboard",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            /// Online switch
                            GestureDetector(
                              onTap: () async {
                                var result = await auth.toggleOnlineStatus();

                                if (result != null &&
                                    result["success"] == true) {
                                  setState(() {
                                    isOnline = result["data"]["isOnline"];
                                  });

                                  Get.snackbar(
                                    "Status Updated",
                                    result["message"],
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "Unable to change status",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 60,
                                height: 33,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isOnline
                                      ? const Color(0xFF1E6F4F)
                                      : const Color(0xFF3A3A3A),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 250),
                                  alignment: isOnline
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            userName == null || userName!.isEmpty
                                ? "Welcome back "
                                : "Welcome back, $userName ",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ⭐ BODY
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF8B0000),
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _statusCard(
                                  title: "Active Orders",
                                  value: activeOrders.toString(),
                                  icon: Icons.delivery_dining_outlined,
                                  color: const Color(0xFF8B0000),
                                  onTap: () => Get.to(
                                    () => const MyOrdersScreen(defaultTab: 0),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                _statusCard(
                                  title: "Completed",
                                  value: completedOrders.toString(),
                                  icon: Icons.check_circle_outline,
                                  color: Colors.green,
                                  onTap: () => Get.to(
                                    () => const MyOrdersScreen(defaultTab: 1),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 42),
                            Text(
                              "Current Assignment",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 18),

                            /// ⭐ REAL-TIME ORDER UI
                            Obx(() {
                              final order = socketService.assignedOrder.value;

                              if (order == null) {
                                return Center(
                                  child: Text(
                                    "No Order Assigned",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: () => Get.to(
                                  () => PickupScreen(orderData: order),
                                ),
                                child: _assignedOrderCardUI(order),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _assignedOrderCardUI(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.red.shade50]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            color: Colors.red.withOpacity(0.22),
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B0000),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "ORDER ASSIGNED",
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black45,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            "Order ID: ${order['order']?['orderId'] ?? '-'}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Customer: ${order['customer']?['name'] ?? '-'}",
            style: GoogleFonts.poppins(fontSize: 14),
          ),

          Text(
            "Phone: ${order['customer']?['phone'] ?? '-'}",
            style: GoogleFonts.poppins(fontSize: 13),
          ),

          const SizedBox(height: 12),

          Text(
            "Items:",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          ...((order["items"] ?? []) as List).map(
            (item) => Text(
              "• ${item['name']} x${item['quantity']} (₹${item['finalItemPrice']})",
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Grand Total: ₹${order['order']?['total'] ?? 0}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
