import 'package:get/get.dart';
import 'package:tk_logistics/util/app_color.dart';

import '../api/model/user.dart';
import '../login_screen.dart';

class UserController extends GetxController {
  var user = Rx<User?>(null); // Store user data (initially null)

  // Method to update user data
  void setUser(User userData) {
    user.value = userData;
  }

  void logout() {
    user.value = null; // Clear user data
    Get.offAll(() => LoginScreen()); // Navigate to login screen
    Get.snackbar(
      'Logout Successful',
      'You have been logged out.',
      snackPosition: SnackPosition.TOP,
      backgroundColor:AppColor.seaGreen,
      colorText: AppColor.white,
    );
  }
}