import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/model/authmodel.dart';
import 'package:restro_deliveryapp/Auth/view/Editprofile.dart';
import 'package:restro_deliveryapp/Auth/view/Login.dart';
import 'package:restro_deliveryapp/Homeview/View/Homveiw.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';

class DeliveryProfileScreen extends StatefulWidget {
  const DeliveryProfileScreen({super.key});

  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  DeliveryPartnerProfile? profileData;
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    final res = await authController.getProfile();
    if (mounted) {
      setState(() {
        profileData = res;
      });
    }
  }

  // ---------------- IMAGE ----------------
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

  // ---------------- INFO ROW ----------------
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- DOC IMAGE ROW ----------------
  Widget _docRow(String title, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 13)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cloudImg(url, 60),
          ),
        ],
      ),
    );
  }

  // ---------------- LOGOUT ----------------
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await SharedPre.clearAll();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DeliveryLoginScreen()),
                (_) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final p = profileData?.data;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        color: const Color(0xFF8B0000),
        onRefresh: () async {
          fetchProfileData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ---------- HEADER ----------
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

              // ---------- PROFILE IMAGE ----------
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                child: ClipOval(child: cloudImg(p?.profileImage, 120)),
              ),

              const SizedBox(height: 14),

              Text(
                p?.name ?? "-",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "+91 ${p?.phone ?? "-"}",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
              Text(
                p?.email ?? "-",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
              ),

              const SizedBox(height: 24),

              // ---------- EDIT PROFILE ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Editprofile()),
                      );

                      if (updated == true) {
                        fetchProfileData(); // 🔥 REFRESH PROFILE
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      "EDIT PROFILE",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ---------- DETAILS CARD ----------
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow(
                        "Date of Birth",
                        p?.dob != null && p!.dob!.length >= 10
                            ? p.dob!.substring(0, 10)
                            : "-",
                      ),
                      _infoRow("Gender", p?.gender ?? "-"),
                      _infoRow(
                        "Address",
                        p?.address == null
                            ? "-"
                            : "${p!.address!.street ?? ""}, "
                                  "${p.address!.area ?? ""}, "
                                  "${p.address!.city ?? ""}, "
                                  "${p.address!.state ?? ""} - "
                                  "${p.address!.zipCode ?? ""}",
                      ),
                      _infoRow("Vehicle Type", p?.vehicle?.type ?? "-"),
                      _infoRow("Vehicle Number", p?.vehicle?.number ?? "-"),
                      _infoRow("Aadhaar Number", p?.kyc?.aadhaarNumber ?? "-"),
                      _infoRow("PAN Number", p?.kyc?.panNumber ?? "-"),
                      _infoRow(
                        "Driving License",
                        p?.kyc?.drivingLicenseNumber ?? "-",
                      ),

                      const Divider(height: 30),

                      Text(
                        "KYC Documents",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      _docRow("Aadhaar Front", p?.kyc?.documents?.aadhaarFront),
                      _docRow("Aadhaar Back", p?.kyc?.documents?.aadhaarBack),
                      _docRow("PAN Card", p?.kyc?.documents?.panCard),
                      _docRow(
                        "Driving License",
                        p?.kyc?.documents?.drivingLicense,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ---------- LOGOUT ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _confirmLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "LOGOUT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
