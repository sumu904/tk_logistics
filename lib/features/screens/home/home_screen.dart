import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/features/screens/home/create_trip/create_trip_screen.dart';
import 'package:tk_logistics/features/screens/home/trip_history/screen/trip_history_screen.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/screen/vehicle_maintenance_screen.dart';
import '../../../common/common_lists/action_list.dart';
import '../../../common/widgets/drawer_menu.dart';
import '../../../util/app_color.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../auth/login/controller/user_controller.dart';
import 'dashboard/dashboard_screen.dart';
import 'fuel_entry/screen/fuel_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final userController = Get.find<UserController>();


    Widget getPageForIndex(int index) {
        switch (index) {
          case 0:
            return DashboardScreen();
          case 1:
            return CreateTripScreen();
          case 2:
            return TripHistoryScreen();
          case 3:
            return FuelEntryScreen();
          case 4:
            return VehicleMaintenanceScreen();
          default:
            return HomeScreen();
      }
    }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppColor.mintGreenBG,
          key: _scaffoldKey,
          endDrawer: DrawerMenu(),
          body: SingleChildScrollView(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40)),
                  color: AppColor.neviBlue),
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeTwentyFive,
                  vertical: Dimensions.paddingSizeForty),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: quicksandRegular.copyWith(
                            fontSize: Dimensions.fontSizeSixteen,
                            color: AppColor.white),
                      ),
                      Text(
                        "${userController.user.value?.firstName ?? 'Guest'}",
                        style: quicksandSemibold.copyWith(
                            fontSize: Dimensions.fontSizeTwenty,
                            color: AppColor.white),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState!.openEndDrawer();
                      },
                      icon: Icon(
                        Icons.grid_view_outlined,
                        color: AppColor.white,
                        size: 30,
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: Dimensions.paddingSizeTwenty,
                        right: Dimensions.paddingSizeTwenty,
                        bottom: Dimensions.paddingSizeTwenty,
                      ),
                      child: Column(
                        children: [
                          // First Item (Dashboard) - Only shown if access is "A"
                          if (userController.user.value?.access == "A") ...[
                            InkWell(
                              onTap: () {
                                Get.to(getPageForIndex(0)); // Dashboard Screen
                              },
                              child: Container(
                                width: double.infinity, // Full width
                                padding: EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeTwenty, // Reduced padding
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.neviBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: AssetImage("${actionList[0].image}"),
                                    ),
                                    SizedBox(height: 10), // Reduced gap
                                    Text(
                                      "${actionList[0].title}",
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: quicksandSemibold.copyWith(
                                        fontSize: Dimensions.fontSizeSixteen,
                                        color: AppColor.neviBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Rest of the items (2 per row)
                          GridView.builder(
                            padding: EdgeInsets.only(top: Dimensions.paddingSizeFifteen),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two items per row
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            itemCount: actionList.length-1,// Skip the first item (Dashboard) if access is not "A"
                            physics: NeverScrollableScrollPhysics(), // Prevents internal scrolling
                            shrinkWrap: true, // Allows it to fit within parent scroll
                            itemBuilder: (context, index) {
                              int actualIndex = index + 1; // Skip first item if access is not "A"
                              return InkWell(
                                onTap: () {
                                  Get.to(getPageForIndex(actualIndex));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeTwelve,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.neviBlue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: AssetImage("${actionList[actualIndex].image}"),
                                      ),
                                      SizedBox(height: 20), // Reduced spacing
                                      Text(
                                        "${actionList[actualIndex].title}",
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: quicksandSemibold.copyWith(
                                          fontSize: Dimensions.fontSizeSixteen,
                                          color: AppColor.neviBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                    )
                  ]))),
    );
  }
}