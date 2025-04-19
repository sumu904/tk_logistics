import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../routes/routes_name.dart';
import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import '../controller/trip_history_controller.dart';

class TripHistoryScreen extends StatelessWidget {
  final TripHistoryController controller = Get.put(TripHistoryController());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.pickDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
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
            "Trip History",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeTwenty,
            vertical: Dimensions.paddingSizeTwenty),
        child: GetBuilder<TripHistoryController>(initState: (_) {
          controller.fetchTrips();
        }, builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Trip Type",
                    style: quicksandBold.copyWith(
                        fontSize: Dimensions.fontSizeEighteen,
                        fontWeight: FontWeight.w800,
                        color: AppColor.neviBlue),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Obx(() =>
                        RadioListTile<String>(
                          title: Text(
                            "TMS",
                            style: quicksandBold.copyWith(
                              fontSize: Dimensions.fontSizeSixteen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          value: 'TMS',
                          groupValue: controller.selectedOption.value,
                          onChanged: (value) => controller.changeOption(value!),
                        )),
                  ),
                  Expanded(
                    child: Obx(() =>
                        RadioListTile<String>(
                          title: Text(
                            "3MS",
                            style: quicksandBold.copyWith(
                              fontSize: Dimensions.fontSizeSixteen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          value: '3MS',
                          groupValue: controller.selectedOption.value,
                          onChanged: (value) => controller.changeOption(value!),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Date",
                style: quicksandBold.copyWith(
                    fontSize: Dimensions.fontSizeEighteen,
                    fontWeight: FontWeight.w800,
                    color: AppColor.neviBlue),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  _selectDate(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeFifteen,
                      vertical: Dimensions.paddingSizeFifteen),
                  decoration: BoxDecoration(
                      color: AppColor.neviBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColor.neviBlue,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Obx(() =>
                          Text(
                              controller.selectedDate.value == null
                                  ? "Pick a date to view trips"
                                  : " ${DateFormat('MMMM dd, yyyy').format(
                                  controller.selectedDate.value!)}",
                              style: quicksandSemibold.copyWith(
                                  fontSize: Dimensions.fontSizeSixteen,
                                  color: AppColor.neviBlue,
                                  fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeFifteen,
                    vertical: Dimensions.paddingSizeFifteen),
                decoration: BoxDecoration(
                    color: AppColor.neviBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() =>
                    controller.selectedDate.value == null
                        ? SizedBox() // Hide list initially
                        : controller.filteredTrips.isEmpty
                        ? Center(
                        child: Text(
                          "No trips found for this date",
                          style: quicksandBold.copyWith(
                              fontSize: Dimensions.fontSizeSixteen,
                              color: AppColor.primaryRed,
                              fontWeight: FontWeight.w800),
                        ))
                        : SizedBox(
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
                                     2.0 + // Padding from top and bottom
                                  10 + // Space after Trip Type
                                  10 + // Space after Date label
                                  Dimensions.paddingSizeFifteen *
                                      5 + // Date Picker Container height
                                  10 + // Space after Date Picker
                                  Dimensions.paddingSizeFifteen *
                                      5 + // Container padding for trip list
                                  50 // Approximate height of "No trips found" message or any extra margin
                          ),
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: controller.filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip =
                          controller.filteredTrips[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: Dimensions.marginSizeTen),
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeTen,
                                vertical: Dimensions.paddingSizeTen),
                            decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius:
                                BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Trip no : ${trip.tripNo}",
                                          style: quicksandBold.copyWith(
                                              fontSize: Dimensions
                                                  .fontSizeEighteen,
                                              color:
                                              AppColor.neviBlue,
                                              fontWeight:
                                              FontWeight.w800),
                                        ),
                                        Text(
                                          "${trip.tripType == 'TMS'
                                              ? 'Vehicle Code'
                                              : 'Vehicle Number'} : ${trip
                                              .vehicleID}",
                                          style: quicksandSemibold.copyWith(
                                            fontSize: Dimensions
                                                .fontSizeSixteen,
                                          ),
                                        ),

                                        if (trip.tripType == 'TMS' &&
                                            (trip.vehicleNo ?? '').isNotEmpty)
                                          Text(
                                              "Vehicle Number : ${trip
                                                  .vehicleNo}",
                                              style: quicksandSemibold.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeFourteen,
                                              )),
                                              Text(
                                                  "Driver Name : ${trip
                                                      .driverName}",
                                                  style: quicksandSemibold
                                                      .copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeFourteen,
                                                  )),
                                              Text(
                                                  "Driver Phone : ${trip
                                                      .driverPhone}",
                                                  style: quicksandSemibold
                                                      .copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeFourteen,
                                                  )),
                                              if
                                              (trip.pickVendor != null && trip.pickVendor
                                              !.isNotEmpty)
                                        Text(
                                            "Vendor Name : ${trip.pickVendor}",
                                            style: quicksandSemibold
                                                .copyWith(
                                              fontSize: Dimensions
                                                  .fontSizeFourteen,
                                            )),
                                        Text(
                                          "From: ${trip.from} → To: ${trip.to}",
                                          style: quicksandSemibold
                                              .copyWith(
                                            fontSize: Dimensions
                                                .fontSizeFourteen,
                                          ),
                                        ),
                                        Text(
                                            "Billing Unit : ${trip
                                                .billingUnit}",
                                            maxLines: 2,
                                            style: quicksandSemibold
                                                .copyWith(
                                              fontSize: Dimensions
                                                  .fontSizeFourteen,
                                            )),
                                      ]),
                                ),
                                IconButton(
                                  onPressed: () {
                                    final trip = controller
                                        .filteredTrips[index];
                                    // Extract the trip number
                                    final tripNo = trip
                                        .tripNo; // Assuming tripNo corresponds to 'xsornum' in API

                                    // Construct API URL with tripNo
                                    final String apiUrl = "http://103.250.68.75/api/v1/Trip_list?xsornum=$tripNo";

                                    // Ensure trip is converted to a Map<String, dynamic>
                                    Get.toNamed(
                                      controller.selectedOption.value == "TMS"
                                          ? RoutesName
                                          .updateTmsTrip // Use the route name from RoutesName
                                          : RoutesName.update3msTrip,
                                      // Use the route name from RoutesName
                                      arguments: {
                                        "tripNo": tripNo,
                                        "tripData": jsonDecode(jsonEncode(trip.toJson())), // Ensure it's a Map
                                        "apiUrl": apiUrl,
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    color: AppColor.neviBlue,
                                  ),
                                )


                              ],
                            ),
                          );
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
