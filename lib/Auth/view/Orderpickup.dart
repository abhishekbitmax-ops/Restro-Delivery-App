import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/deliveryscreen.dart';
import 'package:restro_deliveryapp/Homeview/View/Assignordermodel.dart';

class PickupScreen extends StatefulWidget {
  final OrderData orderData;

  const PickupScreen({super.key, required this.orderData});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  bool isLoading = false;
  bool _navigated = false; // 🔥 guard
  final AuthController auth = Get.put(AuthController());

  // ---------------- AUTO NAVIGATE (FIXED) ----------------
  void checkAndNavigateIfOutForDelivery() {
    if (_navigated) return;

    final status = widget.orderData.order?.status ?? "";

    if (status == "OUT_FOR_DELIVERY") {
      _navigated = true;

      Fluttertoast.showToast(
        msg: "Order already picked!",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );

      Get.off(() => DeliveryScreen(orderData: widget.orderData));
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ SAFE NAVIGATION AFTER BUILD
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndNavigateIfOutForDelivery();
    });
  }

  // ---------------- INFO TILE ----------------
  Widget _infoTile(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.red.shade700),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- ITEM TILE ----------------
  Widget _itemTile(OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(Icons.fastfood, size: 22, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name ?? "-",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "x${item.quantity ?? 0}",
            style: GoogleFonts.poppins(
              fontSize: 14,
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

    final order = widget.orderData;

    final String orderId = order.order?.orderId ?? "-";
    final customer = order.customer;
    final location = order.deliveryAddress;
    final items = order.items ?? [];
    final totalAmount = order.order?.total ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // ---------------- HEADER ----------------
          Container(
            padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 26),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A0000), Color(0xFFB11212)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  "Pickup Order",
                  style: GoogleFonts.poppins(
                    fontSize: width * 0.048,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ---------------- BODY ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------- ORDER CARD -----------
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 6,
                          offset: Offset(0, 3),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Order ID: $orderId",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _infoTile(
                          "Customer Name",
                          customer?.name ?? "-",
                          Icons.person,
                        ),
                        const SizedBox(height: 14),
                        _infoTile(
                          "Phone Number",
                          customer?.phone ?? "-",
                          Icons.phone,
                        ),
                        const SizedBox(height: 14),
                        _infoTile(
                          "Delivery Address",
                          "${location?.addressLine ?? ""}, "
                              "${location?.city ?? ""} - "
                              "${location?.pincode ?? ""}",
                          Icons.location_on,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Order Items",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...items.map(_itemTile),

                  const SizedBox(height: 28),

                  // ----------- TOTAL -----------
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Grand Total:",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "₹$totalAmount",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ---------------- PICKUP BUTTON ----------------
                  SizedBox(
                    width: double.infinity,
                    height: width * 0.15,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);

                              final pickupResponse = await auth.Pickuporder(
                                orderId,
                              );

                              setState(() => isLoading = false);

                              if (pickupResponse?.success != true) {
                                Fluttertoast.showToast(
                                  msg:
                                      pickupResponse?.message ??
                                      "Pickup failed",
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                                return;
                              }

                              Fluttertoast.showToast(
                                msg: "Pickup Successful",
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );

                              order.order?.status = "OUT_FOR_DELIVERY";

                              Get.off(() => DeliveryScreen(orderData: order));
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Confirm Pickup",
                              style: GoogleFonts.poppins(
                                fontSize: width * 0.045,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}