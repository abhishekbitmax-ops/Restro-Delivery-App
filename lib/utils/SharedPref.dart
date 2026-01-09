import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPre {
  // -------------------- KEYS --------------------
  static const String KEY_MOBILE = "user_mobile";
  static const String KEY_ACCESS_TOKEN = "access_token";
  static const String KEY_REFRESH_TOKEN = "refresh_token";
  static const String KEY_EXPIRES_IN = "expires_in";

  static const String KEY_USER_ID = "user_id";

  // Bank Details Keys
  static const String KEY_ACC_HOLDER = "acc_holder";
  static const String KEY_ACC_NUMBER = "acc_number";
  static const String KEY_IFSC = "ifsc";
  static const String KEY_LINKED_MOBILE = "linked_mobile";

  // ⭐ Assigned Order Key
  static const String KEY_ASSIGNED_ORDER = "assigned_order";

  // -------------------- USER ID --------------------
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_USER_ID, id);
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_USER_ID) ?? "";
  }

  // -------------------- MOBILE --------------------
  static Future<void> saveMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_MOBILE, mobile);
  }

  static Future<String> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_MOBILE) ?? "";
  }

  // -------------------- TOKENS --------------------
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_ACCESS_TOKEN, accessToken);
    await prefs.setString(KEY_REFRESH_TOKEN, refreshToken);
    await prefs.setString(KEY_EXPIRES_IN, expiresIn);
  }

  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_ACCESS_TOKEN) ?? "";
  }

  static Future<String> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_REFRESH_TOKEN) ?? "";
  }

  static Future<String> getExpiresIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_EXPIRES_IN) ?? "";
  }

  // -------------------- BANK DETAILS --------------------
  static Future<void> saveBankDetailsLocal({
    required String holder,
    required String number,
    required String ifsc,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_ACC_HOLDER, holder);
    await prefs.setString(KEY_ACC_NUMBER, number);
    await prefs.setString(KEY_IFSC, ifsc);
    await prefs.setString(KEY_LINKED_MOBILE, mobile);
  }

  static Future<Map<String, String>> getBankDetailsLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "holder": prefs.getString(KEY_ACC_HOLDER) ?? "",
      "number": prefs.getString(KEY_ACC_NUMBER) ?? "",
      "ifsc": prefs.getString(KEY_IFSC) ?? "",
      "mobile": prefs.getString(KEY_LINKED_MOBILE) ?? "",
    };
  }

  // -------------------- ASSIGNED ORDER SAVE / GET / CLEAR --------------------

  static Future<void> saveAssignedOrder(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_ASSIGNED_ORDER, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getAssignedOrder() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(KEY_ASSIGNED_ORDER);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr);
  }

  static Future<void> clearAssignedOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_ASSIGNED_ORDER);
  }

  // -------------------- CLEAR ALL (LOGOUT) --------------------
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(KEY_MOBILE);
    await prefs.remove(KEY_ACCESS_TOKEN);
    await prefs.remove(KEY_REFRESH_TOKEN);
    await prefs.remove(KEY_EXPIRES_IN);
    await prefs.remove(KEY_USER_ID);

    await prefs.remove(KEY_ACC_HOLDER);
    await prefs.remove(KEY_ACC_NUMBER);
    await prefs.remove(KEY_IFSC);
    await prefs.remove(KEY_LINKED_MOBILE);

    // ⭐ Clear assigned order also
    await prefs.remove(KEY_ASSIGNED_ORDER);
  }
}
