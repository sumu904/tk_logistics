import 'package:flutter/material.dart';

import '../../../../util/app_color.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';

class InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const InputField({
    Key? key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: quicksandSemibold.copyWith(
          color: AppColor.blackOlive,
          fontSize: Dimensions.fontSizeSixteen),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: quicksandSemibold.copyWith(color: AppColor.blackOlive),
        hintText: hint,
        hintStyle: quicksandSemibold.copyWith(
            color: AppColor.blackOlive,
            fontSize: Dimensions.fontSizeFourteen),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon,color: AppColor.persianGreen,) : null,
        focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(width: 2, color: AppColor.blackOlive),
        borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderSide:
            BorderSide(width: 2, color: AppColor.blackOlive),
        borderRadius: BorderRadius.circular(12)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 2,color: AppColor.primaryRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width:2,color: AppColor.primaryRed),
          ),
        border: InputBorder.none
      ),
    );
  }
}