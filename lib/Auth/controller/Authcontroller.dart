import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:restro_deliveryapp/Auth/model/authmodel.dart';
import 'package:restro_deliveryapp/Auth/view/SocketService.dart';
import 'package:restro_deliveryapp/Homeview/View/Assignordermodel.dart';
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
  // REGISTER DELIVERY PARTNER  — CLOUDINARY VERSION
  // ----------------------------------------------------
  Future<bool> registerDeliveryPartner({
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

    // 🔥 FILES (REQUIRED)
    required File profileImageFile,
    required File aadhaarFrontFile,
    required File aadhaarBackFile,
    required File panFile,
    required File dlFile,
  }) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.red)),
      barrierDismissible: false,
    );

    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.register)),
      );

      //  DO NOT SET CONTENT-TYPE MANUALLY
      // http.MultipartRequest handles it itself

      // ---------------- TEXT FIELDS ----------------
      request.fields.addAll({
        'name': name,
        'phone': phone,
        'password': password,
        'dob': dob,
        'gender': gender,
        'email': email,

        'aadhaarNumber': aadhaarNumber,
        'panNumber': panNumber,
        'licenseNumber': dlNumber,

        'vehicleType': vehicleType,
        'vehicleNumber': vehicleNumber,

        // 🔥 ADDRESS AS JSON STRING (Postman match)
        'address': jsonEncode({
          "type": "home",
          "street": addressLine1,
          "area": addressLine2,
          "city": city,
          "state": state,
          "zipCode": pincode,
        }),
      });

      // ---------------- FILE FIELDS ----------------
      request.files.addAll([
        await http.MultipartFile.fromPath(
          'profileImage',
          profileImageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
        await http.MultipartFile.fromPath(
          'aadhaarFrontImage',
          aadhaarFrontFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
        await http.MultipartFile.fromPath(
          'aadhaarBackImage',
          aadhaarBackFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
        await http.MultipartFile.fromPath(
          'panImage',
          panFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
        await http.MultipartFile.fromPath(
          'licenseImage',
          dlFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      ]);

      // 🔍 DEBUG (optional but gold)
      debugPrint("FIELDS => ${request.fields}");
      for (var f in request.files) {
        debugPrint("FILE => ${f.field} : ${f.filename}");
      }

      final response = await request.send();
      final resp = await response.stream.bytesToString();
      Get.back();

      final data = jsonDecode(resp);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          data["message"] ?? "Registration successful",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true; // ✅ SUCCESS
      } else {
        Get.snackbar(
          "Failed",
          data["message"] ?? "Registration failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // ----------------------------------------------------
  // LOGIN
  // ----------------------------------------------------
  Future<void> loginDeliveryPartner({
    required String phone,
    required String password,
  }) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.red)),
      barrierDismissible: false,
    );

    try {
      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.login));

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      Get.back(); // loader close

      final data = jsonDecode(response.body);

      // ✅ SUCCESS LOGIN
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data["success"] == true) {
          final token = data["token"];

          await SharedPre.saveTokens(
            accessToken: token,
            refreshToken: "",
            expiresIn: "86400",
          );

          await SharedPre.saveMobile(data["partner"]["phone"]);

          Get.snackbar(
            "Success",
            "Login Successful",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          Get.offAll(() => const BottomNavBar());
        } else {
          Get.snackbar(
            "Login Failed",
            data["message"] ?? "Login failed",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
      // ❌ 401 UNAUTHORIZED → ACCOUNT NOT VERIFIED
      else if (response.statusCode == 401) {
        Get.defaultDialog(
          title: "Account Not Verified",
          titleStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          middleText:
              "Your account is not verified yet.\n\nPlease wait for approval.\n⏳ Approval usually takes 12–24 hours.",
          middleTextStyle: const TextStyle(fontSize: 15),
          barrierDismissible: false,
          confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
            ),
            onPressed: () {
              Get.back(); // close dialog
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        );
      }
      // ❌ OTHER ERRORS
      else {
        Get.snackbar(
          "Error",
          data["message"] ?? "Something went wrong",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        body: jsonEncode({"lat": pos.latitude, "lng": pos.longitude}),
      );

      final data = jsonDecode(response.body);
      return data; // RETURN BACKEND JSON RESPONSE
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  //profile data

  Future<DeliveryPartnerProfile?> getProfile() async {
    try {
      String token = await SharedPre.getAccessToken();

      var res = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.getprofile)),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return DeliveryPartnerProfile.fromJson(jsonDecode(res.body));
      } else {
        debugPrint("Profile API Error: ${res.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Profile API Exception: $e");
      return null;
    }
  }

  // ---------------- EDIT PROFILE API ----------------
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? dob,
    String? gender,

    // address fields
    String? street,
    String? area,
    String? city,
    String? state,
    String? pincode,

    File? profileImage,
  }) async {
    try {
      final token = await SharedPre.getAccessToken();

      final request = http.MultipartRequest(
        "PATCH",
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.editProfile)),
      );

      request.headers['Authorization'] = "Bearer $token";

      // ---------------- TEXT FIELDS (ONLY IF NOT EMPTY) ----------------
      if (name != null && name.isNotEmpty) {
        request.fields['name'] = name;
      }

      if (email != null && email.isNotEmpty) {
        request.fields['email'] = email;
      }

      if (dob != null && dob.isNotEmpty) {
        request.fields['dob'] = dob;
      }

      if (gender != null && gender.isNotEmpty) {
        request.fields['gender'] = gender;
      }

      // ---------------- ADDRESS OBJECT ----------------
      if (street != null ||
          area != null ||
          city != null ||
          state != null ||
          pincode != null) {
        request.fields['address'] = jsonEncode({
          "type": "work",
          "street": street ?? "",
          "area": area ?? "",
          "city": city ?? "",
          "state": state ?? "",
          "zipCode": pincode ?? "",
        });
      }

      // ---------------- PROFILE IMAGE ----------------
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      debugPrint("EDIT PROFILE RESPONSE => $body");

      final json = jsonDecode(body);

      return json["success"] == true;
    } catch (e) {
      debugPrint("EDIT PROFILE ERROR => $e");
      return false;
    }
  }

  // ---------------- GLOBAL POST API HELPER ----------------
  Future<Map<String, dynamic>?> postApi(String endpoint, Map body) async {
    try {
      String token = await SharedPre.getAccessToken(); // fetch saved token

      final url = Uri.parse(ApiEndpoint.getUrl(endpoint));

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("POST API RESPONSE (${endpoint}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("POST API ERROR $endpoint : $e");
      return {"success": false, "message": "Something went wrong"};
    }
  }

  //change password

  // CHANGE PASSWORD API - FINAL FIXED METHOD
  Future<Map<String, dynamic>?> changePassword(
    String oldPass,
    String newPass,
  ) async {
    try {
      var response = await postApi(ApiEndpoint.changePassword, {
        "oldPassword": oldPass,
        "newPassword": newPass,
      });

      return response;
    } catch (e) {
      print("Change Password Error: $e");
      return null;
    }
  }

  // ----------------------------------------------------------------------
  // ⭐ ACTIVE ORDER
  // ----------------------------------------------------------------------
  Future<Map<String, dynamic>?> getActiveOrder() async {
    try {
      String token = await SharedPre.getAccessToken();

      final response = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.activeOrder)),
        headers: {"Authorization": "Bearer $token"},
      );

      print("ACTIVE ORDER RESPONSE: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("ACTIVE ORDER ERROR: $e");
      return null;
    }
  }

  // ----------------------------------------------------------------------
  // ⭐ COMPLETED ORDER
  // ----------------------------------------------------------------------
  Future<Map<String, dynamic>?> getCompletedOrder() async {
    try {
      String token = await SharedPre.getAccessToken();

      final response = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.completedOrder)),
        headers: {"Authorization": "Bearer $token"},
      );

      print("COMPLETED ORDER RESPONSE: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("COMPLETED ORDER ERROR: $e");
      return null;
    }
  }

  // ----------------------------------------------------------------------
  // ⭐ ORDER COUNT
  // ----------------------------------------------------------------------
  Future<Map<String, dynamic>?> getOrderCount() async {
    try {
      String token = await SharedPre.getAccessToken();

      final response = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.orderCount)),
        headers: {"Authorization": "Bearer $token"},
      );

      print("ORDER COUNT RESPONSE: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("ORDER COUNT ERROR: $e");
      return null;
    }
  }

  // -----------------------------------------------------------
  // ⭐ SAVE BANK DETAILS API (FINAL, FULLY INTEGRATED VERSION)
  // -----------------------------------------------------------
  Future<Map<String, dynamic>?> saveBankDetails({
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String linkedMobile,
    File? qrImage,
  }) async {
    try {
      String token = await SharedPre.getAccessToken();
      String userId = await SharedPre.getUserId(); // FIXED

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.accountDetails)),
      );

      request.headers['Authorization'] = "Bearer $token";

      request.fields["userId"] = userId;
      request.fields["accountHolderName"] = accountHolderName;
      request.fields["accountNumber"] = accountNumber;
      request.fields["ifscCode"] = ifscCode;
      request.fields["linkedMobile"] = linkedMobile;

      if (qrImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "qrImage",
            qrImage.path,
            contentType: MediaType("image", "jpeg"),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("BANK DETAILS RESPONSE => $responseBody");

      return jsonDecode(responseBody);
    } catch (e) {
      print("BANK DETAILS API ERROR => $e");
      return {"success": false, "message": "Something went wrong"};
    }
  }

  // delivery

  Future<Map<String, dynamic>?> verifyDeliveryOtp(
    String orderId,
    String otp,
  ) async {
    final String url =
        "https://sog.bitmaxtest.com/api/v1/delivery/$orderId/verify-otp";

    print("📌 VERIFY OTP PATCH URL → $url");

    try {
      final token = await SharedPre.getAccessToken();

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"otp": otp}),
      );

      print("📌 VERIFY OTP RESPONSE → ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("❌ VERIFY OTP ERROR = $e");
      return null;
    }
  }

  // ⭐ START DELIVERY   METHOD

  Future<PickupOrderResponse?> Pickuporder(String orderId) async {
    try {
      String token = await SharedPre.getAccessToken();

      final String url =
          "https://sog.bitmaxtest.com/api/v1/delivery/pick-order/$orderId";

      debugPrint("PICKUP ORDER URL → $url");

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"note": "Picked up from restaurant"}),
      );

      final json = jsonDecode(response.body);

      return PickupOrderResponse.fromJson(json);
    } catch (e) {
      print("PICKUP ERROR → $e");
      return null;
    }
  }

  // ----------------------------------------------------------------------
  // ⭐ ASSIGNED ORDER

  Future<AssignedOrderResponse?> getAssignedOrderFromApi() async {
    try {
      final token = await SharedPre.getAccessToken();

      final response = await http.get(
        Uri.parse("https://sog.bitmaxtest.com/api/v1/delivery/assigned-order"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode != 200) {
        debugPrint("❌ ASSIGNED ORDER API STATUS: ${response.statusCode}");
        return null;
      }

      final json = jsonDecode(response.body);

      /// 🔥 NO ORDER
      if (json["data"] == null) {
        Get.find<OrderSocketService>().assignedOrder.value = null;
        return null;
      }

      /// 🔥 PARSE MODEL
      final orderResponse = AssignedOrderResponse.fromJson(json);

      /// 🔥 EXTRACT ORDER ID (BACKEND SAFE)
      final backendOrderId = orderResponse.data?.order?.id;
      final displayOrderId = orderResponse.data?.order?.orderId;

      debugPrint("📦 BACKEND ORDER ID => $backendOrderId");
      debugPrint("🧾 DISPLAY ORDER ID => $displayOrderId");

      /// 🔥 API → SOCKET → UI
      Get.find<OrderSocketService>().pushOrderFromApi(orderResponse);

      return orderResponse;
    } catch (e) {
      debugPrint("❌ ASSIGNED ORDER API ERROR: $e");
      return null;
    }
  }
}
