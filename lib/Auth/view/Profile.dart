import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/Editprofile.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:restro_deliveryapp/Auth/view/ChangePassword.dart';


class DeliveryProfileScreen extends StatefulWidget {
  const DeliveryProfileScreen({super.key});

  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  final AuthController controller = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      controller.fetchDeliveryPartnerProfile();
    });
  }

  // ⭐ LOGOUT CONFIRMATION POPUP
  void _confirmLogout() {
    Get.defaultDialog(
      title: "Logout",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: "Are you sure you want to logout?",
      middleTextStyle: const TextStyle(fontSize: 14),
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF8B0000),
      onConfirm: () async {
        Get.back(); // close popup
        await _logoutUser();
      },
    );
  }

  // ⭐ LOGOUT FUNCTION
  Future<void> _logoutUser() async {
    // 1️⃣ Clear Shared Preferences
    await SharedPre.clearAll();

    // 2️⃣ Remove saved profile image from storage
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/profile.jpg");
    if (file.existsSync()) file.deleteSync();

    // 3️⃣ Clear controller image + profile data
    controller.profileImage.value = null;
    controller.profileData.value = null;

    // 4️⃣ Navigate to Login Screen
    Get.offAllNamed("/login");

    Get.snackbar(
      "Logged Out",
      "You have been logged out successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

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
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
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
          : const Icon(Icons.arrow_back, size: 14, color: Colors.black38),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF8B0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Obx(() {
      final profile = controller.profileData.value;
      final loading = controller.isProfileLoading.value;

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ================= HEADER =================
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 12,
                        bottom: 16,
                      ),
                      color: const Color(0xFF8B0000),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 12,
                            child: InkWell(
                              onTap: () => Get.offAllNamed('/dashboard'),
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
                          Column(
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

                    // ================= PROFILE IMAGE =================
                    Obx(
                      () => Stack(
                        alignment: Alignment.bottomRight,
                        children: [
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

                          // CAMERA BTN
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

                          // REMOVE BTN
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

                    // ================= NAME & PHONE =================
                    Text(
                      profile?.name ?? "Loading...",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "+91 ${profile?.phone ?? "---"}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================= EDIT PROFILE =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Get.to(Editprofile()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon:
                              const Icon(Icons.edit, size: 18, color: Colors.white),
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

                    // ================= DETAILS CARD =================
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _tile(Icons.currency_rupee, "Total Orders",
                              trailing: profile?.totalOrders?.toString() ?? "0",
                              trailColor: Colors.green),

                          _divider(),

                          _tile(Icons.directions_bike, "Vehicle Info",
                              trailing: profile?.vehicleType ?? "N/A"),

                          _divider(),

                          _tile(Icons.verified_user, "Documents (KYC)",
                              trailing: profile?.kyc?.status ?? "N/A",
                              trailColor: Colors.green),

                          _divider(),

                          _tile(Icons.account_balance, "Bank Details"),

                          _divider(),

                         _tile(
  Icons.lock_reset,
  "Change Password",
  onTap: () => Get.to(const ChangePasswordScreen()),
),

                          _divider(),

                          _tile(Icons.help_outline, "Help & Support"),

                          _divider(),

                          // ⭐ LOGOUT BUTTON
                          _tile(
                            Icons.logout,
                            "Logout",
                            trailColor: Colors.red,
                            onTap: _confirmLogout,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      );
    });
  }
}
