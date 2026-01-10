import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryRegistrationScreen extends StatefulWidget {
  const DeliveryRegistrationScreen({super.key});

  @override
  State<DeliveryRegistrationScreen> createState() =>
      _DeliveryRegistrationScreenState();
}

class _DeliveryRegistrationScreenState
    extends State<DeliveryRegistrationScreen> {
  final AuthController auth = Get.put(AuthController());

  bool isSubmitting = false;

  // TEXT CONTROLLERS
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final aadhaarIdCtrl = TextEditingController();
  final panIdCtrl = TextEditingController();
  final dlIdCtrl = TextEditingController();

  final vehicleNumberCtrl = TextEditingController();

  final addressLine1Ctrl = TextEditingController();
  final addressLine2Ctrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  // DOB & GENDER
  String gender = "MALE";
  DateTime? dob;

  String vehicleType = "BIKE";

  // FILES
  File? profileImageFile;
  File? aadhaarFrontFile;
  File? aadhaarBackFile;
  File? panFile;
  File? dlFile;

  final ImagePicker picker = ImagePicker();

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
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final picked =
          await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) onPicked(File(picked.path));
    }
  }

  // ---------------------------------------------
  // CLOUDINARY UPLOAD
  // ---------------------------------------------
  Future<String?> uploadToCloudinary(File file) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://api.cloudinary.com/v1_1/dp8jfjx7c/image/upload"),
      );

      request.fields["upload_preset"] = "ml_default";
      request.files
          .add(await http.MultipartFile.fromPath("file", file.path));

      var response = await request.send();
      var resStr = await response.stream.bytesToString();
      var data = jsonDecode(resStr);

      return data["secure_url"];
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
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
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 14,
                bottom: 28,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF8B0000),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
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
                  Column(
                    children: [
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
                ],
              ),
            ),

            const SizedBox(height: 28),

            // PROFILE IMAGE
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        profileImageFile != null
                            ? FileImage(profileImageFile!)
                            : null,
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

            _section("Basic Details"),
            _field(nameCtrl, Icons.person_outline, "Full Name"),
            _field(phoneCtrl, Icons.phone_outlined, "Mobile Number"),
            _field(emailCtrl, Icons.email_outlined, "Email Address"),
            _field(passwordCtrl, Icons.lock_outline, "Password"),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: InkWell(
                onTap: () async {
                  dob = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1970),
                    lastDate: DateTime.now(),
                    initialDate: DateTime(2000),
                  );
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        dob == null
                            ? "Select Date of Birth"
                            : "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: gender,
                decoration: _decoration(Icons.person, "Gender"),
                items: ["MALE", "FEMALE", "OTHER"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => gender = value!),
              ),
            ),

            _section("Address Details"),
            _field(addressLine1Ctrl, Icons.home, "Address Line 1"),
            _field(addressLine2Ctrl, Icons.home_max, "Address Line 2"),
            _field(cityCtrl, Icons.location_city, "City"),
            _field(stateCtrl, Icons.map, "State"),
            _field(pincodeCtrl, Icons.pin, "Pincode"),

            _section("Vehicle Information"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: vehicleType,
                decoration: _decoration(Icons.directions_bike, "Vehicle Type"),
                items: ["BIKE", "CAR", "CYCLE"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => vehicleType = v!),
              ),
            ),
            _field(vehicleNumberCtrl, Icons.confirmation_number_outlined,
                "Vehicle Number"),
            _section("Upload Documents (KYC)"),
            _field(aadhaarIdCtrl, Icons.credit_card, "Aadhaar Number"),
            _uploadKyc(
              title: "Aadhaar Front Image",
              file: aadhaarFrontFile,
              onTap: () => _pickImage((file) => setState(() => aadhaarFrontFile = file)),
            ),
            _uploadKyc(
              title: "Aadhaar Back Image",
              file: aadhaarBackFile,
              onTap: () => _pickImage((file) => setState(() => aadhaarBackFile = file)),
            ),
            _field(panIdCtrl, Icons.perm_identity, "PAN Number"),
            _uploadKyc(
              title: "PAN Card Image",
              file: panFile,
              onTap: () => _pickImage((file) => setState(() => panFile = file)),
            ),
            _field(dlIdCtrl, Icons.drive_eta_outlined, "Driving License Number"),
            _uploadKyc(
              title: "Driving License Image",
              file: dlFile,
              onTap: () => _pickImage((file) => setState(() => dlFile = file)),
            ),

            const SizedBox(height: 24),

            // REGISTER BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _onRegisterPress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Register", style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

void _onRegisterPress() async {
  if (profileImageFile == null ||
      aadhaarFrontFile == null ||
      aadhaarBackFile == null ||
      panFile == null ||
      dlFile == null) {
    Get.snackbar("Error", "Please upload all required documents!",
        backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  setState(() => isSubmitting = true);

  // 1️⃣ Upload to Cloudinary
  String? profileUrl = await uploadToCloudinary(profileImageFile!);
  String? adFrontUrl = await uploadToCloudinary(aadhaarFrontFile!);
  String? adBackUrl = await uploadToCloudinary(aadhaarBackFile!);
  String? panUrl = await uploadToCloudinary(panFile!);
  String? dlUrl = await uploadToCloudinary(dlFile!);

  // 2️⃣ Check if any upload failed
  if (profileUrl == null ||
      adFrontUrl == null ||
      adBackUrl == null ||
      panUrl == null ||
      dlUrl == null) {
    Get.snackbar("Upload Error", "Failed to upload some documents!",
        backgroundColor: Colors.red, colorText: Colors.white);
    setState(() => isSubmitting = false);
    return;
  }

  // 3️⃣ Call API
  await auth.registerDeliveryPartner(
    name: nameCtrl.text,
    phone: phoneCtrl.text,
    email: emailCtrl.text,
    password: passwordCtrl.text,
    dob: dob == null ? "" : dob!.toIso8601String(),
    gender: gender,

    addressLine1: addressLine1Ctrl.text,
    addressLine2: addressLine2Ctrl.text,
    city: cityCtrl.text,
    state: stateCtrl.text,
    pincode: pincodeCtrl.text,

    vehicleType: vehicleType,
    vehicleNumber: vehicleNumberCtrl.text,

    aadhaarNumber: aadhaarIdCtrl.text,
    panNumber: panIdCtrl.text,
    dlNumber: dlIdCtrl.text,

    // 4️⃣ Send Cloudinary URLS only
    profileImageUrl: profileUrl,
    aadhaarFrontUrl: adFrontUrl,
    aadhaarBackUrl: adBackUrl,
    panUrl: panUrl,
    dlUrl: dlUrl,
  );

  setState(() => isSubmitting = false);
}



  Widget _section(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
  );

  Widget _field(TextEditingController c, IconData i, String h) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
    child: TextField(controller: c, decoration: _decoration(i, h)),
  );

  Widget _uploadKyc({required String title, required File? file, required VoidCallback onTap}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            file == null
                ? Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.upload_file, size: 22),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(file, width: 50, height: 50, fit: BoxFit.cover),
                  ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))),
            Icon(file == null ? Icons.arrow_forward_ios : Icons.check_circle,
                size: 18, color: file == null ? Colors.grey : Colors.green),
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
