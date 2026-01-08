import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/Editprofile.dart';
import 'package:restro_deliveryapp/Auth/view/Login.dart';
import 'package:restro_deliveryapp/Homeview/View/Homveiw.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DeliveryProfileScreen extends StatefulWidget {
  const DeliveryProfileScreen({super.key});

  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  // ---- Local Bank Details (for now, no API) ---- //
  String? accHolder;
  String? accNumber;
  String? ifscCode;
  String? mobileNumber;

  // ---------------- INFO ROW ----------------
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  // ---------------- DOCUMENT ROW ----------------
  Widget _docRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12)),
            child: Image.asset("assets/images/restro_logo.jpg",
                fit: BoxFit.cover),
          )
        ],
      ),
    );
  }

 void showBankDetailsBottomSheet() {
  final nameCtrl = TextEditingController(text: accHolder);
  final accCtrl = TextEditingController(text: accNumber);
  final ifscCtrl = TextEditingController(text: ifscCode);
  final mobileCtrl = TextEditingController(text: mobileNumber);

  bool isEdit = accHolder != null; // if already saved → show EDIT btn

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Handle Bar ---
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                isEdit ? "Edit Bank Details" : "Add Bank Details",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _inputField("Account Holder Name", nameCtrl),
            _inputField("Account Number", accCtrl,
                inputType: TextInputType.number),
            _inputField("IFSC Code", ifscCtrl),
            _inputField("Mobile Number", mobileCtrl,
                inputType: TextInputType.phone),

            const SizedBox(height: 25),

            Row(
              children: [
                // CANCEL BTN
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8B0000)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B0000),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // SAVE / EDIT BTN
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.isEmpty ||
                            accCtrl.text.isEmpty ||
                            ifscCtrl.text.isEmpty ||
                            mobileCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          accHolder = nameCtrl.text.trim();
                          accNumber = accCtrl.text.trim();
                          ifscCode = ifscCtrl.text.trim();
                          mobileNumber = mobileCtrl.text.trim();
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? "Bank Details Updated Successfully!"
                                  : "Bank Details Saved Successfully!",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        isEdit ? "Update" : "Save",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
          ],
        ),
      );
    },
  );
}


Widget _inputField(String label, TextEditingController controller,
    {TextInputType inputType = TextInputType.text}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    ),
  );
}



Widget _profileOption({
  required String title,
  required IconData icon,
  required VoidCallback onTap,
  Color iconColor = const Color(0xFF8B0000),
  Color textColor = Colors.black,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}



void _confirmLogout() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // LOGOUT BUTTON
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // --- Clear session using your SharedPre class ---
              await SharedPre.clearAll();

              // --- Navigate to LoginScreen ---
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => DeliveryLoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}





  // --------------------- UI ---------------------
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B0000),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12, bottom: 16),
              color: const Color(0xFF8B0000),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: InkWell(
onTap: () => Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => DeliveryDashboardScreen()),
),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Color(0xFF8B0000)),
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
                      Text("Profile",
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- PROFILE IMAGE ----------------
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              backgroundImage: AssetImage("assets/images/user.png"),
            ),

            const SizedBox(height: 14),

            // ---------------- NAME & PHONE ----------------
            Text("Rashmi Rani",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text("+91 9876543210",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
            Text("rashmi@gmail.com",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45)),

            const SizedBox(height: 24),

            // ---------------- EDIT PROFILE ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Editprofile()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: Text("EDIT PROFILE",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- DETAILS CARD ----------------
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow("Date of Birth", "11/03/2001"),
                    _infoRow("Gender", "Female"),
                    _infoRow("Address", "Sector 62, Noida"),

                    _infoRow("Vehicle Type", "Bike"),
                    _infoRow("Vehicle Number", "UP16 AB 2345"),

                    _infoRow("Aadhaar Number", "XXXX XXXX 2345"),
                    _infoRow("PAN Number", "ABCDE1234Z"),
                    _infoRow("Driving License", "DL-0923-XYZ-112233"),

                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),

                    Text("KYC Documents",
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),
                    _docRow("Aadhaar Front"),
                    _docRow("Aadhaar Back"),
                    _docRow("PAN Card"),
                    _docRow("Driving License"),

                    const SizedBox(height: 20),

                    // -------- BANK DETAILS SECTION --------
                    if (accHolder != null) ...[
                      const Divider(),
                      const SizedBox(height: 10),
                      Text("Bank Details",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _infoRow("Account Holder", accHolder ?? "-"),
                      _infoRow("Account Number", accNumber ?? "-"),
                      _infoRow("IFSC Code", ifscCode ?? "-"),
                      _infoRow("Mobile Number", mobileNumber ?? "-"),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --------------- BANK DETAILS BUTTON ----------------
           // --------------- BANK DETAILS BUTTON ----------------
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 22),
  child: SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: showBankDetailsBottomSheet,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B0000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
      child: Text(
        "Bank Details",
        style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    ),
  ),
),


const SizedBox(height: 25),

// ---------------- ACCOUNT OPTIONS ----------------
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 22),
  child: Column(
    children: [

      // Help & Support
      _profileOption(
        title: "Help & Support",
        icon: Icons.headset_mic_outlined,
        onTap: () {
          // TODO: Navigate to Help Screen
        },
      ),

      const SizedBox(height: 12),

      // Settings
      _profileOption(
        title: "Settings",
        icon: Icons.settings_outlined,
        onTap: () {
          // TODO: Navigate to Settings Screen
        },
      ),

      const SizedBox(height: 12),

      // Logout
      _profileOption(
        title: "Logout",
        icon: Icons.logout,
        iconColor: Colors.red,
        textColor: Colors.red,
        onTap: () {
          _confirmLogout();
        },
      ),
    ],
  ),
),


const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}
