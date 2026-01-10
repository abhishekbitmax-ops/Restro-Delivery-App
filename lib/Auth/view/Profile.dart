import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/model/authmodel.dart';
import 'package:restro_deliveryapp/Auth/view/Editprofile.dart';
import 'package:restro_deliveryapp/Auth/view/Login.dart';
import 'package:restro_deliveryapp/Auth/view/SettingsScreen';
import 'package:restro_deliveryapp/Homeview/View/Homveiw.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';

class DeliveryProfileScreen extends StatefulWidget {
  const DeliveryProfileScreen({super.key});

  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  // Bank local fields
  String? accHolder;
  String? accNumber;
  String? ifscCode;
  String? mobileNumber;

  DeliveryPartnerProfile? profileData;
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    loadLocalBankDetails();
  }

  void loadLocalBankDetails() async {
    var data = await SharedPre.getBankDetailsLocal();
    setState(() {
      accHolder = data["holder"];
      accNumber = data["number"];
      ifscCode = data["ifsc"];
      mobileNumber = data["mobile"];
    });
  }

  void fetchProfileData() async {
    var res = await authController.getProfile();
    if (mounted) {
      setState(() {
        profileData = res;
      });
    }
  }

  // ⭐ CLOUDINARY IMAGE LOADER
  Widget cloudImg(String? url, double size) {
    if (url == null || url.isEmpty) {
      return Image.asset(
        "assets/images/restro_logo.jpg",
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(child: CircularProgressIndicator(color: Colors.red));
      },
      errorBuilder: (_, __, ___) {
        return Image.asset(
          "assets/images/restro_logo.jpg",
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      },
    );
  }

  // INFO ROW
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  // ⭐ DOCUMENT ROW UPDATED
  Widget _docRow(String title, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cloudImg(url, 60),
          ),
        ],
      ),
    );
  }

  // BOTTOMSHEET
  void showBankDetailsBottomSheet() {
    final nameCtrl = TextEditingController(text: accHolder);
    final accCtrl = TextEditingController(text: accNumber);
    final ifscCtrl = TextEditingController(text: ifscCode);
    final mobileCtrl = TextEditingController(text: mobileNumber);

    bool isEdit = accHolder != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(isEdit ? "Edit Bank Details" : "Add Bank Details",
                    style:
                        GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
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
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF8B0000)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: Text("Cancel",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8B0000))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameCtrl.text.isEmpty ||
                              accCtrl.text.isEmpty ||
                              ifscCtrl.text.isEmpty ||
                              mobileCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please fill all fields!"),
                                  backgroundColor: Colors.red),
                            );
                            return;
                          }

                          var response = await authController.saveBankDetails(
                            accountHolderName: nameCtrl.text.trim(),
                            accountNumber: accCtrl.text.trim(),
                            ifscCode: ifscCtrl.text.trim(),
                            linkedMobile: mobileCtrl.text.trim(),
                            qrImage: null,
                          );

                          if (response != null && response["success"] == true) {
                            setState(() {
                              accHolder = nameCtrl.text.trim();
                              accNumber = accCtrl.text.trim();
                              ifscCode = ifscCtrl.text.trim();
                              mobileNumber = mobileCtrl.text.trim();
                            });

                            SharedPre.saveBankDetailsLocal(
                              holder: accHolder!,
                              number: accNumber!,
                              ifsc: ifscCode!,
                              mobile: mobileNumber!,
                            );

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEdit
                                    ? "Bank Details Updated Successfully!"
                                    : "Bank Details Saved Successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 3),
                        child: Text(isEdit ? "Update" : "Save",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // INPUT FIELD
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
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  // PROFILE OPTION
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
                  offset: const Offset(0, 3))
            ]),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // LOGOUT POPUP
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text("Logout",
              style:
                  GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
          content: Text("Are you sure you want to logout?",
              style: GoogleFonts.poppins(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                await SharedPre.clearAll();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => DeliveryLoginScreen()),
                  (_) => false,
                );
              },
              child: Text("Logout",
                  style: GoogleFonts.poppins(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  // ------------------ MAIN UI ------------------
  @override
  Widget build(BuildContext context) {
    final p = profileData?.data;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ⭐ HEADER — NOT CHANGED
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
                          MaterialPageRoute(
                              builder: (_) => DeliveryDashboardScreen())),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Color(0xFF8B0000)),
                      ),
                    ),
                  ),

                  // ⭐ STATIC HEADER IMAGE
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

            // ⭐ CLOUDINARY PROFILE PIC
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: ClipOval(
                child: cloudImg(p?.profileImage, 120),
              ),
            ),

            const SizedBox(height: 14),

            Text(p?.name ?? "Loading...",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("+91 ${p?.phone ?? ""}",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
            Text(p?.email ?? "",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45)),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const Editprofile()));
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: Text("EDIT PROFILE",
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow("Date of Birth", p?.dob?.substring(0, 10) ?? "-"),
                    _infoRow("Gender", p?.gender ?? "-"),
                    _infoRow(
                        "Address",
                        p?.address == null
                            ? "-"
                            : "${p!.address!.line1}, ${p.address!.line2}, "
                                "${p.address!.city}, ${p.address!.state} - ${p.address!.pincode}"),
                    _infoRow("Vehicle Type", p?.vehicleType ?? "-"),
                    _infoRow("Vehicle Number", p?.vehicleNumber ?? "-"),
                    _infoRow("Aadhaar Number", p?.kyc?.aadhaarNumber ?? "-"),
                    _infoRow("PAN Number", p?.kyc?.panNumber ?? "-"),
                    _infoRow(
                        "Driving License", p?.kyc?.drivingLicenseNumber ?? "-"),

                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),

                    Text("KYC Documents",
                        style:
                            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // ⭐ CLOUDINARY KYC IMAGES
                    _docRow("Aadhaar Front", p?.kyc?.documents?.aadhaarFront),
                    _docRow("Aadhaar Back", p?.kyc?.documents?.aadhaarBack),
                    _docRow("PAN Card", p?.kyc?.documents?.panCard),
                    _docRow("Driving License", p?.kyc?.documents?.drivingLicense),

                    const SizedBox(height: 20),

                    if (accHolder != null) ...[
                      const Divider(),
                      Text("Bank Details",
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.bold)),
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
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  child: Text("Bank Details",
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _profileOption(
                      title: "Settings",
                      icon: Icons.settings_outlined,
                      onTap: () => Get.to(() => const DeliverySettingsScreen())),

                  const SizedBox(height: 12),

                  _profileOption(
                      title: "Logout",
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: _confirmLogout),
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
