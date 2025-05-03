import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tk_logistics/features/screens/initial/initial_screen.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';

import '../../../util/app_color.dart';
import '../../auth/login/controller/login_controller.dart';
import '../../auth/login/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _secondTextController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _secondTextFadeAnimation;
  Animation<Offset>? _secondTextSlideAnimation;

  final loginController = Get.put(LoginController()); // Get LoginController instance

  @override
  void initState() {
    super.initState();

    // Main controller for the first text animation
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Controller for the second text animation (with delay)
    _secondTextController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _secondTextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _secondTextController, curve: Curves.easeIn),
    );

    _secondTextSlideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _secondTextController, curve: Curves.easeOut),
    );

    // Start the first text animation
    _controller.forward();

    // After the first animation completes, start the second text animation
    Future.delayed(Duration(seconds: 2), () {
      _secondTextController.forward();
    });

    // Check login status after 5 seconds (after animations)
    Future.delayed(Duration(seconds: 6), () async {
      bool isLoggedIn = await Get.find<LoginController>().checkLoginStatus();
      if (isLoggedIn) {
        Get.offAll(() => HomeScreen());
      } else {
        Get.offAll(() => InitialScreen());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: AppColor.neviBlue,
        child: Center(
          child: _fadeAnimation == null || _slideAnimation == null
              ? SizedBox() // If animations aren't ready, show empty widget
              : Column(
            children: [
              SizedBox(height: size.height * 0.1),
              Image.asset("assets/images/logo_tk.png", width: size.width * 0.45, height: size.width * 0.45),
              SizedBox(height: size.height * 0.18),
              FadeTransition(
                opacity: _fadeAnimation!,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // First text (T.K. LOGISTICS)
                      Text(
                        "T.K. LOGISTICS",
                        style: sedanRegular.copyWith(
                          fontSize: Dimensions.fontSizeThirtyFour,
                          color: AppColor.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      // Second text (Drive Excellence) starts after delay
                      FadeTransition(
                        opacity: _secondTextFadeAnimation!,
                        child: SlideTransition(
                          position: _secondTextSlideAnimation!,
                          child: Text(
                            "Drive Excellence",
                            style: quicksandBold.copyWith(
                              fontSize: Dimensions.fontSizeTwentyFour,
                              color: AppColor.yellow,
                              fontStyle: FontStyle.italic,
                            ),
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
      ),
    );
  }
}