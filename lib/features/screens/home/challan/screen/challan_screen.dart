import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';

import '../../../../../common/widgets/custom_indicator.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import '../controller/challan_controller.dart';


class ChallanScreen extends StatelessWidget {
  final String tripNo;

  ChallanScreen({required this.tripNo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is initialized with tripNo
    final ChallanController controller = Get.put(ChallanController(tripNo));

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
            "Trip Summary",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeThirty,vertical: Dimensions.paddingSizeTwenty),
          child: GetBuilder<ChallanController>(
            builder: (controller) {
              if (controller.tripData == null) {
                return Center(child: spinkit);
              }

              final trip = controller.tripData;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwenty, vertical: Dimensions.paddingSizeTwenty),
                decoration: BoxDecoration(
                  color: AppColor.neviBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Challan No: ${trip?['xsornum'] ?? 'N/A'}",
                        style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeEighteen, fontWeight: FontWeight.w900, color: AppColor.neviBlue)),
                    SizedBox(height: 5,),
                    Text("From: ${trip?['xsdestin'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    Text("To: ${trip?['xdestin'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    /*Text("Vehicle Code : ${trip?['xvehicle'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    Text("Vehicle Number : ${trip?['xvmregno'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    */
                    trip?['xtype'] == "TMS"
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vehicle Code : ${trip?['xvehicle'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                        Text("Vehicle Number : ${trip?['xvmregno'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                      ],
                    )
                        : Text(
                      "Vehicle Number: ${trip?['xvehicle'] ?? 'N/A'}",
                      style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen),
                    ),
                    Text("Driver Name: ${trip?['xdriver'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    Text("Driver Mobile: ${trip?['xmobile'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    Text("Billing Unit: ${trip?['xproj'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    Text("Departure Date: ${trip?['xdate'] ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    Text("Freight: ${trip?['xtypecat']?.toString() ?? 'N/A'}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    Text("Cargo Weight: ${trip?['xinweight']?.toString() ?? 'N/A'} MT", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen)),
                    SizedBox(height: 40),
                    Center(
                      child: CustomButton(
                        height: 40,
                        width: 160,
                        text: "View Challan",
                        onTap: controller.generatePdf,
                      ),
                    ),
                  ],
                ),
              );
            },
          )

      ),
    );
  }
}