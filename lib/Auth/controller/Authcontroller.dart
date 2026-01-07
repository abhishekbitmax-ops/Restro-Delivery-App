import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:restro_deliveryapp/Auth/model/authmodel.dart';
import 'package:restro_deliveryapp/Auth/view/Navbar.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:restro_deliveryapp/utils/api_endpoints.dart';
import 'package:geolocator/geolocator.dart';

class AuthController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // LOCAL PROFILE IMAGE (Used for Dashboard UI)
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

  Future<void> pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/profile.jpg";

      final savedFile = File(path);
      if (savedFile.existsSync()) savedFile.deleteSync();

      final image = await File(picked.path).copy(path);
      profileImage.value = image;
    }
  }

  Future<void> removeImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/profile.jpg");
    if (file.existsSync()) await file.delete();

    profileImage.value = null;
  }

  // ----------------------------------------------------
  // REGISTER
  // ----------------------------------------------------
Future<void> registerDeliveryPartner({
  required String name,
  required String phone,
  required String email,
  required String password,
  required String confirmPassword,
  required String vehicleType,
  // required String vehicleNumber,
  required String aadhaarNumber,
  required String panNumber,
  required String dlNumber,

  // Files
  required File? profileImage,
  required File? aadhaarImage,
  required File? panImage,
  required File? dlImage,
}) async {
  if (password != confirmPassword) {
    Get.snackbar("Error", "Password & Confirm Password do not match",
        backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  if (profileImage == null ||
      aadhaarImage == null ||
      panImage == null ||
      dlImage == null) {
    Get.snackbar("Error", "All 4 images are required",
        backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.red)),
      barrierDismissible: false);

  try {
    final url = ApiEndpoint.getUrl(ApiEndpoint.register);
    var request = http.MultipartRequest("POST", Uri.parse(url));

    // REQUIRED TEXT FIELDS
    request.fields["name"] = name;
    request.fields["phone"] = phone;
    request.fields["email"] = email;
    request.fields["password"] = password;
    request.fields["vehicleType"] = vehicleType;
    // request.fields["vehicleNumber"] = vehicleNumber;
    request.fields["licenseNumber"] = dlNumber; // backend expects licenseNumber
    request.fields["aadhaarNumber"] = aadhaarNumber;
    request.fields["panNumber"] = panNumber;

   request.files.add(await http.MultipartFile.fromPath(
    "profileImage", profileImage.path));   // PROFILE PIC

request.files.add(await http.MultipartFile.fromPath(
    "driverImage", dlImage.path));         // DRIVING LICENSE PIC

request.files.add(await http.MultipartFile.fromPath(
    "aadhaarImage", aadhaarImage.path));   // AADHAAR PIC

request.files.add(await http.MultipartFile.fromPath(
    "panImage", panImage.path));           // PAN PIC


    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    Get.back();
    print("REGISTER RESPONSE: $respStr");

    final data = jsonDecode(respStr);

    if (response.statusCode == 201 && data["success"] == true) {
      Get.snackbar("Success", data["message"],
          backgroundColor: Colors.green, colorText: Colors.white);

      Future.delayed(const Duration(milliseconds: 400), () => Get.back());
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
      print("LOGIN RESPONSE: ${response.body}");

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

  // ----------------------------------------------------
  // PROFILE FETCH
  // ----------------------------------------------------

  var isProfileLoading = false.obs;
  var profileData = Rx<ProfileData?>(null);

  Future<void> fetchDeliveryPartnerProfile() async {
    isProfileLoading.value = true;

    try {
      final token = await SharedPre.getAccessToken();
      print("TOKEN BEFORE PROFILE API: $token");

      final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.getprofile));

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      });

      print("PROFILE STATUS: ${response.statusCode}");
      print("PROFILE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["success"] == true) {
          profileData.value = DeliveryPartnerProfile.fromJson(json).data;
        } else {
          Get.snackbar("Error", json["message"]);
        }
      } else if (response.statusCode == 401) {
        Get.snackbar("Unauthorized", "Invalid Token");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isProfileLoading.value = false;
    }
  }

  // ----------------------------------------------------
  // ONLINE/OFFLINE + LOCATION
  // ----------------------------------------------------

  Future<void> toggleOnlineStatus(bool newStatus) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Location Off", "Please enable location service");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final pos =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final token = await SharedPre.getAccessToken();
    final url = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.toggleOnline));

    try {
      final response = await http.post(url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "isOnline": newStatus,
            "lat": pos.latitude,
            "lng": pos.longitude
          }));

      final data = jsonDecode(response.body);
      print("TOGGLE: ${response.body}");

      if (data["success"] == true) {
        Get.snackbar("Success", data["message"],
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", data["message"]);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

}
