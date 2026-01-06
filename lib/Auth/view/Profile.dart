import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/Editprofile.dart';
import '../controller/profile_controller.dart';

class DeliveryProfileScreen extends StatelessWidget {
  DeliveryProfileScreen({super.key});

  final ProfileController controller =
      Get.put(ProfileController());

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
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500),
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
          : const Icon(Icons.arrow_back,
              size: 14, color: Colors.black38),
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

            //  PERFECT HEADER (CENTERED TITLE)
           Container(
  width: double.infinity, //  VERY IMPORTANT
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).padding.top + 12,
    bottom: 16,
  ),
  color: const Color(0xFF8B0000),
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Back Button (LEFT)
      Positioned(
  left: 12,
  child: InkWell(
    onTap: () {
      Get.offAllNamed('/dashboard');
    },
    borderRadius: BorderRadius.circular(30),
    child: const Padding(
      padding: EdgeInsets.all(8),
      child: Icon(
        Icons.arrow_back_ios_new,
        color: Colors.white,
        size: 20,
      ),
    ),
  ),
),


      //  CENTER CONTENT (LOGO + TITLE)
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset(
                "assets/images/restro_logo.jpg",
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Profile",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ],
  ),
),


            const SizedBox(height: 30),

            //  UPLOADABLE PROFILE IMAGE
           Obx(
  () => Stack(
    alignment: Alignment.bottomRight,
    children: [
      //  PROFILE IMAGE
      CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: controller.profileImage.value != null
            ? FileImage(controller.profileImage.value!)
            : null,
        child: controller.profileImage.value == null
            ? const Icon(Icons.person,
                size: 60, color: Colors.white)
            : null,
      ),

      //  CAMERA BUTTON (UPLOAD / CHANGE)
      Positioned(
        bottom: 0,
        right: 0,
        child: InkWell(
          onTap: controller.pickImage,
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF8B0000),
            child: Icon(Icons.camera_alt,
                size: 18, color: Colors.white),
          ),
        ),
      ),

      //  REMOVE IMAGE BUTTON (ONLY WHEN IMAGE EXISTS)
      if (controller.profileImage.value != null)
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: controller.removeImage,
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black87,
              child: Icon(Icons.close,
                  size: 16, color: Colors.white),
            ),
          ),
        ),
    ],
  ),
),

            const SizedBox(height: 14),

            Text(
              "Rakesh Kumar",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "+91 9876543210",
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 24),

            //  EDIT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(Editprofile()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.edit,
                      size: 18, color: Colors.white),
                  label: Text(
                    "EDIT PROFILE",
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            //  DETAILS
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  _tile(Icons.currency_rupee, "Earnings",
                      trailing: "₹ 84,325",
                      trailColor: Colors.green),
                  _divider(),
                  _tile(Icons.directions_bike, "Vehicle Info"),
                  _divider(),
                  _tile(Icons.verified_user, "Documents (KYC)",
                      trailing: "Verified",
                      trailColor: Colors.green),
                  _divider(),
                  _tile(Icons.account_balance, "Bank Details"),
                  _divider(),
                  _tile(Icons.lock_reset, "Change Password"),
                  _divider(),
                  _tile(Icons.help_outline, "Help & Support"),
                  _divider(),
                  _tile(Icons.logout, "Logout",
                      trailColor: Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.grey.shade200);
}
 