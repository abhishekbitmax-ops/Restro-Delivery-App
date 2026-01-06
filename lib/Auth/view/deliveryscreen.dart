import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  bool isOtpValid = false;

  void _checkOtp() {
    setState(() {
      isOtpValid =
          _otpControllers.every((c) => c.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF2),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _customerCard(),
                  const SizedBox(height: 18),
                  _paymentDetails(),
                  const SizedBox(height: 18),
                  _otpSection(context),
                ],
              ),
            ),
          ),
          _bottomButtons(),
        ],
      ),
    );
  }

  // 🔴 HEADER WITH CENTER LOGO
  Widget _header() {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF8B0000),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Text(
                "Order ID: #5699",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          // ✅ CENTER LOGO
        CircleAvatar(
  radius: 28,
  backgroundColor: Colors.white,
  child: ClipOval(
    child: Image.asset(
      "assets/images/restro_logo.jpg",
      height: 50,
      width: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          "S",
          style: GoogleFonts.poppins(
            color: const Color(0xFF8B0000),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }

  // 👤 CUSTOMER CARD
  Widget _customerCard() {
    return _cardContainer(
      child: Row(
        children: [
          Image.asset(
            "assets/delivery_boy.png",
            height: 90,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.delivery_dining,
                    size: 80, color: Colors.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home,
                        size: 18, color: Color(0xFF7CB342)),
                    const SizedBox(width: 6),
                    Text(
                      "John Doe",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: Colors.orange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "1234 Elm Street, Springfield",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _circleIcon(Icons.phone),
              const SizedBox(height: 10),
              _circleIcon(Icons.chat),
            ],
          ),
        ],
      ),
    );
  }

  // 💳 PAYMENT DETAILS
  Widget _paymentDetails() {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Details",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF8B0000)),
              const SizedBox(width: 10),
              Text(
                "Collect ₹650 in Cash",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.number,
            decoration: _inputDecoration("Enter amount collected"),
          ),
        ],
      ),
    );
  }

  // 🔐 OTP SECTION
  Widget _otpSection(BuildContext context) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "OTP for Confirm Delivery",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
              (index) => _otpInputBox(context, index),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                isOtpValid ? Icons.check_circle : Icons.info,
                color: isOtpValid ? Colors.green : Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isOtpValid
                    ? "OTP verified successfully"
                    : "Enter OTP to continue",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isOtpValid ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _otpInputBox(BuildContext context, int index) {
    return SizedBox(
      width: 58,
      height: 58,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8B0000),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration(""),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          _checkOtp();
        },
      ),
    );
  }

  // 🔘 BOTTOM BUTTON
 Widget _bottomButtons() {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52, // ✅ Professional standard height
        child: ElevatedButton(
          onPressed: isOtpValid ? _showSuccessDialog : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B0000),
            disabledBackgroundColor: const Color(0xFF8B0000).withOpacity(0.4),
            elevation: isOtpValid ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // soft professional radius
            ),
          ),
          child: Text(
            "Complete Delivery",
            style: GoogleFonts.poppins(
              fontSize: 15,          // ✅ readable, not bulky
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,    // subtle premium feel
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}


  // ✅ SUCCESS POPUP
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.check_circle,
                    color: Colors.green, size: 42),
              ),
              const SizedBox(height: 16),
              Text(
                "Delivery Completed!",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Order #5699 has been successfully delivered.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // close dialog
                  Get.back(); // go back screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: Text(
                    "Done",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧩 COMMONS
  Widget _circleIcon(IconData icon) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFFFEBEB),
      child: Icon(icon, color: const Color(0xFF8B0000), size: 18),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      counterText: "",
    );
  }
}
