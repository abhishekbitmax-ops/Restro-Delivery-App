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
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController(); // ⭐ NEW


  File? profileImageFile;
  final ImagePicker picker = ImagePicker();

  // ---------------------- IMAGE PICKER ----------------------
  Future<void> _pickImage(Function(File) onPicked) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
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

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        onPicked(File(picked.path));
      }
    }
  }

  // ---------------------- UI ----------------------
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
            // ---------------------- HEADER ----------------------
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
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 6,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Color(0xFF8B0000)),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
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
                          "Edit Profile",
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

            // ---------------------- PROFILE IMAGE ----------------------
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profileImageFile != null
                        ? FileImage(profileImageFile!)
                        : null,
                    child: profileImageFile == null
                        ? const Icon(Icons.person,
                            size: 46, color: Colors.black45)
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
                        child: Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ---------------------- SECTION: USER DETAILS ----------------------
            _section("User Details"),
            _field(nameCtrl, Icons.person_outline, "Full Name"),
            _field(emailCtrl, Icons.email_outlined, "Email Address"),
            _field(addressCtrl, Icons.location_on_outlined, "Address"),

            

           
            const SizedBox(height: 36),

            // ---------------------- SAVE BUTTON ----------------------
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
onPressed: () {
  if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // 🎉 SUCCESS POPUP
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                size: 60, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              "Profile Updated!",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Your changes were saved successfully.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );

  // ⏳ AUTO CLOSE POPUP & SCREEN
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context); // close dialog
    Navigator.pop(context); // go back to profile screen
  });
},
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

  // ---------------------- COMPONENTS ----------------------
  Widget _section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  Widget _field(TextEditingController c, IconData i, String h,
          {bool obscure = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: TextField(
          controller: c,
          obscureText: obscure,
          decoration: _decoration(i, h),
        ),
      );

  InputDecoration _decoration(IconData icon, String hint) => InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF8B0000), width: 1.2),
        ),
      );
}
