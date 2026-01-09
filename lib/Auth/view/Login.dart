import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/Navbar.dart';
import 'package:restro_deliveryapp/Auth/view/Signup.dart';

class DeliveryLoginScreen extends StatefulWidget {
  const DeliveryLoginScreen({super.key});

  @override
  State<DeliveryLoginScreen> createState() => _DeliveryLoginScreenState();
}

class _DeliveryLoginScreenState extends State<DeliveryLoginScreen> {
  final TextEditingController idCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  

  bool hidePassword = true;

  // ⭐ GetX Auth Controller
  final AuthController auth = Get.put(AuthController());

  

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF8B0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: topPadding + 26,
                bottom: 44,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF8B0000),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/restro_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Swaad ",
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.075,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "of Grandmaa",
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.075,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Delivering Grandma’s Love",
                    style: GoogleFonts.poppins(
                      fontSize: width * 0.032,
                      color: Colors.white70,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 38),

            // LOGIN CARD
            Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.06),
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 26,
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Welcome Delivery Partner",
                    style: GoogleFonts.poppins(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildTextField(
                    context,
                    controller: idCtrl,
                    hint: "Enter your Phone Number",
                    icon: Icons.person_outline,
                    isPassword: false,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    context,
                    controller: passCtrl,
                    hint: "Enter your Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 12),

                  // LOGIN BUTTON WITH AUTH CONTROLLER
                  SizedBox(
                    width: double.infinity,
                    height: width * 0.13,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        auth.loginDeliveryPartner(
                          phone: idCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                        );
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            TextButton(
              onPressed: () {
                Get.to(const DeliveryRegistrationScreen());
              },
              child: Text(
                "Create a New Account",
                style: GoogleFonts.poppins(
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8B0000),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // TEXT FIELD WIDGET
  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
  }) {
    final width = MediaQuery.of(context).size.width;

    return TextField(
      controller: controller,
      obscureText: isPassword ? hidePassword : false,
      style: GoogleFonts.poppins(fontSize: width * 0.036),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: width * 0.032,
          color: Colors.black38,
        ),
        prefixIcon: Icon(icon, color: Colors.black45),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF8B0000),
                ),
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
