import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/common/widgets/custom_textfield.dart';
import 'package:tk_logistics/util/app_color.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_indicator.dart';
import 'controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>(); // Define a GlobalKey for the form


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeFifteen,vertical: Dimensions.paddingSizeTwentyTwo),
          child: Column(
            children: [
              SizedBox(height: 80,),
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage("assets/images/truck.gif")),
              SizedBox(height: 20,),
              Text("T.K. Logistics",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeTwentyFour,color: AppColor.neviBlue),),
              SizedBox(height: 80,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: loginController.userNameController,
                      hint: "User name",
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        } else if (value.length < 3) {
                          return 'Username must be at least 3 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      controller: loginController.passwordController,
                      hint: "Password",
                      icon: Icons.lock,
                      isPasswordField: true,
                      hidePassword: loginController.hidePassword, // Use reactive variable
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTen),
                child: Row(
                  children: [
                    Obx(() => Checkbox(
                      value: loginController.isChecked.value,
                      onChanged: (value) {
                        loginController.isChecked(value);
                      },
                      activeColor: AppColor.white,
                      checkColor: AppColor.primaryRed,
                      side: WidgetStateBorderSide.resolveWith(
                              (states) => BorderSide(
                            color: loginController.isChecked == true
                                ? AppColor.primaryRed
                                : AppColor.neviBlue,
                            width: 2,
                          )),
                    )),
                    Text("Remember Me",
                        style: quicksandBold.copyWith(
                            fontSize: Dimensions.fontSizeFourteen,
                            color: AppColor.neviBlue)),
                    Spacer(),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: quicksandBold.copyWith(
                              fontSize: Dimensions.fontSizeFourteen,
                              color: AppColor.green),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => loginController.isLoading.value
                  ? Center(
                child: spinkit,
              )
                  : CustomButton(
                height: 45,
                width: 380,
                color: AppColor.neviBlue,
                text: "Log In",
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, proceed with login
                    loginController.login();
                  }
                },
              )),
            ],
          ),
          ),
      ),
    );
  }
}
