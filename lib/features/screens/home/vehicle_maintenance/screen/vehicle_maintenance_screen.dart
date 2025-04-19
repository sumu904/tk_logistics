import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tk_logistics/common/widgets/custom_button.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/controller/main_form_controller.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/screen/entry_list_screen.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/screen/main_form_screen.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/screen/task_info_screen.dart';

import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

class VehicleMaintenanceScreen extends StatefulWidget {
  const VehicleMaintenanceScreen({super.key});

  @override
  State<VehicleMaintenanceScreen> createState() => _VehicleMaintenanceScreenState();
}

class _VehicleMaintenanceScreenState extends State<VehicleMaintenanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void switchToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          "Vehicle Maintenance Entry Form",
          style: quicksandBold.copyWith(
            fontSize: Dimensions.fontSizeEighteen,
            color: AppColor.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeTwenty,
          vertical: Dimensions.paddingSizeTwenty,
        ),
        child: Column(
          children: [
            ButtonsTabBar(
              controller: _tabController,
              buttonMargin: EdgeInsets.symmetric(horizontal: Dimensions.marginSizeTen),
              contentPadding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeFifteen),
              backgroundColor: AppColor.neviBlue,
              unselectedBackgroundColor: AppColor.neviBlue.withOpacity(0.6),
              unselectedLabelStyle: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeTwelve,
                color: AppColor.white,
              ),
              labelStyle: quicksandBold.copyWith(
                color: AppColor.white,
                fontWeight: FontWeight.w900,
                fontSize: Dimensions.fontSizeFourteen,
              ),
              tabs: const [
                Tab(text: "Main form"),
                Tab(text: "Task info"),
                Tab(text: "Entry list"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  MainFormScreen(onSuccess: () => switchToTab(1)), //  callback here
                  TaskInfoScreen(),
                  EntryListScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}