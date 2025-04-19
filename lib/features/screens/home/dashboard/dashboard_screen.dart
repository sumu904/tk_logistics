import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';

import '../../../../util/app_color.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';
import 'billing_unit_report/screen/billing_unit_report.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.neviBlue,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22,
            color: AppColor.white,
          ),
        ),
        title: Text(
          "Dashboard",
          style: quicksandBold.copyWith(
              fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
        ),
      ),
      body: Padding(
        padding:EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwenty,vertical: Dimensions.paddingSizeTwenty),
        child: Column(
          children: [
            CustomButton(text: "Unit Wise Bill Summary",height:42,width: double.infinity,onTap: (){
              Get.toNamed("BillingUnitReport");
            },),
            CustomButton(text: "Trip Type Wise Income",height:42,width: double.infinity,onTap: (){
              Get.toNamed("TripTypeReport");
            },),
            CustomButton(text: "Depot Wise Fuel Consumption",height:42,width: double.infinity,onTap: (){
              Get.toNamed("FuelConsumptionReport");
            },)
          ],
        ),
      ),
    );
  }
}


