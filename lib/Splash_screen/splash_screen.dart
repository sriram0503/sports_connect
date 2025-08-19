import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sports_c/Reusable/color.dart';
import 'package:sports_c/Reusable/image.dart';
import 'package:sports_c/login/login.dart';
import 'package:sports_c/user/Home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sports_c/navigation_bar/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  dynamic userId;
  dynamic roleId;

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("userId");
      roleId = prefs.getString("roleId");
    });
    debugPrint("SplashUserId: $userId");
    debugPrint("SplashRoleId: $roleId");
  }

  void onTimerFinished() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) =>  LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    getToken();
    Timer(const Duration(seconds: 5), () => onTimerFinished());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Image.asset(
          Images.splashLogo,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.4,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
