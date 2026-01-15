import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';

class DeliverySettingsScreen extends StatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  bool orderAlert = true;
  bool payoutAlert = true;
  bool vibration = true;
  bool darkMode = false;

  final AuthController auth = Get.put(AuthController());

  // ---------------- SHOW CHANGE PASSWORD DIALOG ----------------
  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    bool oldObscure = true;
    bool newObscure = true;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  // Title
                  Text("Change Password",
                      style: GoogleFonts.poppins(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 18),

                  // OLD PASSWORD
                  TextField(
                    controller: oldCtrl,
                    obscureText: oldObscure,
                    decoration: InputDecoration(
                      labelText: "Old Password",
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      suffixIcon: IconButton(
                        icon: Icon(oldObscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() => oldObscure = !oldObscure);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // NEW PASSWORD
                  TextField(
                    controller: newCtrl,
                    obscureText: newObscure,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      suffixIcon: IconButton(
                        icon: Icon(newObscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() => newObscure = !newObscure);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF8B0000)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text("Cancel",
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF8B0000),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (oldCtrl.text.isEmpty ||
                                      newCtrl.text.isEmpty) {
                                    Get.snackbar("Error", "All fields are required!",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white);
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  var res = await auth.changePassword(
                                      oldCtrl.text.trim(),
                                      newCtrl.text.trim());

                                  setState(() => isLoading = false);

                                  if (res != null && res["success"] == true) {
                                    Navigator.pop(context);
                                    Get.snackbar(
                                        "Success", res["message"] ?? "Updated",
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white);
                                  } else {
                                    Get.snackbar(
                                        "Failed",
                                        res?["message"] ??
                                            "Something went wrong",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text("Update",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54),
      ),
    );
  }

  // ---------------- NORMAL TILE ----------------
  Widget _tile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF8B0000), size: 24),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  // ---------------- SWITCH TILE ----------------
  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF8B0000), size: 24),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Switch(
          value: value,
          activeColor: const Color(0xFF8B0000),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        elevation: 0,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),

      body: ListView(
        children: [
          // CHANGE PASSWORD
          _sectionTitle("Account"),
          _tile(
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: _showChangePasswordDialog,
          ),

          // HELP SUPPORT
          _tile(
            icon: Icons.headset_mic_outlined,
            title: "Help & Support",
            onTap: () {},
          ),

          // NOTIFICATIONS
          _sectionTitle("Notifications"),
          _switchTile(
              icon: Icons.notifications_active_outlined,
              title: "Order Alerts",
              value: orderAlert,
              onChanged: (v) => setState(() => orderAlert = v)),
          _switchTile(
              icon: Icons.payments_outlined,
              title: "Payout Alerts",
              value: payoutAlert,
              onChanged: (v) => setState(() => payoutAlert = v)),
          _switchTile(
              icon: Icons.vibration,
              title: "Vibration on New Order",
              value: vibration,
              onChanged: (v) => setState(() => vibration = v)),

          // LANGUAGE
          _sectionTitle("App Language"),
          _tile(
            icon: Icons.language,
            title: "English / Hindi",
            onTap: () {},
          ),

          // THEME
          _sectionTitle("Appearance"),
          _switchTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              value: darkMode,
              onChanged: (v) => setState(() => darkMode = v)),

          // PERMISSIONS
          _sectionTitle("Permissions"),
          _tile(icon: Icons.location_on_outlined, title: "Location Permission"),
          _tile(icon: Icons.camera_alt_outlined, title: "Camera Permission"),
          _tile(icon: Icons.folder_outlined, title: "Storage Permission"),
          _tile(
              icon: Icons.location_searching_outlined,
              title: "Background Location"),

          // ABOUT
          _sectionTitle("About App"),
          _tile(
            icon: Icons.info_outline,
            title: "App Version 1.0.0",
          ),
          _tile(
            icon: Icons.article_outlined,
            title: "Terms & Conditions",
          ),
          _tile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
          ),

          // DELETE ACCOUNT
          _sectionTitle("Account Actions"),
          _tile(
            icon: Icons.delete_forever,
            title: "Delete Account",
            onTap: () {},
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.red),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
