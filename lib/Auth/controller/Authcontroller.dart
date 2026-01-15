import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:restro_deliveryapp/Auth/model/authmodel.dart';
import 'package:restro_deliveryapp/Auth/view/Profile.dart';
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
 // ----------------------------------------------------
// REGISTER DELIVERY PARTNER  — CLOUDINARY VERSION
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

  String? profileImageUrl,
  String? aadhaarFrontUrl,
  String? aadhaarBackUrl,
  String? panUrl,
  String? dlUrl,
}) async {


  Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.red)),
      barrierDismissible: false);

  try {
    final url = ApiEndpoint.getUrl(ApiEndpoint.register);
    var request = http.MultipartRequest("POST", Uri.parse(url));

    // TEXT FIELDS
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

    // ⭐ SEND CLOUDINARY URLS (exact backend keys)
  request.fields["profileImage"] = profileImageUrl ?? "";
request.fields["aadhaarFrontImage"] = aadhaarFrontUrl ?? "";
request.fields["aadhaarBackImage"] = aadhaarBackUrl ?? "";
request.fields["panImage"] = panUrl ?? "";
request.fields["licenseImage"] = dlUrl ?? "";

    final response = await request.send();
    final resp = await response.stream.bytesToString();
    Get.back();

    final data = jsonDecode(resp);

    if (response.statusCode == 201 && data["success"] == true) {
      Get.snackbar("Success", data["message"],
          backgroundColor: Colors.green, colorText: Colors.white);
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


//profile data

Future<DeliveryPartnerProfile?> getProfile() async {
  try {
    String token = await SharedPre.getAccessToken();

    var res = await http.get(
      Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.getprofile)),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      var body = jsonDecode(res.body);
      return DeliveryPartnerProfile.fromJson(body);
    } else {
      print("Profile API Error: ${res.body}");
      return null;
    }
  } catch (e) {
    print("Profile API Exception: $e");
    return null;
  }
}




// ---------------- EDIT PROFILE API ----------------
Future<bool> updateProfile({
  required String name,
  required String email,
  required String address,
  required String pincode,
  File? profileImage,
}) async {
  try {
    String token = await SharedPre.getAccessToken();   // ✅ correct

    var request = http.MultipartRequest(
      "POST",
      Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.editProfile)),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['address'] = address;
    request.fields['pincode'] = pincode;

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
        ),
      );
    }

    var response = await request.send();
    String body = await response.stream.bytesToString();

    print("EDIT PROFILE RESPONSE = $body");

    var json = jsonDecode(body);

    return json["success"] == true;
  } catch (e) {
    print("Edit Profile API Error: $e");
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
        "message": "Server error: ${response.statusCode}"
      };
    }
  } catch (e) {
    print("POST API ERROR $endpoint : $e");
    return {"success": false, "message": "Something went wrong"};
  }
}



//change password

// CHANGE PASSWORD API - FINAL FIXED METHOD
Future<Map<String, dynamic>?> changePassword(String oldPass, String newPass) async {
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
    String userId = await SharedPre.getUserId();  // FIXED

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

// Future<Map<String, dynamic>?> verifyDeliveryOtp(String orderId, String otp) async {
//   final url = ApiEndpoint.getUrl(ApiEndpoint.verifyOtp(orderId));

//   print("📌 VERIFY OTP PATCH URL → $url");

//   try {
//     final response = await http.patch(
//       Uri.parse(url),  // ⭐ FIXED
//       headers: {
//         "Authorization": "Bearer ${await SharedPre.getAccessToken()}",
//         "Content-Type": "application/json"
//       },
//       body: jsonEncode({
//         "otp": otp
//       }),
//     );

//     print("📌 VERIFY OTP RESPONSE → ${response.body}");

//     return jsonDecode(response.body);

//   } catch (e) {
//     print("❌ VERIFY OTP ERROR = $e");
//     return null;
//   }
// }



Future<String?> uploadToCloudinary(File file) async {
  try {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/dp8jfjx7c/image/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = "ml_default"
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final res = await request.send();
    final response = await res.stream.bytesToString();
    final data = jsonDecode(response);

    return data["secure_url"];
  } catch (e) {
    print("CLOUDINARY ERROR: $e");
    return null;
  }
}

// ⭐ START DELIVERY   METHOD


Future<PickupOrderResponse?> Pickuporder(String orderId) async {

  try {
    String token = await SharedPre.getAccessToken();

    final String url =
        "https://resto-grandma.onrender.com/api/v1/delivery/pick-order/$orderId";

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

Future<Map<String, dynamic>?> getAssignedOrderFromApi() async {
  try {
    String token = await SharedPre.getAccessToken();

    final response = await http.get(
      Uri.parse("https://resto-grandma.onrender.com/api/v1/delivery/assigned-order"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("ASSIGNED ORDER API RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["data"];   // return actual assigned order
    }
  } catch (e) {
    print("ASSIGNED ORDER API ERROR: $e");
  }
  return null;
}


}