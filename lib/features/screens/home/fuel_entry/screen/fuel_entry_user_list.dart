import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import '../../../../auth/login/controller/user_controller.dart';
import '../controller/fuel_entry_controller.dart';

class FuelEntryUserList extends StatelessWidget {
  final FuelEntryController controller = Get.put(FuelEntryController());
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.mintGreenBG,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeTwenty,vertical: Dimensions.paddingSizeTwenty),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.fuelEntries.isEmpty) {
                    return Center(child: Text("No fuel entries available."));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.fuelEntries
                        .where((entry) => entry['zemail'] == userController.user.value?.username)
                        .length, // Filtered length
                    itemBuilder: (context, index) {
                      var filteredEntries = controller.fuelEntries
                          .where((entry) => entry['zemail'] == userController.user.value?.username)
                          .toList()
                        ..sort((a, b) => DateTime.parse(b['xdate']).compareTo(DateTime.parse(a['xdate']))); // Convert to list
                      var entry = filteredEntries[index]; // Get filtered entry

                      return Card(
                        margin: EdgeInsets.only(bottom: Dimensions.marginSizeFifteen),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeFifteen,
                            vertical: Dimensions.paddingSizeTen,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Vehicle ID : ${entry['xvehicle'] ?? 'Unknown'}",
                                style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeSixteen,
                                  color: AppColor.neviBlue,
                                ),
                              ),
                              Text(
                                "Vehicle Number : ${entry['xvmregno'] ?? 'Unknown'}",
                                style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                ),
                              ),
                              Text(
                                "Driver Name : ${entry['xdriver'] ?? 'Unknown'}",
                                style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                ),
                              ),
                              Text(
                                "Date: ${entry['xdate'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(entry['xdate'])) : 'null'}",
                                style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                ),
                              ),
                              Text(
                                "Fuel Type: ${entry['xtype'] ?? 'Unknown'}",
                                style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                ),
                              ),
                              Text(
                                "Fuel Quantity : ${NumberFormat('0.0').format(double.tryParse(entry['xqtyord']?.toString() ?? '') ?? 0)} L",
                                style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                ),
                              ),

                              Text(
                                "Pump Name : ${entry['xwh'] ?? 'Unknown'} ",
                                style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                ),
                              ),
                              Text(
                                "User ID : ${entry['zemail'] ?? 'Unknown'} ",
                                style: quicksandRegular.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                })
              ],
            ),
          ),
        )
    );
  }
}
