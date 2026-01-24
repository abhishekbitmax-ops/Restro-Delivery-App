class ApiEndpoint {
  // 🌍 Base API URL (for all API requests)
  static const String baseUrl = "https://sog.bitmaxtest.com/api/v1/delivery";

  //Patient App Endpoints

  // 🔹 AUTHENTICATION ENDPOINTS
  static const String register = "/Self-register";
  static const String login = "/login";
  static const String toggleOnline = "/online-offline";

  static const String getprofile = "/profile";
  static const String editProfile = "/edit-profile"; // ⭐ Added
  static const String changePassword = "/change-password"; // ⭐ Addedq

  // ⭐ NEW ORDER APIs
  static const String activeOrder = "/active-order";
  static const String completedOrder = "/completed-order";
  static const String orderCount = "/order-count";
  static const String assignedOrder = "/assigned-order";

  static const String accountDetails = "/account-details";
  static const String payoutDetails = "/payout-details";

  // 🧩 Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }
}
