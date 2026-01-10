import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final address = orderData["deliveryAddress"] ?? {};
    final restaurant = orderData["restaurant"] ?? {};
    final items = orderData["items"] ?? [];

    final orderId = orderData["orderNumber"] ?? "-";
    final status = orderData["status"] ?? "UNKNOWN";
    final total = orderData["total"] ?? 0;
    final timeline = orderData["timeline"] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A0000),
        elevation: 0,
        title: Text(
          "Order Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ---------------------- ORDER ID + STATUS ----------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Order #: $orderId",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _statusBadge(status),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------- RESTAURANT ----------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  const Icon(Icons.store, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      restaurant["name"] ?? "Restaurant",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------- DELIVERY ADDRESS ----------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${address["addressLine"] ?? "-"}, "
                      "${address["city"]}, ${address["pincode"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------- ITEMS LIST ----------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Items",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.fastfood, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item["name"],
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                            Text(
                              "x${item["quantity"]}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------- TOTAL AMOUNT ----------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  Text(
                    "Grand Total",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "₹$total",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------- TIMELINE ----------------------
            if (timeline.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Timeline",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...timeline.map((t) => _timelineTile(t)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------- TIMELINE TILE ----------------------
  Widget _timelineTile(Map t) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t["status"],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              t["at"]?.toString().replaceAll("T", " ").substring(0, 16) ??
                  "",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ---------------------- BADGE ----------------------
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
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

  // ---------------------- CARD DECORATION ----------------------
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 12,
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
