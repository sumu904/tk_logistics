import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controller/user_controller.dart';
import 'model/user.dart';

class LoginApi {
  final String apiUrl = 'http://103.250.68.75/api/v1/account/login/';

  Future<User?> login(String username, String password,
      BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print("Response Status: ${response.statusCode}");
        print("Response Body: ${response.body}");
        if (data.containsKey('data')) {
          if (data['data'].containsKey('username')) {
            print("User data from response: ${data['data']['username']}");
          } else {
            print("No 'user' key in data['data']");
          }
        } else {
          print("No 'data' key in API response");
        }

        if (data['status'] == 'success' && data['data'] != null) {
          final user = User.fromJson(data['data']); // Directly pass data['data']
          Get.find<UserController>().setUser(user);
          print("User object after login: ${user.firstName}");
          print("Login successful");
          return user;
        } else {
          print("Login failed: User data is missing");
          return null;
        }
      } else {
        print("invalid login details");
      }
    } catch (error) {
      print("Error occurred: $error");
      return null;
    }
    return null;
  }
}