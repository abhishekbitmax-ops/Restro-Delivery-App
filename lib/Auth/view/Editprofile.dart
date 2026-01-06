import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final partnerIdCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final vehicleNumberCtrl = TextEditingController();
  final accountNumberCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final aadhaarIdCtrl = TextEditingController();
  final panIdCtrl = TextEditingController();
  final dlIdCtrl = TextEditingController();

  String vehicleType = "Bike";
  File? profileImageFile;
  final ImagePicker picker = ImagePicker();

Future<void> _pickImage(Function(File) onPicked) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent, // 🔥 for rounded card look
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20), // 👈 bottom gap
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),

                /// DRAG HANDLE
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 14),

                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Gallery"),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (source != null) {
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (picked != null) {
      onPicked(File(picked.path));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B0000),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 26,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF8B0000),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child:Stack(
  children: [
    /// ⬅ BACK BUTTON (LEFT FIXED)
    Positioned(
      left: 16,
      top: 6,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.arrow_back,
            color: Color(0xFF8B0000),
          ),
        ),
      ),
    ),

    /// ✅ LOGO + TITLE PERFECT CENTER
    Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                "assets/images/restro_logo.jpg",
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Swaad of Grandmaa",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
         
        ],
      ),
    ),
  ],
),

            ),

            const SizedBox(height: 28),

            /// PROFILE IMAGE
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        profileImageFile != null ? FileImage(profileImageFile!) : null,
                    child: profileImageFile == null
                        ? const Icon(Icons.person, size: 46, color: Colors.black45)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _pickImage((file) {
                          setState(() => profileImageFile = file);
                        });
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF8B0000),
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            _section("Partner Details"),
            _field(partnerIdCtrl, Icons.badge_outlined, "Partner ID"),
            _field(nameCtrl, Icons.person_outline, "Full Name"),
            _field(phoneCtrl, Icons.phone_outlined, "Mobile Number"),
            _field(emailCtrl, Icons.email_outlined, "Email Address"),

            const SizedBox(height: 28),

            _section("Vehicle Information"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: vehicleType,
                decoration: _decoration(Icons.directions_bike, "Vehicle Type"),
                items: ["Bike", "Bicycle"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => vehicleType = v!),
              ),
            ),
            _field(vehicleNumberCtrl, Icons.confirmation_number_outlined, "Vehicle Number"),

            const SizedBox(height: 28),

            _section("Upload Documents (KYC)"),
            _upload("Aadhaar Card", () => _pickImage((_) {})),
            _field(aadhaarIdCtrl, Icons.credit_card, "Aadhaar Number"),
            _upload("PAN Card", () => _pickImage((_) {})),
            _field(panIdCtrl, Icons.perm_identity, "PAN Number"),
            _upload("Driving License", () => _pickImage((_) {})),
            _field(dlIdCtrl, Icons.drive_eta_outlined, "License Number"),

            const SizedBox(height: 28),

            _section("Bank Information"),
            _field(accountNumberCtrl, Icons.account_balance_wallet_outlined, "Account Number"),
            _field(ifscCtrl, Icons.account_balance_outlined, "IFSC Code"),

            const SizedBox(height: 36),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// COMPONENTS
  Widget _section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  Widget _field(TextEditingController c, IconData i, String h) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: TextField(controller: c, decoration: _decoration(i, h)),
      );

  Widget _upload(String title, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file_outlined, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ),
      );

  InputDecoration _decoration(IconData icon, String hint) => InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.2),
        ),
      );
}
