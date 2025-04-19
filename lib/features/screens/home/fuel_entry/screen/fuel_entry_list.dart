import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/features/auth/login/controller/user_controller.dart';
import 'package:tk_logistics/features/screens/home/fuel_entry/controller/fuel_entry_controller.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import 'fuel_entry_user_list.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FuelEntryList extends StatelessWidget {
  final FuelEntryController controller = Get.put(FuelEntryController());
  final userController = Get.find<UserController>();

  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.pickDate(picked); // Update controller state
      print("Selected Date: ${DateFormat("yyyy-MM-dd").format(picked)}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.neviBlue,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, size: 22, color: AppColor.white),
        ),
        title: Text(
          "Fuel Entry List",
          style: quicksandBold.copyWith(
              fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeTwenty,
          vertical: Dimensions.paddingSizeTwenty,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Label
            Text(
              "Date",
              style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen,
                fontWeight: FontWeight.w800,
                color: AppColor.neviBlue,
              ),
            ),
            SizedBox(height: 10),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeFifteen,
                    vertical: Dimensions.paddingSizeFifteen),
                decoration: BoxDecoration(
                    color: AppColor.neviBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, color: AppColor.neviBlue),
                    SizedBox(width: 15),
                    Obx(() => Text(
                      controller.selectedDate.value == null
                          ? "Pick a date to view trips"
                          : DateFormat('MMMM dd, yyyy').format(controller.selectedDate.value!),
                      style: quicksandSemibold.copyWith(
                          fontSize: Dimensions.fontSizeSixteen,
                          color: AppColor.neviBlue,
                          fontWeight: FontWeight.w700),
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),

            // Fuel Entries List
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeFifteen,
                  vertical: Dimensions.paddingSizeFifteen),
              decoration: BoxDecoration(
                  color: AppColor.neviBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Obx(() {
                if (controller.selectedDate.value == null) {
                  return Center(
                    child: Text(
                      "Select a date to view fuel entries.",
                      style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeSixteen,
                          color: AppColor.primaryRed,
                          fontWeight: FontWeight.w800),
                    ),
                  );
                }

                // ✅ Format selected date
                String formattedDate = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value!);

                // ✅ Filter fuel entries
                var filteredEntries = controller.fuelEntries
                    .where((entry) =>
                entry['zemail'] == userController.user.value?.username &&
                    entry['xdate'] != null &&
                    DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['xdate'])) == formattedDate)
                    .toList()
                  ..sort((a, b) => DateTime.parse(b['xdate']).compareTo(DateTime.parse(a['xdate'])));

                if (filteredEntries.isEmpty) {
                  return Center(
                    child: Text(
                      "No fuel entry found for this date",
                      style: quicksandBold.copyWith(
                          fontSize: Dimensions.fontSizeSixteen,
                          color: AppColor.primaryRed,
                          fontWeight: FontWeight.w800),
                    ),
                  );
                }

                return SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height -
                      ( // Subtract heights of the elements above
                          kToolbarHeight + // Default app bar height (if exists)
                              MediaQuery
                                  .of(context)
                                  .padding
                                  .top + // Status bar height
                              Dimensions.paddingSizeTwenty *
                                  1 + // Padding from top and bottom
                              10 + // Space after Trip Type
                              10 + // Space after Date label
                              Dimensions.paddingSizeFifteen *
                                  5 + // Date Picker Container height
                              10 + // Space after Date Picker
                              Dimensions.paddingSizeFifteen *
                                  5 + // Container padding for trip list
                              10 // Approximate height of "No trips found" message or any extra margin
                      ),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      var entry = filteredEntries[index];
                  
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: Dimensions.marginSizeTen),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeTen,
                          vertical: Dimensions.paddingSizeTen,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vehicle ID : ${entry['xvehicle'] ?? 'Unknown'}",
                              style: quicksandBold.copyWith(
                                fontSize: Dimensions.fontSizeSixteen,
                                color: AppColor.neviBlue,
                              ),
                            ),
                            Text(
                              "Vehicle Number : ${entry['xvmregno'] ?? 'Unknown'}",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ),
                            Text(
                              "Driver Name : ${entry['xdriver'] ?? 'Unknown'}",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ),
                            Text(
                              "Date: ${entry['xdate'] != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(entry['xdate'])) : 'null'}",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ),
                            Text(
                              "Fuel Type: ${entry['xtype'] ?? 'Unknown'}",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ),
                            Text(
                              "Fuel Quantity : ${NumberFormat('0.0').format(double.tryParse(entry['xqtyord']?.toString() ?? '') ?? 0)} L",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ),
                            Text(
                              "Pump Name : ${entry['xwh'] ?? 'Unknown'} ",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ),
                            Text(
                              "User ID : ${entry['zemail'] ?? 'Unknown'} ",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeFourteen),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}