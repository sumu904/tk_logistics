import 'package:get/get.dart';

import '../api/model/user.dart';

class UserController extends GetxController {
  var user = Rx<User?>(null); // Store user data (initially null)

  // Method to update user data
  void setUser(User userData) {
    user.value = userData;
  }
}