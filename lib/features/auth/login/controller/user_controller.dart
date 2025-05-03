import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tk_logistics/util/app_color.dart';

import '../api/model/user.dart';
import '../login_screen.dart';

class UserController extends GetxController {
  var user = Rx<User?>(null); // Store user data (initially null)

  @override
  void onInit() {
    super.onInit();
    loadUserData(); // Load user data when the controller is initialized
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString('firstName');
    String? lastName = prefs.getString('lastName');
    String? username = prefs.getString('username');
    String? access = prefs.getString('access');

    if (firstName != null && lastName != null && username != null) {
      // Create a User object from the stored data
      User userData = User(
        firstName: firstName,
        lastName: lastName,
        username: username,
        access: access ?? '', // Default to empty string if access is null
      );
      setUser(userData);
    }
  }

  // Method to update user data
  void setUser(User userData) {
    user.value = userData;
  }

  void logout() async {
    user.value = null; // Clear the user data from the controller
    // Clear all user-related shared preferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('username');
    await prefs.remove('access');
    await prefs.remove('isLoggedIn'); // Remove the session flag
    // Navigate to login screen
    Get.offAll(() => LoginScreen());
    Get.snackbar(
      'Logout Successful',
      'You have been logged out.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor.seaGreen,
      colorText: AppColor.white,
    );
  }
}


/*class UserController extends GetxController {
  var user = Rx<User?>(null);

  void setUser(User userData) {
    user.value = userData;
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved credentials and login status

    user.value = null;
    Get.offAll(() => LoginScreen());
    Get.snackbar(
      'Logout Successful',
      'You have been logged out.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor.seaGreen,
      colorText: AppColor.white,
    );
  }
}*/
