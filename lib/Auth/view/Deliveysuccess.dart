import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/Navbar.dart';
import 'package:restro_deliveryapp/Auth/view/SocketService.dart';

class DeliverySuccessScreen extends StatelessWidget {
  final String orderId;

  const DeliverySuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SUCCESS ICON
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 110,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Delivery Completed!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Order ID: $orderId",
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              Text(
                "Your delivery has been successfully completed.\nThank you!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 50),

              // BACK TO HOME BUTTON
              ElevatedButton(
                onPressed: () {
                  final socket = Get.find<OrderSocketService>();
                  socket.assignedOrder.value = null; // 🛡️ safety

                  Get.offAll(() => const BottomNavBar(initialIndex: 0));
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Back to Home",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
