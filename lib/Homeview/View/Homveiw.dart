import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/Orderpickup.dart';
import 'package:restro_deliveryapp/Auth/view/Orders.dart';
import 'package:restro_deliveryapp/Auth/view/SocketService.dart';
import 'package:restro_deliveryapp/Homeview/View/Assignordermodel.dart';
import 'package:shimmer/shimmer.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final AuthController auth = Get.put(AuthController());
  final OrderSocketService socketService = Get.find<OrderSocketService>();

  bool isOnline = true;
  bool isLoading = true;

  String? userName;

  int activeOrders = 0;
  int completedOrders = 0;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    loadOrderData();

    /// 🔥 ONE TIME API HIT (API → SOCKET → UI)
    auth.getAssignedOrderFromApi();
  }

  // ----------------------------------------------------
  // FETCH USER NAME
  // ----------------------------------------------------
  void fetchUserName() async {
    final profile = await auth.getProfile();
    if (!mounted) return;

    setState(() {
      userName = profile?.data?.name ?? "";
    });
  }

  // ----------------------------------------------------
  // LOAD DASHBOARD COUNTS
  // ----------------------------------------------------
  Future<void> loadOrderData() async {
    setState(() => isLoading = true);

    final active = await auth.getActiveOrder();
    final completed = await auth.getCompletedOrder();

    if (!mounted) return;

    setState(() {
      activeOrders = (active?["data"] ?? []).length;
      completedOrders = (completed?["data"] ?? []).length;
      isLoading = false;
    });
  }

  // ----------------------------------------------------
  // STATUS CARD
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // BUILD
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF7A0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: isLoading
          ? _shimmer(topPadding)
          : Column(
              children: [
                _header(topPadding),
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF8B0000),
                    onRefresh: loadOrderData,
                    child: SingleChildScrollView(
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

                          /// 🔥 REAL-TIME ORDER UI
                          /// ⭐ REAL-TIME ORDER UI (FIXED)
                          Obx(() {
                            final response = socketService.assignedOrder.value;
                            final data = response?.data;

                            if (data == null) {
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
                              onTap: () =>
                                  Get.to(() => PickupScreen(orderData: data)),
                              child: _assignedOrderCardUI(data),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ----------------------------------------------------
  // ASSIGNED ORDER CARD (MODEL BASED)
  // ----------------------------------------------------
  Widget _assignedOrderCardUI(OrderData data) {
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
          Text(
            "Order ID: ${data.order?.orderId ?? '-'}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text("Customer: ${data.customer?.name ?? '-'}"),
          Text("Phone: ${data.customer?.phone ?? '-'}"),
          const SizedBox(height: 12),
          ...(data.items ?? []).map(
            (item) => Text(
              "• ${item.name} x${item.quantity} (₹${item.finalItemPrice})",
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Grand Total: ₹${data.order?.total ?? 0}",
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

  // ----------------------------------------------------
  // HEADER
  // ----------------------------------------------------
  Widget _header(double topPadding) {
    return Container(
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          userName == null || userName!.isEmpty
              ? "Welcome back"
              : "Welcome back, $userName",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // SHIMMER
  // ----------------------------------------------------
  Widget _shimmer(double topPadding) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade200,
          child: Container(
            height: 160,
            margin: EdgeInsets.only(top: topPadding),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}
