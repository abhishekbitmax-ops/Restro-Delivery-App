import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'dart:math';

import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/model/authmodel.dart';
import 'package:restro_deliveryapp/Auth/view/Deliveysuccess.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';

class DeliveryScreen extends StatefulWidget {
  final PickupData orderData;

  const DeliveryScreen({super.key, required this.orderData});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  final AuthController auth = Get.put(AuthController());
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

    final orderId = data.orderId ?? "N/A";
    final status = data.currentStatus ?? "-";
    final pickedAt = data.pickedUpAt ?? "-";

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
                  const SizedBox(height: 16),

                  _trackMapButton(address), // ⭐ MAP BUTTON
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

  // ---------------- CUSTOMER CARD ----------------
  Widget _customerCard(Map customer, Map address) {
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

  // ---------------- MAP BUTTON ----------------
  Widget _trackMapButton(Map address) {
    if (address["lat"] == null || address["lng"] == null) {
      return const SizedBox();
    }

    return _cardContainer(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000),
          minimumSize: const Size(double.infinity, 48),
        ),
        icon: const Icon(Icons.map, color: Colors.white),
        label: Text(
          "Track on Map",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () => _openMapBottomSheet(address),
      ),
    );
  }

  // ---------------- MAP BOTTOM SHEET ----------------
  void _openMapBottomSheet(Map address) async {
    final double destLat = address["lat"];
    final double destLng = address["lng"];

    await _getCurrentLocation(destLat, destLng);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Distance chip
                  if (_distanceInKm != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Chip(
                        label: Text(
                          "Distance: ${_distanceInKm!.toStringAsFixed(2)} km",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.green.shade100,
                      ),
                    ),

                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(destLat, destLng),
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: {
                        // Delivery location
                        Marker(
                          markerId: const MarkerId("delivery"),
                          position: LatLng(destLat, destLng),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ),
                          infoWindow: const InfoWindow(
                            title: "Delivery Address",
                          ),
                        ),

                        // Driver location
                        if (_currentLocation != null)
                          Marker(
                            markerId: const MarkerId("driver"),
                            position: LatLng(
                              _currentLocation!.latitude!,
                              _currentLocation!.longitude!,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                            infoWindow: const InfoWindow(
                              title: "Your Location",
                            ),
                          ),
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.navigation, color: Colors.white),
                      label: Text(
                        "Open in Google Maps",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _launchGoogleMaps(destLat, destLng),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ---------------- ITEMS ----------------
  Widget _itemsCard(List items) {
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
          ),
        ],
      ),
    );
  }

  // ---------------- PAYMENT ----------------
  Widget _paymentCard(amount) {
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
  Widget _timelineCard(PickupData order) {
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
          ...?order.timeline?.map(
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
  Widget _otpSection(String orderId) {
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
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: _inputDecoration(),
        onChanged: (_) => _checkOtp(),
      ),
    );
  }

  // ---------------- COMPLETE DELIVERY ----------------
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

  // ---------------- UI HELPERS ----------------
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

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
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
    const double earthRadius = 6371; // KM

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
