// QUICK REFERENCE - Call these functions to control location tracking

import 'package:restro_deliveryapp/utils/location_helper.dart';

// ✅ START location tracking (in deliveryscreen.dart - ALREADY ADDED)
await startDeliveryTracking(authToken, orderId);

// 🛑 STOP location tracking (in Deliveysuccess.dart - ALREADY ADDED)
await stopDeliveryTracking();

// ===================================================================
// WHAT HAPPENS AUTOMATICALLY AFTER YOU CALL startDeliveryTracking()
// ===================================================================

// 1️⃣ Service initializes with:
//    - 5 second interval
//    - Foreground notification enabled
//    - Wake lock enabled (keeps service alive)
//    - Background location enabled

// 2️⃣ Every 5 SECONDS, the service will:
//    - Get current GPS location
//    - Prepare location data (lat, lon, timestamp)
//    - Send to API: http://192.168.1.108:5004/api/v1/location/update-location
//    - Update notification with current coordinates

// 3️⃣ If API call FAILS:
//    - Automatically retry up to 3 times
//    - With exponential backoff (2s, 4s, 6s wait)
//    - Retry on network errors
//    - Retry on server errors (5xx)

// 4️⃣ Service runs:
//    - ✅ When app is in foreground
//    - ✅ When app is in background
//    - ✅ Even when app is completely CLOSED
//    - ✅ Persists across device restarts (autoRunOnBoot: true)

// 5️⃣ Real-time notification shows:
//    📍 Latitude and Longitude
//    ✅ When location was sent
//    ⚠️ If there are errors

// ===================================================================
// CONSOLE LOGS TO WATCH FOR
// ===================================================================

// 🟢 GOOD LOGS (Success):
// ✅✅✅ LOCATION UPDATE SUCCESS!
// Response: {"message":"Location updated successfully"}

// 🔴 BAD LOGS (Issues):
// ❌ Max retries reached - Location update failed
// ⚠️ GPS is OFF
// ⚠️ Permission DENIED
// ⚠️ Missing credentials

// ===================================================================
// FILES YOU CAN CUSTOMIZE
// ===================================================================

// 1. Change API URL: lib/utils/forgroundservice.dart (line with _apiUrl)
// 2. Change interval: lib/utils/forgroundservice.dart (interval: 5000)
// 3. Add more fields to API call: lib/utils/forgroundservice.dart (jsonEncode)
// 4. Change notification text: lib/utils/forgroundservice.dart (_updateNotification)

// ===================================================================
// TESTING CHECKLIST
// ===================================================================

// ✓ Device has GPS enabled
// ✓ App has Location permission granted (show in settings)
// ✓ Device has internet connection
// ✓ Firebase/API backend is running
// ✓ Token is valid (not expired)
// ✓ OrderId format matches backend
// ✓ No firewall blocking port 5004

// Run: flutter logs | grep -i "location\|api\|tracking"
// To see only location-related logs
