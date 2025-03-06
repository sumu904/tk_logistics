import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../../../util/app_color.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPasswordField;
  final RxBool? hidePassword;
  final String? Function(String?)? validator;// Optional RxBool for password visibility

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPasswordField = false,
    this.validator,
    this.hidePassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: isPasswordField
          ? Obx(
              () => TextFormField(
                controller: controller,
                obscureText: hidePassword?.value ?? false,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: quicksandSemibold.copyWith(
                      color: AppColor.neviBlue,
                      fontSize: Dimensions.fontSizeFourteen),
                  prefixIcon: Icon(
                    icon,
                    size: 18,
                    color: AppColor.neviBlue,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword?.value ?? false
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColor.neviBlue,
                    ),
                    onPressed: () {
                      hidePassword?.toggle(); // Toggle visibility safely
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeTwelve),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1.5, color: AppColor.primaryRed),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 1.5, color: AppColor.neviBlue),
                      borderRadius: BorderRadius.circular(12)),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(width: 1.5,color: AppColor.primaryRed),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(width:1.5,color: AppColor.primaryRed),
                  ),
                ),
                validator: validator,
              ),
            )
          : TextFormField(
              controller: controller,
              style: quicksandSemibold.copyWith(
                  color: AppColor.blackOlive,
                  fontSize: Dimensions.fontSizeSixteen),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.5, color: AppColor.primaryRed),
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.5, color: AppColor.neviBlue),
                    borderRadius: BorderRadius.circular(12)),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 1.5,color: AppColor.primaryRed),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width:1.5,color: AppColor.primaryRed),
                ),
                prefixIcon: Icon(
                  icon,
                  size: 18,
                  color: AppColor.neviBlue,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeTwelve),
                hintText: hint,
                hintStyle: quicksandSemibold.copyWith(
                    color: AppColor.neviBlue,
                    fontSize: Dimensions.fontSizeFourteen),
              ),
        validator: validator,
            ),
    );
  }
}