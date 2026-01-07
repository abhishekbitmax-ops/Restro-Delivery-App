import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/Orderpickup.dart';
import 'package:restro_deliveryapp/Auth/view/Orders.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final bool hasActiveOrder = true;
  bool isOnline = true;

  /// GetX Auth Controller
  final AuthController auth = Get.put(AuthController());

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
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
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
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 1, 0,
            ]),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: Column(
          children: [
            /// HEADER
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
                      /// LOGO
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

                      /// 🔥 ONLINE/OFFLINE SWITCH (API INTEGRATED)
                      GestureDetector(
  onTap: () async {
    bool newStatus = !isOnline;

    // Store previous state (in case API fails)
    bool previous = isOnline;

    // Call the API
    await auth.toggleOnlineStatus(newStatus);

    // Update UI only after API call completes
    setState(() {
      isOnline = newStatus;
    });
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.25),
            ),
          ],
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
                      "Welcome back 👋",
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

            /// BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _statusCard(
                          title: "Active Orders",
                          value: hasActiveOrder ? "1" : "0",
                          icon: Icons.delivery_dining_outlined,
                          color: const Color(0xFF8B0000),
                          onTap: () => Get.to(const MyOrdersScreen()),
                        ),
                        const SizedBox(width: 18),
                        _statusCard(
                          title: "Completed",
                          value: "12",
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                          onTap: () {},
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

                    hasActiveOrder
                        ? GestureDetector(
                            onTap: () => Get.to(const PickupScreen()),
                            child: Container(
                              padding: const EdgeInsets.all(26),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.red.shade50,
                                  ],
                                ),
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
                                            horizontal: 16, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B0000),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          "ORDER ASSIGNED",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                                    "New Delhi Restaurant",
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Butter Chicken • Veg Biryani",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red.shade100,
                                        ),
                                        child: const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Bhaijan Nagar, Springfield",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
