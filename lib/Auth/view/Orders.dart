import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/Orderpickup.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int selectedTab = 0;

  final orders = [
    {
      "name": "Rakesh Kumar",
      "address": "1234 Elm St, Springfield",
      "price": "₹540",
      "status": "Delivered",
      "time": "Today at 10:30 AM",
      "active": true,
    },
    {
      "name": "John Doe",
      "address": "Bhaijan Nagar",
      "price": "₹650",
      "status": "Pending",
      "time": "Today at 9:00 AM",
      "active": false,
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    return orders
        .where((order) =>
            selectedTab == 0 ? order["active"] == true : order["active"] == false)
        .toList();
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
          /// 🔥 MODERN HEADER WITH LOGO
          Container(
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7A0000),
                  Color(0xFFB11212),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🍽️ APP LOGO
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
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

                // IconButton(
                //   icon: const Icon(Icons.arrow_back, color: Colors.white),
                //   onPressed: () => Navigator.pop(context),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 🔘 TABS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _tabButton("Active Orders", 0),
                  const SizedBox(width: 6),
                  _tabButton("Past Orders", 1),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 📦 ORDER LIST
          Expanded(
            child: filteredOrders.isEmpty
                ? _emptyState()
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _orderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 🔘 TAB BUTTON
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

  /// 🧾 ORDER CARD
  Widget _orderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () {
        // Get.to(() => const PickupScreen(), arguments: order);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.red.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  order["name"],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _statusBadge(order),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: Colors.redAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order["address"],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order["time"],
              style:
                  GoogleFonts.poppins(fontSize: 10, color: Colors.black38),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  "Order Amount",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  order["price"],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B0000),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ STATUS BADGE
  Widget _statusBadge(Map<String, dynamic> order) {
    final isActive = order["active"] == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? "ACTIVE" : order["status"].toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green : Colors.deepOrange,
        ),
      ),
    );
  }

  /// 📭 EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 60, color: Colors.grey.shade400),
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
