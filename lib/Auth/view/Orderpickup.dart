// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
// import 'package:restro_deliveryapp/Auth/view/deliveryscreen.dart';

// class PickupScreen extends StatefulWidget {
//   final Map<String, dynamic> orderData;

//   const PickupScreen({
//     super.key,
//     required this.orderData,
//   });

//   @override
//   State<PickupScreen> createState() => _PickupScreenState();
// }

// class _PickupScreenState extends State<PickupScreen> {
//   bool isLoading = false;
//   final AuthController auth = Get.put(AuthController());

//   Widget _infoTile(String label, String value, IconData icon) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: Colors.red.shade700),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.black45,
//                   )),
//               const SizedBox(height: 2),
//               Text(value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   )),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _itemTile(Map item) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.black12),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.fastfood, size: 22, color: Colors.red.shade600),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               item["name"],
//               style: GoogleFonts.poppins(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Text(
//             "x${item["quantity"]}",
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final topPadding = MediaQuery.of(context).padding.top;

//     final order = widget.orderData;

//     final String orderId = order["customOrderId"] ??
//         order["orderId"] ??
//         order["_id"] ??
//         "";

//     final customer = order["customer"] ?? {};
//     final location = order["location"] ?? {};
//     final items = (order["items"] ?? []) as List;
//     final totalAmount = order["price"]?["grandTotal"] ?? 0;

//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       body: Column(
//         children: [
//           // 🔥 Header
//           Container(
//             padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 26),
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF7A0000), Color(0xFFB11212)],
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Get.back(),
//                   child: const Icon(Icons.arrow_back,
//                       color: Colors.white, size: 26),
//                 ),
//                 const SizedBox(width: 14),
//                 Text(
//                   "Pickup Order",
//                   style: GoogleFonts.poppins(
//                     fontSize: width * 0.048,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// 🔖 Order Card
//                   Container(
//                     padding: const EdgeInsets.all(18),
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                           color: Colors.black12,
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           "Order ID: $orderId",
//                           style: GoogleFonts.poppins(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.red.shade700,
//                           ),
//                         ),
//                         const SizedBox(height: 14),

//                         _infoTile(
//                           "Customer Name",
//                           customer["name"] ?? "-",
//                           Icons.person,
//                         ),
//                         const SizedBox(height: 14),

//                         _infoTile(
//                           "Phone Number",
//                           customer["phone"] ?? "-",
//                           Icons.phone,
//                         ),
//                         const SizedBox(height: 14),

//                         _infoTile(
//                           "Delivery Address",
//                           "${location["addressLine"]}, ${location["city"]} - ${location["pincode"]}",
//                           Icons.location_on,
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 28),

//                   Text(
//                     "Order Items",
//                     style: GoogleFonts.poppins(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 14),

//                   ...items.map((e) => _itemTile(e)).toList(),

//                   const SizedBox(height: 28),

//                   /// TOTAL AMOUNT
//                   Container(
//                     padding: const EdgeInsets.all(18),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.black12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Grand Total:",
//                             style: GoogleFonts.poppins(
//                                 fontSize: 16, fontWeight: FontWeight.w600)),
//                         Text("₹$totalAmount",
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green.shade700,
//                             )),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   /// ⭐ PICKUP BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     height: width * 0.15,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red.shade700,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 5,
//                       ),
//                       onPressed: isLoading
//                           ? null
//                           : () async {
//                               setState(() => isLoading = true);

//                               final response =
//                                   await auth.startDelivery(orderId);

//                               setState(() => isLoading = false);

//                               if (response != null &&
//                                   response["success"] == true) {
//                                 Fluttertoast.showToast(
//                                   msg: "Order Picked Successfully",
//                                   backgroundColor: Colors.black87,
//                                   textColor: Colors.white,
//                                 );

//                                 /// Navigate → Delivery Screen
//                                 Get.to(() => DeliveryScreen(
//                                       orderData: response["data"],
//                                     ));
//                               } else {
//                                 Fluttertoast.showToast(
//                                   msg: response?["message"] ??
//                                       "Pickup failed",
//                                   backgroundColor: Colors.red,
//                                   textColor: Colors.white,
//                                 );
//                               }
//                             },
//                       child: isLoading
//                           ? const CircularProgressIndicator(
//                               color: Colors.white,
//                             )
//                           : Text(
//                               "Confirm Pickup",
//                               style: GoogleFonts.poppins(
//                                 fontSize: width * 0.045,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/deliveryscreen.dart';

class PickupScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const PickupScreen({
    super.key,
    required this.orderData,
  });

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  bool isLoading = false;
  final AuthController auth = Get.put(AuthController());

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
              Text(label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black45,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemTile(Map item) {
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
              item["name"],
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "x${item["quantity"]}",
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

  // ⭐ AUTO-NAVIGATE if ORDER ALREADY PICKED
  void checkAndNavigateIfOutForDelivery() {
    final status = widget.orderData["currentStatus"] ?? "";

    if (status == "OUT_FOR_DELIVERY") {
      Fluttertoast.showToast(
        msg: "Order already picked!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Get.off(() => DeliveryScreen(orderData: widget.orderData));
    }
  }

  @override
  void initState() {
    super.initState();
    checkAndNavigateIfOutForDelivery(); // Auto skip if already picked
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    final order = widget.orderData;
    final String orderId = order["customOrderId"] ??
        order["orderId"] ??
        order["_id"] ??
        "";

    final customer = order["customer"] ?? {};
    final location = order["location"] ?? {};
    final items = (order["items"] ?? []) as List;
    final totalAmount = order["price"]?["grandTotal"] ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 🔥 Header
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
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 26),
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔖 Order Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          offset: const Offset(0, 3),
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
                          customer["name"] ?? "-",
                          Icons.person,
                        ),
                        const SizedBox(height: 14),

                        _infoTile(
                          "Phone Number",
                          customer["phone"] ?? "-",
                          Icons.phone,
                        ),
                        const SizedBox(height: 14),

                        _infoTile(
                          "Delivery Address",
                          "${location["addressLine"]}, ${location["city"]} - ${location["pincode"]}",
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

                  ...items.map((e) => _itemTile(e)).toList(),

                  const SizedBox(height: 28),

                  /// TOTAL AMOUNT
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
                        Text("Grand Total:",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        Text("₹$totalAmount",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ⭐ PICKUP BUTTON (FULLY FIXED)
                  SizedBox(
                    width: double.infinity,
                    height: width * 0.15,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);

                              final response =
                                  await auth.startDelivery(orderId);

                              setState(() => isLoading = false);

                              final msg =
                                  response?["message"] ?? "Pickup failed";

                              // ⭐ CASE 1: Success → Navigate
                              if (response?["success"] == true) {
                                Fluttertoast.showToast(
                                  msg: "Pickup Successful",
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );

                               Get.off(() => DeliveryScreen(
  orderData: response?["data"] ?? widget.orderData,
));

                              }

                              // ⭐ CASE 2: Backend says "already OUT_FOR_DELIVERY"
                              else if (msg.contains("OUT_FOR_DELIVERY")) {
                                Fluttertoast.showToast(
                                  msg: "Order already picked!",
                                  backgroundColor: Colors.orange,
                                  textColor: Colors.white,
                                );

                               Get.off(() => DeliveryScreen(
  orderData: response?["data"] ?? widget.orderData,
));

                              }

                              // ❌ CASE 3: Error
                              else {
                                Fluttertoast.showToast(
                                  msg: msg,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
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
