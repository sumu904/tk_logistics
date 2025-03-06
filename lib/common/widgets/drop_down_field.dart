import 'package:flutter/material.dart';

import '../../../../util/app_color.dart';
import '../../../../util/styles.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final Color textColor;
  final List<String> items;
  final Color itemTextColor;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const DropdownField({
    Key? key,
    required this.label,
    this.textColor = AppColor.blackOlive,
    required this.items,
    this.itemTextColor = AppColor.blackOlive,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      style: quicksandBold.copyWith(color: itemTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: quicksandBold.copyWith(color: textColor),
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
      ),
      items:
      items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
