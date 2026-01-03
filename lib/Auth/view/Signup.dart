import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class DeliveryRegistrationScreen extends StatefulWidget {
  const DeliveryRegistrationScreen({super.key});

  @override
  State<DeliveryRegistrationScreen> createState() =>
      _DeliveryRegistrationScreenState();
}

class _DeliveryRegistrationScreenState
    extends State<DeliveryRegistrationScreen> {
  // Controllers
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

  Future<void> _pickProfileImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Wrap(
        children: [
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
        ],
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() {
          profileImageFile = File(picked.path);
        });
      }
    }
  }

  Future<void> _pickKycImage(String type) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Wrap(
        children: [
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
        ],
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        debugPrint("$type image selected → ${picked.path}");
      }
    }
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
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 18,
                bottom: 24,
              ),
              decoration: const BoxDecoration(color: Color(0xFF8B0000)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(color: Color(0xFF8B0000)),
                    child: Column(
                      children: [
                        Text(
                          "Swaad",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "of Grandmaa",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Bringing Grandma’s love to every doorstep",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.app_registration, color: Color(0xFF8B0000)),
                  const SizedBox(width: 8),
                  Text(
                    "Delivery Partner Registration",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Profile Image Upload
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profileImageFile != null
                        ? FileImage(profileImageFile!)
                        : null,
                    child: profileImageFile == null
                        ? const Icon(
                            Icons.person,
                            size: 42,
                            color: Colors.black45,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: const Color(0xFF8B0000),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: _pickProfileImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Partner Details
            _buildSectionTitle("Partner Details"),
            _buildInputField(
              partnerIdCtrl,
              Icons.badge_outlined,
              "Enter Partner ID",
            ),
            _buildInputField(nameCtrl, Icons.person_outline, "Full Name"),
            _buildInputField(phoneCtrl, Icons.phone_outlined, "Mobile Number"),
            _buildInputField(emailCtrl, Icons.email_outlined, "Email Address"),

            const SizedBox(height: 26),

            // Vehicle Info
            _buildSectionTitle("Vehicle Information"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: vehicleType,
                isExpanded: true,
                decoration: _inputDecoration(
                  Icons.directions_bike,
                  "Select Vehicle Type",
                ),
                items: ["Bike", "Bicycle"].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => vehicleType = val ?? "Bike"),
              ),
            ),
            _buildInputField(
              vehicleNumberCtrl,
              Icons.confirmation_number_outlined,
              "Vehicle Number",
            ),

            const SizedBox(height: 32),

            // KYC Upload
            _buildSectionTitle("Upload Documents (KYC)"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _buildUploadRow(
                    "Aadhaar Card",
                    onTap: () => _pickKycImage("Aadhaar"),
                  ),
                  _buildInputField(
                    aadhaarIdCtrl,
                    Icons.credit_card,
                    "Enter Aadhaar ID Number",
                  ),
                  _buildUploadRow(
                    "PAN Card",
                    onTap: () => _pickKycImage("PAN"),
                  ),
                  _buildInputField(
                    panIdCtrl,
                    Icons.perm_identity,
                    "Enter PAN ID Number",
                  ),
                  _buildUploadRow(
                    "Driving License",
                    onTap: () => _pickKycImage("DL"),
                  ),
                  _buildInputField(
                    dlIdCtrl,
                    Icons.drive_eta_outlined,
                    "Enter License ID Number",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bank Info
            _buildSectionTitle("Bank Information"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _buildInputField(
                    accountNumberCtrl,
                    Icons.account_balance_wallet_outlined,
                    "Account Number",
                  ),
                  _buildInputField(
                    ifscCtrl,
                    Icons.account_balance_outlined,
                    "IFSC Code",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 44),

            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    debugPrint("Form Submitted!");
                  },
                  child: Text(
                    "Submit Registration",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Terms
            Center(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                  children: const [
                    TextSpan(text: "By proceeding, you agree to the "),
                    TextSpan(
                      text: "Terms & Conditions",
                      style: TextStyle(
                        color: Color(0xFF8B0000),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController ctrl,
    IconData icon,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      child: TextField(
        controller: ctrl,
        decoration: _inputDecoration(icon, hint),
      ),
    );
  }

  Widget _buildUploadRow(String label, {void Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.upload_file_outlined,
              size: 22,
              color: Colors.black45,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black45, size: 20),
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B0000), width: 1.3),
      ),
    );
  }
}
