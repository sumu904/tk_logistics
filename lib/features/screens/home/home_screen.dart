import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/features/screens/home/create_trip/create_trip_screen.dart';
import 'package:tk_logistics/features/screens/home/diesel_entry/screen/diesel_entry_screen.dart';
import 'package:tk_logistics/features/screens/home/trip_history/screen/trip_history_screen.dart';
import 'package:tk_logistics/features/screens/home/vehicle_maintenance/screen/vehicle_maintenance_screen.dart';

import '../../../common/common_lists/action_list.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/drawer_menu.dart';
import '../../../util/app_color.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../auth/login/controller/user_controller.dart';

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
        return CreateTripScreen();
      case 1:
        return TripHistoryScreen();
      case 2:
        return DieselEntryScreen();
      case 3:
        return VehicleMaintenanceScreen();
      default:
        return HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
                      "${userController.user.value?.firstName}",
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
            height: 20,
          ),
                  Padding(
                    padding: EdgeInsets.only(left: Dimensions.paddingSizeTwenty,right: Dimensions.paddingSizeTwenty,bottom: Dimensions.paddingSizeTwenty),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12
                        ),
                        itemCount: actionList.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context,index){
                          return  InkWell(
                            onTap: (){
                              Get.to(getPageForIndex(index));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeTwelve),
                              decoration: BoxDecoration(
                                  color: AppColor.neviBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 40 ,
                                    backgroundImage: AssetImage(
                                      "${actionList[index].image}",
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "${actionList[index].title}",
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: quicksandSemibold.copyWith(
                                        fontSize: Dimensions.fontSizeSixteen,
                                        color: AppColor.neviBlue),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ])));
  }
}