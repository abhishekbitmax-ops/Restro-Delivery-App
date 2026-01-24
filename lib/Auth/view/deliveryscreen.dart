import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restro_deliveryapp/Auth/view/SocketService.dart';
import 'package:restro_deliveryapp/Homeview/View/Assignordermodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'dart:math';

import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/Deliveysuccess.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';

class DeliveryScreen extends StatefulWidget {
  final OrderData orderData;

  const DeliveryScreen({super.key, required this.orderData});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final AuthController auth = Get.put(AuthController());

  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  LocationData? _currentLocation;
  double? _distanceInKm;
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

    final orderId = data.order?.orderId ?? "N/A";
    final status = data.order?.status ?? "-";
    final pickedAt = data.order?.timeline?.lastOrNull?.at ?? "-";

    final customer = data.customer;
    final address = data.deliveryAddress;
    final items = data.items ?? [];
    final amount = data.order?.total ?? 0;

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
                  const SizedBox(height: 16),

                  if (address?.lat != null && address?.lng != null)
                    _trackMapButton(address!),

                  const SizedBox(height: 20),

                  _itemsCard(items),
                  const SizedBox(height: 20),

                  _paymentCard(amount),
                  const SizedBox(height: 20),

                  _timelineCard(data),
                  const SizedBox(height: 20),

                  _otpSection(),
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
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
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
          ),
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
          Text(
            "$title: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  // ---------------- CUSTOMER ----------------
  Widget _customerCard(Customer? customer, DeliveryAddress? address) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer Details",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow("Name", customer?.name ?? "-"),
          _infoRow("Phone", customer?.phone ?? "-"),
          _infoRow(
            "Address",
            "${address?.addressLine ?? ""}, "
                "${address?.city ?? ""} - "
                "${address?.pincode ?? ""}",
          ),
        ],
      ),
    );
  }

  // ---------------- MAP ----------------
  Widget _trackMapButton(DeliveryAddress address) {
    return _cardContainer(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000),
          minimumSize: const Size(double.infinity, 48),
        ),
        icon: const Icon(Icons.map, color: Colors.white),
        label: Text(
          "Open in Google Maps",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _openGoogleMaps(address),
      ),
    );
  }

  Future<void> _openGoogleMaps(DeliveryAddress address) async {
    if (address.lat == null || address.lng == null) {
      Get.snackbar(
        "Location Error",
        "Delivery location not available",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${address.lat},${address.lng}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        "Error",
        "Could not open Google Maps",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---------------- ITEMS ----------------
  Widget _itemsCard(List<OrderItem> items) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Items",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.fastfood, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(i.name ?? "")),
                  Text("x${i.quantity ?? 1}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PAYMENT ----------------
  Widget _paymentCard(num amount) {
    return _cardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Grand Total",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Text(
            "₹$amount",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TIMELINE ----------------
  Widget _timelineCard(OrderData data) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Timeline",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...?data.order?.timeline?.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${t.status} (${t.at})",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- OTP ----------------
  Widget _otpSection() {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Delivery OTP",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
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
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration(),
        onChanged: (value) {
          _checkOtp();

          // 👉 Move to next box
          if (value.isNotEmpty && index < _focusNodes.length - 1) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          }

          // 👉 Last box → close keyboard
          if (value.isNotEmpty && index == _focusNodes.length - 1) {
            FocusScope.of(context).unfocus();
          }

          // 👉 Backspace → move to previous
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  // ---------------- COMPLETE ----------------
  Widget _bottomButtons(String orderId) {
    return SafeArea(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: const Color(0xFF8B0000),
        ),
        onPressed: isOtpValid ? () => _verifyOtp(orderId) : null,
        child: Text(
          "Complete Delivery",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp(String orderId) async {
    final otp = _getOtp();

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final result = await auth.verifyDeliveryOtp(orderId, otp);
    Get.back();

    if (result?["success"] == true) {
      /// 🔥 CLEAR SOCKET STATE
      final socket = Get.find<OrderSocketService>();
      socket.assignedOrder.value = null;

      await SharedPre.clearAssignedOrder();

      Get.off(() => DeliverySuccessScreen(orderId: orderId));
    } else {
      Get.snackbar(
        "Error",
        "Invalid OTP",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---------------- HELPERS ----------------
  Widget _cardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black12.withOpacity(0.1)),
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

  Future<void> _getCurrentLocation(double destLat, double destLng) async {
    final location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) return;
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    final loc = await location.getLocation();

    setState(() {
      _currentLocation = loc;
      _distanceInKm = _calculateDistance(
        loc.latitude!,
        loc.longitude!,
        destLat,
        destLng,
      );
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
