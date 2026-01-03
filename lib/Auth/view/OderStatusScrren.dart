import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  Widget _timelineTile(
    String title,
    String subtitle,
    String trailing, {
    bool active = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 34, bottom: 22, right: 18),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(1, 2),
            color: Colors.grey.shade200,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: active ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF8B0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final order = Get.arguments ?? {};

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 🔴 Header
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/profile_banner.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 12,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              Positioned(
                top: 46,
                right: 20,
                child: Text(
                  "Order ID: #${order["id"] ?? "5699"}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
              Positioned(
                top: 95,
                left: 20,
                child: Row(
                  children: [
                    const Icon(Icons.store, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      order["restaurant"] ?? "New Delhi Restaurant",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 📦 Timeline + avatar
          Expanded(
            child: Stack(
              children: [
                // vertical line
                Positioned(
                  left: 28,
                  top: 6,
                  bottom: 60,
                  child: Container(width: 3, color: const Color(0xFF8B0000)),
                ),

                ListView(
                  children: [
                    _timelineTile(
                      "Order Confirmed",
                      "10:12 AM",
                      "10:12 AM",
                      active: true,
                    ),
                    _timelineTile(
                      "Order Packed",
                      "10:29 AM",
                      "10:29 AM",
                      active: true,
                    ),
                    _timelineTile(
                      "Picked Up",
                      "10:41 AM",
                      "10:41 AM",
                      active: true,
                    ),
                    _timelineTile(
                      "Out For Delivery",
                      "10:45 AM",
                      "10:45 AM",
                      active: true,
                    ),
                    _timelineTile(
                      "Delivered",
                      "Pending",
                      "Pending",
                      active: false,
                    ),
                  ],
                ),

                // 👤 Bottom partner card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(2, 3),
                            color: Colors.grey.shade200,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: order["image"] != null
                                ? NetworkImage(order["image"])
                                : null,
                            child: order["image"] == null
                                ? const Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.black45,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order["name"] ?? "John Doe",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order["address"] ??
                                      "1234 Elm Street, Springfield",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _contactButton(Icons.phone),
                              const SizedBox(width: 8),
                              _contactButton(Icons.message),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactButton(IconData icon) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.red.shade50,
      child: Icon(icon, size: 18, color: const Color(0xFF8B0000)),
    );
  }
}
