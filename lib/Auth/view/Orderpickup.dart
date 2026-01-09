import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/deliveryscreen.dart';

class PickupScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const PickupScreen({super.key, required this.orderData});

  Widget _itemRow(
    BuildContext context,
    String name,
    String qty,
    IconData icon,
  ) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(
        vertical: width * 0.035,
        horizontal: width * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            qty,
            style: GoogleFonts.poppins(
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    // Extract all fields
    final orderId = orderData["customOrderId"] ?? "-";
    final customer = orderData["customer"] ?? {};
    final location = orderData["location"] ?? {};
    final items = (orderData["items"] ?? []) as List;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF8B0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 PREMIUM HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7A0000), Color(0xFFB11212)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 26),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
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
                      const SizedBox(height: 8),
                      Text(
                        "Pick Up Order",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// 🧾 ORDER ID
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Order ID: $orderId",
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.032,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🏠 CUSTOMER & ADDRESS CARD
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.045),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer: ${customer["name"]}",
                      style: GoogleFonts.poppins(
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Phone: ${customer["phone"]}",
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.032,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${location["addressLine"]}, ${location["city"]} - ${location["pincode"]}",
                      style: GoogleFonts.poppins(
                        fontSize: width * 0.032,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// 🍽 ORDER ITEMS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Text(
                "Order Items",
                style: GoogleFonts.poppins(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: Column(
                children: items
                    .map(
                      (e) => _itemRow(
                        context,
                        e["name"],
                        "x${e["quantity"]}",
                        Icons.lunch_dining_outlined,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 40),

            /// CONFIRM PICKUP BUTTON
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.045),
              child: SizedBox(
                width: double.infinity,
                height: width * 0.13,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Get.to(const DeliveryScreen());
                  },
                  child: Text(
                    "Confirm Pickup",
                    style: GoogleFonts.poppins(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
