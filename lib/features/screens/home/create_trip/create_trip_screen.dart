import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/features/screens/home/create_trip/3ms/screen/threems_trip.dart';
import 'package:tk_logistics/features/screens/home/create_trip/tms/screen/tms_trip.dart';
import 'package:tk_logistics/util/app_color.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /*final AttendanceController attendanceController = Get.put(AttendanceController());
  final LocationController locationController = Get.find();*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
        appBar: AppBar(
          backgroundColor: AppColor.neviBlue,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {Get.back();},
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                size: 20,
                color: AppColor.white,
              )),
          title: Text(
            "Create New Trip",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          ),
        ),
        body: Column(children: [
          // TabBar at the top
          TabBar.secondary(
            controller: _tabController,
            indicatorColor: AppColor.neviBlue,
            labelColor: AppColor.neviBlue,
            unselectedLabelColor: AppColor.grey3,
            labelStyle: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeSixteen,
                fontWeight: FontWeight.w900),
            tabs: [
              Tab(text: "TMS Trip"),
              Tab(text: "3MS Trip"),
            ],
          ),

          // TabBarView wrapped in Expanded
          Expanded(
              child: TabBarView(controller: _tabController, children:  [
            TmsTrip(),
            ThreemsTrip(),
          ]))
        ]));
  }
}