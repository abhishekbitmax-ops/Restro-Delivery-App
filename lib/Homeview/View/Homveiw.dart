import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/controller/Authcontroller.dart';
import 'package:restro_deliveryapp/Auth/view/Orderpickup.dart';
import 'package:restro_deliveryapp/Auth/view/Orders.dart';
import 'package:restro_deliveryapp/utils/SharedPref.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';



class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  bool hasAssignedOrder = false;  
  bool isOnline = true;

  final AuthController auth = Get.put(AuthController());

  String? userName;

  int activeOrders = 0;
  int completedOrders = 0;
  int orderCount = 0;

  Map<String, dynamic>? assignedOrderData;

  /// SOCKET INSTANCE
  late IO.Socket orderSocket;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    loadOrderData();
    connectOrderSocket();   // ⭐ SOCKET CONNECT
  }

  /// ⭐ CONNECT SOCKET.IO
  void connectOrderSocket() async {
    String? token = await SharedPre.getAccessToken();  // tumhara saved JWT token

    orderSocket = IO.io(
  "http://192.168.1.108:5004/orders",  // ✔ Correct socket namespace
  IO.OptionBuilder()
      .setTransports(['websocket'])
      .enableForceNew()
      .enableAutoConnect()
      .setAuth({"token": token})
      .build(),
);


    /// CONNECTED
    orderSocket.onConnect((_) {
      print("✔️ SOCKET CONNECTED TO ORDERS NAMESPACE");
    });

    /// TOKEN VERIFIED
    orderSocket.on("CONNECTION_ESTABLISHED", (data) {
      print("🔥 CONNECTION_ESTABLISHED: $data");
    });

    /// ⭐ DELIVERY ASSIGNED REALTIME EVENT
    orderSocket.on("DELIVERY_ASSIGNED", (data) {
      print("📦 NEW DELIVERY ASSIGNED: $data");

      
  // ⭐ Save to Local Storage
  SharedPre.saveAssignedOrder(data);


      setState(() {
        hasAssignedOrder = true;
        assignedOrderData = data;
      });

       // ⭐ Toast Notification
  Fluttertoast.showToast(
    msg: "📦 New delivery assigned!",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.TOP,
    backgroundColor: Colors.black87,
    textColor: Colors.white,
    fontSize: 16.0,
  );

      Get.snackbar(
        "New Order Assigned",
        "A new delivery has been assigned!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });

   /// ⭐ ORDER STATUS UPDATED
orderSocket.on("ORDER_STATUS_UPDATED", (data) {
  print("🔄 ORDER_STATUS_UPDATED: $data");
  loadOrderData(); // refresh UI
});

    orderSocket.onError((err) {
      print("❌ SOCKET ERROR: $err");
    });
  }

  /// ⭐ FETCH USERNAME
  void fetchUserName() async {
    var profile = await auth.getProfile();
    if (mounted) {
      setState(() {
        userName = profile?.data?.name ?? "";
      });
    }
  }

  /// ⭐ LOAD ORDER DATA
void loadOrderData() async {
  var active = await auth.getActiveOrder();
  var completed = await auth.getCompletedOrder();
  var count = await auth.getOrderCount();

  // ⭐ API assigned order
  var assigned = await auth.getAssignedOrder();

  // ⭐ Local storage assigned order
  var localAssigned = await SharedPre.getAssignedOrder();

  if (mounted) {
    setState(() {
      // Update counts
      activeOrders = active?["data"]?.length ?? 0;
      completedOrders = completed?["data"]?.length ?? 0;
      orderCount = count?["data"]?["activeOrders"] ?? 0;

      // ⭐ PRIORITY 1 → If API sends assigned order
      if (assigned != null && assigned["data"] != null) {
        hasAssignedOrder = true;
        assignedOrderData = assigned["data"];

        // ⭐ Save latest order into local storage
        SharedPre.saveAssignedOrder(assigned["data"]);
      }

      // ⭐ PRIORITY 2 → If API says no assigned order BUT we have local data
      else if (localAssigned != null) {
        hasAssignedOrder = true;
        assignedOrderData = localAssigned;
      }

      // ⭐ PRIORITY 3 → No assigned order anywhere
      else {
        hasAssignedOrder = false;
        assignedOrderData = null;
      }
    });
  }
}


  /// ⭐ DISPOSE SOCKET
  @override
  void dispose() {
    orderSocket.dispose();
    super.dispose();
  }

  // ⭐ (Rest of your UI code remains SAME – untouched)

  Widget _statusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.06)],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                blurRadius: 26,
                color: color.withOpacity(0.18),
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 20),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF7A0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ColorFiltered(
      colorFilter: isOnline
          ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
          : const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 1, 0,
            ]),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: Column(
          children: [
            // ⭐ HEADER (Untouched)
            Container(
              padding: EdgeInsets.only(
                top: topPadding + 18,
                bottom: 28,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7A0000), Color(0xFFB11212)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 14,
                              color: Colors.black.withOpacity(0.35),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/restro_logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Swaad of Grandmaa",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Delivery Partner Dashboard",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () async {
                          var result = await auth.toggleOnlineStatus();

                          if (result != null && result["success"] == true) {
                            setState(() {
                              isOnline = result["data"]["isOnline"];
                            });

                            Get.snackbar(
                              "Status Updated",
                              result["message"],
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              "Error",
                              "Unable to change status",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 60,
                          height: 33,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isOnline
                                ? const Color(0xFF1E6F4F)
                                : const Color(0xFF3A3A3A),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            alignment: isOnline
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      userName == null || userName!.isEmpty
                          ? "Welcome back "
                          : "Welcome back, $userName ",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _statusCard(
                          title: "Active Orders",
                          value: activeOrders.toString(),
                          icon: Icons.delivery_dining_outlined,
                          color: const Color(0xFF8B0000),
                          onTap: () => Get.to(const MyOrdersScreen()),
                        ),
                        const SizedBox(width: 18),
                        _statusCard(
                          title: "Completed",
                          value: completedOrders.toString(),
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 42),

                    Text(
                      "Current Assignment",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 18),

                   hasAssignedOrder
    ? GestureDetector(
        onTap: () => Get.to(() => PickupScreen(orderData: assignedOrderData!)),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.red.shade50],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                blurRadius: 28,
                color: Colors.red.withOpacity(0.22),
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ----- TAG -----
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "ORDER ASSIGNED",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.black45),
                ],
              ),

              const SizedBox(height: 22),

              // ----- ORDER ID -----
              Text(
                "Order ID: ${assignedOrderData?['customOrderId'] ?? '-'}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // ----- CUSTOMER NAME -----
              Text(
                "Customer: ${assignedOrderData?['customer']?['name'] ?? '-'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              // ----- CUSTOMER PHONE -----
              Text(
                "Phone: ${assignedOrderData?['customer']?['phone'] ?? '-'}",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 12),

              // ----- ITEMS -----
              Text(
                "Items:",
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),

              ...((assignedOrderData?["items"] ?? []) as List)
                  .map((item) => Text(
                        "• ${item['name']}  x${item['quantity']} (₹${item['finalItemPrice']})",
                        style: GoogleFonts.poppins(fontSize: 13),
                      )),

              const SizedBox(height: 16),

              // ----- ADDRESS -----
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade100,
                    ),
                    child: const Icon(Icons.location_on,
                        size: 16, color: Colors.redAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${assignedOrderData?['location']?['addressLine']}, "
                      "${assignedOrderData?['location']?['city']} - "
                      "${assignedOrderData?['location']?['pincode']}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ----- PRICE -----
              Text(
                "Grand Total: ₹${assignedOrderData?['price']?['grandTotal'] ?? 0}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      )
    : Center(
        child: Text(
          "No Order Assigned",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
      
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
