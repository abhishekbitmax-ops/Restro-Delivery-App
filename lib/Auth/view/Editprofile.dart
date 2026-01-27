import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  File? profileImageFile;
  String? profileImageUrl; // ⭐ API IMAGE URL

  final ImagePicker picker = ImagePicker();
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    _loadExistingUserData();
  }

  // ---------- LOAD EXISTING PROFILE DATA ----------
  void _loadExistingUserData() async {
    final user = await authController.getProfile();

    if (user != null && user.data != null) {
      final data = user.data!;
      final addr = data.address;

      nameCtrl.text = data.name ?? "";
      emailCtrl.text = data.email ?? "";

      // ✅ Combine address fields safely
      addressCtrl.text = addr == null
          ? ""
          : [
              addr.street,
              addr.area,
              addr.city,
              addr.state,
            ].where((e) => e != null && e!.isNotEmpty).join(", ");

      // ✅ Correct field name
      pincodeCtrl.text = addr?.zipCode ?? "";

      profileImageUrl = data.profileImage ?? "";

      setState(() {});
    }
  }

  // ----------------- IMAGE PICKER -----------------
  Future<void> _pickImage(Function(File) onPicked) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _imageSourceSheet(ctx),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 80);

      if (picked != null) {
        final ext = picked.name.split(".").last.toLowerCase();
        if (ext != "jpg" && ext != "jpeg" && ext != "png") {
          Get.snackbar(
            "Invalid Image",
            "Only JPG, JPEG, PNG allowed!",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        onPicked(File(picked.path));
      }
    }
  }

  // Image Source Bottom Sheet
  Widget _imageSourceSheet(BuildContext ctx) {
    return Padding(
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
    );
  }

  // ---------------------- UI ----------------------
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF8B0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),

            _profileImage(),

            const SizedBox(height: 36),

            _section("User Details"),
            _field(nameCtrl, Icons.person_outline, "Full Name"),
            _field(emailCtrl, Icons.email_outlined, "Email Address"),
            _field(addressCtrl, Icons.location_on_outlined, "Address"),
            _field(pincodeCtrl, Icons.numbers_outlined, "Pincode"),

            const SizedBox(height: 36),
            _saveButton(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---------------------- HEADER ----------------------
  Widget _header() {
    return Container(
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
    );
  }

  // ---------------------- PROFILE IMAGE ----------------------
  Widget _profileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: profileImageFile != null
                ? FileImage(profileImageFile!)
                : profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : null,
            child:
                (profileImageFile == null &&
                    (profileImageUrl == null || profileImageUrl!.isEmpty))
                ? const Icon(Icons.person, size: 46, color: Colors.black45)
                : null,
          ),

          // Camera Button
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
    );
  }

  // ---------------------- SAVE BUTTON ----------------------
  Widget _saveButton() {
    return Padding(
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
          onPressed: _saveProfile,
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
    );
  }

  // ---------------------- SAVE PROFILE API ----------------------
  Future<void> _saveProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    bool success = await authController.updateProfile(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      street: addressCtrl.text.trim(),
      pincode: pincodeCtrl.text.trim(),
      profileImage: profileImageFile,
    );

    Navigator.pop(context, true); // 👈 tell previous screen to refresh
    if (success) {
      Get.snackbar(
        "Success",
        "Profile Updated!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Navigator.pop(context);
    } else {
      Get.snackbar(
        "Error",
        "Profile update failed!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---------------------- COMPONENTS ----------------------
  Widget _section(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
    child: Text(
      text,
      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  );

  Widget _field(
    TextEditingController c,
    IconData i,
    String h, {
    bool obscure = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
    child: TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        hintText: h,
        prefixIcon: Icon(i, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.2),
        ),
      ),
    ),
  );
}
