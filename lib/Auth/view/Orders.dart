import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final List<dynamic> activeOrders;
  final List<dynamic> completedOrders;
  final int defaultTab; // 0 = active, 1 = completed

  const MyOrdersScreen({
    super.key,
    required this.activeOrders,
    required this.completedOrders,
    this.defaultTab = 0,
  });

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    selectedTab = widget.defaultTab; // 🔥 load correct tab
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF7A0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          // 🔥 HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A0000), Color(0xFFB11212)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/restro_logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "My Orders",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ⭐ UPDATED TABS (Active + Completed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _tabButton("Active Orders", 0),
                  const SizedBox(width: 6),
                  _tabButton("Completed Orders", 1),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 📦 LIST VIEW
          Expanded(
            child: selectedTab == 0
                ? _buildOrderList(widget.activeOrders)      // Only ACTIVE
                : _buildOrderList(widget.completedOrders),  // Only COMPLETED
          ),
        ],
      ),
    );
  }

  // 🔘 TAB BUTTON UI
  Widget _tabButton(String label, int index) {
    final active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF8B0000), Color(0xFFB11212)],
                  )
                : null,
            color: active ? null : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // 🧾 ORDER LIST
  Widget _buildOrderList(List<dynamic> orders) {
    if (orders.isEmpty) return _emptyState();

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) => _orderCard(orders[index]),
    );
  }

  // 🧾 ORDER CARD
  Widget _orderCard(dynamic order) {
    final address = order["deliveryAddress"] ?? {};
    final restaurant = order["restaurant"] ?? {};
    final items = order["items"] ?? [];

    final orderId = order["orderNumber"] ?? "-";
    final status = order["status"] ?? "UNKNOWN";
    final total = order["total"] ?? 0;

    return GestureDetector(
      onTap: () => Get.to(() => OrderDetailsScreen(orderData: order)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "#$orderId",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                const Spacer(),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.store, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant["name"] ?? "Restaurant",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${address["addressLine"] ?? "-"}, "
                    "${address["city"] ?? ""} - "
                    "${address["pincode"] ?? ""}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  "${items.length} items",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  "₹$total",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // STATUS BADGE
  Widget _statusBadge(String status) {
    Color bg;
    Color text;

    switch (status) {
      case "OUT_FOR_DELIVERY":
        bg = Colors.blue.shade100;
        text = Colors.blue.shade900;
        break;
      case "READY_FOR_PICKUP":
        bg = Colors.orange.shade100;
        text = Colors.orange.shade900;
        break;
      case "DELIVERED":
        bg = Colors.green.shade100;
        text = Colors.green.shade900;
        break;
      default:
        bg = Colors.grey.shade200;
        text = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            "No orders found",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
