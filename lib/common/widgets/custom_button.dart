import 'package:flutter/material.dart';
import '../../../util/app_color.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String text;
  final Color? color;
  final Color? textColor;
  final Function()? onTap;
  const CustomButton({super.key, this.height = 36, this.width = 105,required this.text,this.color = AppColor.neviBlue,
    this.textColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: Dimensions.marginSizeFifteen,vertical: Dimensions.marginSizeTen),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dimensions.radiusEight),
        ),
        child: Center(
          child: Text(text, style: quicksandBold.copyWith(color: textColor ?? AppColor.white,fontSize: Dimensions.fontSizeFourteen )),
        ),
      ),
    );
  }
}