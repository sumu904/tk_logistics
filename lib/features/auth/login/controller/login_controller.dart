import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/features/screens/home/home_screen.dart';

import '../../../../util/app_color.dart';
import '../api/login_api.dart';
import 'user_controller.dart';

/*class LoginController extends GetxController {
  // Controllers for text fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable variables
  var isChecked = false.obs;
  var hidePassword = true.obs;
  var isLoading = false.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  // Handle checkbox toggle
  void toggleRememberMe(bool? value) {
    isChecked.value = value ?? false;
  }

  // Login function
  void login() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 2)); // Simulate a network request
    isLoading.value = false;

    // Example authentication logic
    if (phoneController.text == "01XXXXXXXXX" && passwordController.text == "password") {
      Get.snackbar("Success", "Login successful!", backgroundColor: AppColor.seaGreen, colorText: Colors.white);
      Get.toNamed("HomeScreen"); // Navigate to home screen
    } else {
      Get.snackbar("Error", "Invalid Phone no or password", backgroundColor: AppColor.primaryRed, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}*/


class LoginController extends GetxController {
  var isLoading = false.obs;
  var hidePassword = true.obs;
  var isChecked = false.obs;

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginApi _loginApi = LoginApi();
  final userController = Get.put(UserController());// Initialize LoginApi

  // Call this function to perform the login
  Future<void> login() async {
    // Set the loading state to true to show loading indicator
    isLoading(true);

    try {
      // Call the API to perform login
      final user = await _loginApi.login(
        userNameController.text,
        passwordController.text,
        Get.context!,  // Pass the context from GetX
      );
      print("${user?.firstName}");

      // If login is successful, navigate to the next page
      if (user!= null) {
        userController.setUser(user);
        Get.offAll(() => HomeScreen());
        Get.snackbar(
          'Login Successful',
          'Successfully Logged In',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.seaGreen,
          colorText: AppColor.white,
        );// Navigate to NavBarPage
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid credentials. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
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
}
