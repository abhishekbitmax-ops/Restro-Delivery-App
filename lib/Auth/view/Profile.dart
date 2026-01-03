import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/Editprofile.dart';

class DeliveryProfileScreen extends StatelessWidget {
  const DeliveryProfileScreen({super.key});

  Widget _tile(
    IconData icon,
    String label, {
    String? trailing,
    Color? trailColor,
    void Function()? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF8B0000)),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: trailing != null
          ? Text(
              trailing,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: trailColor ?? Colors.black54,
              ),
            )
          : const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black38,
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 Header Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 18,
                bottom: 22,
              ),
              decoration: const BoxDecoration(color: Color(0xFF8B0000)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    " Delivery Profile ",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 👤 Profile Image Banner
            Center(
              child: Column(
                children: [
                  Image.asset(
                    "assets/profile_banner.png",
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.account_circle, // fallback icon
                          size: 80,
                          color: Colors.black45,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),
                  Text(
                    "Rakesh Kumar",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "+91 9876543210",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✏ Edit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Get.to(Editprofile());
                  },
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                  label: Text(
                    "EDIT PROFILE",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📌 Details List
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _tile(
                    Icons.currency_rupee,
                    "Earnings",
                    trailing: "₹ 84,325",
                    trailColor: Colors.green,
                  ),
                  _divider(),
                  _tile(Icons.directions_bike, "Vehicle Info"),
                  _divider(),
                  _tile(
                    Icons.verified_user,
                    "Documents (KYC)",
                    trailing: "Verified",
                    trailColor: Colors.green,
                  ),
                  _divider(),
                  _tile(Icons.account_balance, "Bank Details"),
                  _divider(),
                  _tile(Icons.lock_reset, "Change Password"),
                  _divider(),
                  _tile(Icons.help_outline, "Help & Support"),
                  _divider(),
                  _tile(
                    Icons.logout,
                    "Logout",
                    trailing: "",
                    onTap: () {},
                    trailColor: Colors.red,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "App Version 1.0.0",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
  Widget _dividerBig() =>
      Divider(height: 6, thickness: 1, color: Colors.grey.shade300);
}
