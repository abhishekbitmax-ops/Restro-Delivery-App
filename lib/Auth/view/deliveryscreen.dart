import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';

class DeliveryScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const DeliveryScreen({super.key, required this.orderData});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  final AuthController auth = Get.put(AuthController());

  bool isOtpValid = false;

  void _checkOtp() {
    setState(() {
      isOtpValid = _otpControllers.every((c) => c.text.isNotEmpty);
    });
  }

  // ⭐ COMBINE 4 DIGITS INTO OTP
  String _getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
    final customer = order["customer"] ?? {};
    final location = order["location"] ?? {};
    final grandTotal = order["price"]?["grandTotal"] ?? 0;

    final orderId = order["customOrderId"] ??
        order["orderId"] ??
        order["_id"] ??
        "N/A";

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
          _header(orderId),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _customerCard(
                    customer["name"] ?? "-",
                    customer["phone"] ?? "-",
                    "${location["addressLine"]}, ${location["city"]} - ${location["pincode"]}",
                  ),
                  const SizedBox(height: 18),
                  _paymentDetails("₹$grandTotal"),
                  const SizedBox(height: 18),
                  _otpSection(context, orderId),
                ],
              ),
            ),
          ),
          _bottomButtons(orderId),
        ],
      ),
    );
  }

  // 🔴 HEADER
  Widget _header(String orderId) {
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
                "Order ID: $orderId",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          // Center Logo
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset(
                "assets/images/restro_logo.jpg",
                height: 52,
                width: 52,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 👤 CUSTOMER CARD
  Widget _customerCard(String name, String phone, String address) {
    return _cardContainer(
      child: Row(
        children: [
          Image.asset(
            "assets/delivery_boy.png",
            height: 90,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.delivery_dining, size: 80, color: Colors.orange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 18, color: Color(0xFF7CB342)),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: Colors.orange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
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
  Widget _paymentDetails(String amount) {
    return _cardContainer(
      child: Row(
        children: [
          const Icon(Icons.currency_rupee, color: Color(0xFF8B0000)),
          const SizedBox(width: 10),
          Text(
            "Collect $amount",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🔐 OTP SECTION
  Widget _otpSection(BuildContext context, String orderId) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "OTP for Delivery Confirmation",
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
                    ? "OTP is ready to submit"
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

  // INPUT BOX
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

  // 🔘 BOTTOM BUTTON — API INTEGRATED
  Widget _bottomButtons(String orderId) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isOtpValid ? () => _verifyOtp(orderId) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              disabledBackgroundColor: const Color(0xFF8B0000).withOpacity(0.4),
              elevation: isOtpValid ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "Complete Delivery",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ VERIFY OTP API CALL
  Future<void> _verifyOtp(String orderId) async {
    final otp = _getOtp();

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.red)),
      barrierDismissible: false,
    );

    final res = await auth.verifyDeliveryOtp(orderId, otp);

    Get.back();

    if (res != null && res["success"] == true) {
      _showSuccessDialog(orderId);
    } else {
      Get.snackbar(
        "OTP Failed",
        res?["message"] ?? "Invalid OTP",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🎉 SUCCESS POPUP
  void _showSuccessDialog(String orderId) {
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
                child:
                    Icon(Icons.check_circle, color: Colors.green, size: 42),
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
                "Order $orderId has been successfully delivered.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 10),
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

  // COMMON UI COMPONENTS
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
