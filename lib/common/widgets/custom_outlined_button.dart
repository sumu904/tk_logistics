import 'package:flutter/material.dart';

import '../../util/app_color.dart';
import '../../util/dimensions.dart';
import '../../util/styles.dart';

class CustomOutlinedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String text;
  final Color? color;
  final Color? textColor;
  final Color? disableColor;
  final bool isEnabled; // 🔹 Added to enable/disable button
  final Function()? onTap;

  const CustomOutlinedButton({
    super.key,
    this.height = 36,
    this.width = 105,
    required this.text,
    this.color,
    this.textColor,
    this.disableColor = Colors.grey, // 🔹 Default disabled color
    this.isEnabled = true, // 🔹 Default to enabled
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null, // ❌ Disable tap when not enabled
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSizeFifteen),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.5,
            color: isEnabled ? (color ?? AppColor.neviBlue) : disableColor!, // 🔹 Use disableColor when disabled
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusFive),
        ),
        child: Center(
          child: Text(
            text,
            style: quicksandBold.copyWith(
              color: isEnabled ? (textColor ?? AppColor.neviBlue) : Colors.grey, // 🔹 Grey out text when disabled
              fontSize: Dimensions.fontSizeFourteen,
            ),
          ),
        ),
      ),
    );
  }
}


/*
class CustomOutlinedButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String text;
  final Color? color;
  final Color? textColor;
  final Function()? onTap;

  const CustomOutlinedButton({super.key, this.height = 36, this.width = 105,required this.text, this.color,
    this.textColor, this.onTap, });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSizeFifteen),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5,color: color ?? AppColor.neviBlue),
          borderRadius: BorderRadius.circular(Dimensions.radiusFive),
        ),
        child: Center(
          child: Text(text, style: quicksandBold.copyWith(color: textColor ?? AppColor.blackOlive, fontSize: Dimensions.fontSizeEighteen)),
        ),
      ),
    );;
  }
}*/
