class ApiEndpoint {
  // 🌍 Base API URL (for all API requests)
  static const String baseUrl = "https://resto-grandma.onrender.com/api/v1/delivery";

 

  //Patient App Endpoints

  // 🔹 AUTHENTICATION ENDPOINTS
  static const String register = "/Self-register";
  static const String login = "/login";
  static const String toggleOnline = "/online-offline";
    // static const String getprofile = "/profile";
        static const String changePassword = "/changepassword";




  


  // 🧩 Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }

 
}
