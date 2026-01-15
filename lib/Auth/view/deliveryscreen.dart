import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/model/authmodel.dart';

class DeliveryScreen extends StatefulWidget {
  final PickupData orderData;

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

  String _getOtp() => _otpControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final data = widget.orderData;

    /// -----------------------------
    /// 🔥 USE API DATA FIRST
    /// -----------------------------
    final orderId = data.orderId ?? "N/A";
    final status = data.currentStatus ?? "-";
    final pickedAt = data.pickedUpAt ?? "-";

    /// -----------------------------
    /// 🔥 MERGED DATA FROM PickupScreen
    /// -----------------------------
    final customer = data.customer ?? {};
    final address = data.deliveryAddress ?? {};
    final items = data.items ?? [];
    final amount = data.totalAmount ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF2),
      body: Column(
        children: [
          _header(orderId),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _orderInfoCard(orderId, status, pickedAt),
                  const SizedBox(height: 20),

                  _customerCard(customer, address),
                  const SizedBox(height: 20),

                  _itemsCard(items),
                  const SizedBox(height: 20),

                  _paymentCard(amount),
                  const SizedBox(height: 20),

                  _timelineCard(data),
                  const SizedBox(height: 20),

                  _otpSection(orderId),
                ],
              ),
            ),
          ),

          _bottomButtons(orderId),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(String orderId) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF8B0000),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back, color: Colors.white)),
              Text(
                "Order ID: $orderId",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),

          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset("assets/images/restro_logo.jpg"),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- ORDER INFO ----------------
  Widget _orderInfoCard(String orderId, String status, String pickedAt) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Order ID", orderId),
          _infoRow("Current Status", status),
          _infoRow("Picked At", pickedAt),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$title: ",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  // ---------------- CUSTOMER CARD ----------------
  Widget _customerCard(Map customer, Map address) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Customer Details",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),

          _infoRow("Name", customer["name"] ?? "-"),
          _infoRow("Phone", customer["phone"] ?? "-"),
          _infoRow(
            "Address",
            "${address["addressLine"] ?? ''}, "
            "${address["city"] ?? ''} - "
            "${address["pincode"] ?? ''}",
          ),
        ],
      ),
    );
  }

  // ---------------- ITEMS CARD ----------------
  Widget _itemsCard(List items) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Items",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.fastfood, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item["name"] ?? "")),
                  Text("x${item["quantity"] ?? 1}"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- PAYMENT CARD ----------------
  Widget _paymentCard(amount) {
    return _cardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Grand Total",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          Text("₹$amount",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.green)),
        ],
      ),
    );
  }

  // ---------------- TIMELINE ----------------
  Widget _timelineCard(PickupData order) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Timeline",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),

          if (order.timeline == null || order.timeline!.isEmpty)
            Text("No timeline available",
                style: GoogleFonts.poppins(color: Colors.black45)),

          ...?order.timeline?.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("${t.status} (${t.at})",
                        style: GoogleFonts.poppins(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- OTP SECTION ----------------
  Widget _otpSection(String orderId) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Enter Delivery OTP",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, _otpBox),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 55,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
        decoration: _inputDecoration(),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          _checkOtp();
        },
      ),
    );
  }

  // ---------------- BOTTOM BUTTON ----------------
  Widget _bottomButtons(String orderId) {
    return SafeArea(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: const Color(0xFF8B0000),
        ),
        onPressed: isOtpValid ? () => _verifyOtp(orderId) : null,
        child: Text("Complete Delivery",
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ---------------- VERIFY OTP ----------------
  Future<void> _verifyOtp(String orderId) async {
    final otp = _getOtp();

    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    // Call your OTP API here

    Get.back();
  }

  // ---------------- UI HELPERS ----------------
  Widget _cardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12.withOpacity(0.1),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      counterText: "",
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
