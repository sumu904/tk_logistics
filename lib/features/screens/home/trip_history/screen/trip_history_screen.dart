import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';
import '../../create_trip/create_trip_screen.dart';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeTwenty,
              vertical: Dimensions.paddingSizeTwenty),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Date",style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeEighteen,fontWeight: FontWeight.w800,color: AppColor.neviBlue),),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeFive,vertical: Dimensions.paddingSizeFive),
                decoration: BoxDecoration(
                  color: AppColor.neviBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                      _selectDate(context);
                    }, icon: Icon(Icons.calendar_today_outlined,color: AppColor.neviBlue,)),
                    Obx(() => Text(
                        controller.selectedDate.value == null
                            ? "Pick a date to view trips"
                            : " ${DateFormat('MMMM dd, yyyy').format(controller.selectedDate.value!)}",
                        style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen,color: AppColor.neviBlue,fontWeight: FontWeight.w700)
                    )),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeTwelve,
                    vertical: Dimensions.paddingSizeTwelve),
                decoration: BoxDecoration(
                    color: AppColor.neviBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    Obx(() => controller.selectedDate.value == null
                        ? SizedBox() // Hide list initially
                        : controller.filteredTrips.isEmpty
                            ? Center(child: Text("No trips found for this date"))
                            : ListView.builder(
                      shrinkWrap: true,
                          itemCount: controller.filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = controller.filteredTrips[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: Dimensions.paddingSizeEight,top: Dimensions.paddingSizeEight,bottom: Dimensions.paddingSizeEight),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                     Text("Vehicle Number : ${trip.vehicleNumber}",
                                          style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeEighteen,color: AppColor.neviBlue,fontWeight: FontWeight.w800)),
                                      Text(  "Trip no : ${trip.tripNo}",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen,color: AppColor.neviBlue),),
                                      Text("From: ${trip.from} → To: ${trip.to}",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.neviBlue),),
                                    ]
                                    ),
                                    IconButton(onPressed: (){
                                      Get.toNamed("CreateTripScreen");
                                    }, icon: Icon(Icons.arrow_forward_ios_outlined ,color: AppColor.neviBlue,))
                                  ],
                                ),
                              ),
                            );
                          },
                        )),],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
