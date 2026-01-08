import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:restro_deliveryapp/utils/api_endpoints.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:restro_deliveryapp/Auth/view/Navbar.dart';

class AuthController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  Rx<File?> profileImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/profile.jpg");
    if (file.existsSync()) profileImage.value = file;
  }

  // ---------- MIME TYPE ----------
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (ext == "png") return "png";
    return "jpeg";
  }

  // ----------------------------------------------------
  // REGISTER DELIVERY PARTNER (FINAL FIXED VERSION)
  // ----------------------------------------------------
  Future<void> registerDeliveryPartner({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String dob,
    required String gender,

   required String addressLine1,
required String addressLine2,
required String city,
required String state,
required String pincode,


    required String vehicleType,
    required String vehicleNumber,

    required String aadhaarNumber,
    required String panNumber,
    required String dlNumber,

    required File? profileImage,
    required File? aadhaarFront,
    required File? aadhaarBack,
    required File? panImage,
    required File? dlImage,
  }) async {

    if (profileImage == null ||
        aadhaarFront == null ||
        aadhaarBack == null ||
        panImage == null ||
        dlImage == null) {
      Get.snackbar("Error", "All document images are required",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.red)),
      barrierDismissible: false,
    );

    try {
      final url = ApiEndpoint.getUrl(ApiEndpoint.register);
      var request = http.MultipartRequest("POST", Uri.parse(url));

      // -------- TEXT FIELDS EXACTLY AS BACKEND EXPECTS --------
      request.fields["name"] = name;
      request.fields["phone"] = phone;
      request.fields["email"] = email;
      request.fields["password"] = password;

      request.fields["dob"] = dob;
      request.fields["gender"] = gender;

      request.fields["addressLine1"] = addressLine1;
request.fields["addressLine2"] = addressLine2;
request.fields["city"] = city;
request.fields["state"] = state;
request.fields["pincode"] = pincode;


      request.fields["vehicleType"] = vehicleType;
      request.fields["vehicleNumber"] = vehicleNumber;

      request.fields["aadhaarNumber"] = aadhaarNumber;
      request.fields["panNumber"] = panNumber;
      request.fields["licenseNumber"] = dlNumber;

      // -------------------- FILE FIELDS (EXACT BACKEND NAMES) --------------------
 request.files.add(await http.MultipartFile.fromPath(
  "profileImage",
  profileImage.path,
  contentType: MediaType("image", _getMimeType(profileImage.path)),
));

request.files.add(await http.MultipartFile.fromPath(
  "aadhaarFrontImage",
  aadhaarFront.path,
  contentType: MediaType("image", _getMimeType(aadhaarFront.path)),
));

request.files.add(await http.MultipartFile.fromPath(
  "aadhaarBackImage",
  aadhaarBack.path,
  contentType: MediaType("image", _getMimeType(aadhaarBack.path)),
));

request.files.add(await http.MultipartFile.fromPath(
  "panImage",
  panImage.path,
  contentType: MediaType("image", _getMimeType(panImage.path)),
));

request.files.add(await http.MultipartFile.fromPath(
  "licenseImage",
  dlImage.path,
  contentType: MediaType("image", _getMimeType(dlImage.path)),
));



      // ---------------- SEND REQUEST ----------------
      final response = await request.send();
      final resp = await response.stream.bytesToString();
      Get.back();

      print("REGISTER RESPONSE: $resp");

      final data = jsonDecode(resp);

      if (response.statusCode == 201 && data["success"] == true) {
        Get.snackbar("Success", data["message"],
            backgroundColor: Colors.green, colorText: Colors.white);

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        Get.snackbar("Failed", data["message"],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ----------------------------------------------------
  // LOGIN
  // ----------------------------------------------------
  Future<void> loginDeliveryPartner({
    required String phone,
    required String password,
  }) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.red)),
        barrierDismissible: false);

    try {
      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.login));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          final token = data["token"];

          await SharedPre.saveTokens(
              accessToken: token, refreshToken: "", expiresIn: "86400");

          await SharedPre.saveMobile(data["partner"]["phone"]);

          Get.snackbar("Success", "Login Successful",
              backgroundColor: Colors.green, colorText: Colors.white);

          Get.offAll(() => const BottomNavBar());
        } else {
          Get.snackbar("Login Failed", data["message"],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "Status ${response.statusCode}");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Error", e.toString());
    }
  }

  // ------------ ONLINE / OFFLINE ----------
Future<Map<String, dynamic>?> toggleOnlineStatus() async {
  // Check Location Service
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    Get.snackbar("Location Off", "Please enable location service");
    return null;
  }

  // Permission Check
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // Get Current Location
  final pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  final token = await SharedPre.getAccessToken();
  final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.toggleOnline));

  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "lat": pos.latitude,
        "lng": pos.longitude,
      }),
    );

    final data = jsonDecode(response.body);
    return data; // RETURN BACKEND JSON RESPONSE

  } catch (e) {
    Get.snackbar("Error", e.toString(),
        backgroundColor: Colors.red, colorText: Colors.white);
    return null;
  }
}
}