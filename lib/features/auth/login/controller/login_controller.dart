import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/features/screens/home/home_screen.dart';

import '../../../../util/app_color.dart';
import '../../../screens/home/trip_history/controller/trip_history_controller.dart';
import '../api/login_api.dart';
import '../api/model/user.dart';
import 'user_controller.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final tripHistoryController = Get.put(TripHistoryController());

  var isLoading = false.obs;
  var hidePassword = true.obs;
  var isChecked = false.obs;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginApi _loginApi = LoginApi();
  final userController = Get.put(UserController());

  @override
  void onInit() {
    super.onInit();
    loadCredentials(); // Load saved credentials
  }

  @override
  void onClose() {
    userNameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // New Method to check login status when app starts
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the user is logged in
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Retrieve user data
      String? firstName = prefs.getString('firstName');
      String? lastName = prefs.getString('lastName');
      String? username = prefs.getString('username');
      String? access = prefs.getString('access');

      // Set the user data in the UserController
      Get.find<UserController>().setUser(User(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        username: username ?? '',
        access: access ?? '',
      ));

      return true; // User is logged in
    }

    return false; // User is not logged in
  }



  Future<void> login() async {
    isLoading(true);

    try {
      final user = await _loginApi.login(
        userNameController.text,
        passwordController.text,
        Get.context!,
      );
      print("${user?.firstName}");

      if (user != null) {
        userController.setUser(user);

        // Save the user data to SharedPreferences after successful login
        await saveUserData(user);

        Get.offAll(() => HomeScreen());
        Get.snackbar(
          'Login Successful',
          'Successfully Logged In',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColor.seaGreen,
          colorText: AppColor.white,
        );
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid credentials. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }


  Future<void> saveUserData(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('firstName', user.firstName ?? '');
    await prefs.setString('lastName', user.lastName ?? '');
    await prefs.setString('username', user.username ?? '');
    await prefs.setString('access', user.access ?? '');
    await prefs.setBool('isLoggedIn', true);  // Save login status
  }


  // Save login info and isLoggedIn = true
  Future<void> saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', userNameController.text);
    await prefs.setString('password', passwordController.text);
    await prefs.setBool('rememberMe', true);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.setBool('rememberMe', false);
    await prefs.setBool('isLoggedIn', false);
  }

  Future<void> loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      String? savedUsername = prefs.getString('username');
      String? savedPassword = prefs.getString('password');

      if (savedUsername != null && savedPassword != null) {
        userNameController.text = savedUsername;
        passwordController.text = savedPassword;
        isChecked.value = true;
      }
    }
  }
}

