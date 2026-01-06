import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_deliveryapp/Auth/view/Earnings.dart';
import 'package:restro_deliveryapp/Auth/view/Orders.dart';
import 'package:restro_deliveryapp/Auth/view/Profile.dart';
import 'package:restro_deliveryapp/Homeview/View/Homveiw.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  final screens = [
    const DeliveryDashboardScreen(),
    const MyOrdersScreen(),
    const DeliveryEarningsScreen(),
    DeliveryProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  /// 🔙 BACK PRESS HANDLING
  Future<bool> _onWillPop() async {
    if (currentIndex != 0) {
      // If not on Dashboard → go to Dashboard
      setState(() {
        currentIndex = 0;
      });
      return false; // ❌ app exit mat karo
    }
    // If already on Dashboard → allow app exit
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: screens[currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() => currentIndex = index);
            },
            selectedItemColor: const Color(0xFF8B0000),
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            unselectedLabelStyle:
                GoogleFonts.poppins(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.currency_rupee),
                label: "Earnings",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
