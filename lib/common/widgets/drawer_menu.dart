import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/app_color.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../features/auth/login/controller/user_controller.dart';

class DrawerMenu extends StatefulWidget {
  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.mintGreenBG,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children:[ Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: Dimensions.paddingSizeTwenty, top: Dimensions.paddingSizeSixty, bottom: Dimensions.paddingSizeTwenty,right: Dimensions.paddingSizeTwenty),
                decoration: BoxDecoration(
                  color: AppColor.mintGreenBG
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColor.neviBlue.withOpacity(0.2),
                        child: Icon(Icons.person, size: 50, color: AppColor.neviBlue)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${userController.user.value?.firstName}", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeTwenty, color: AppColor.neviBlue,)),
                        SizedBox(height: 2,),
                        Text("01XXXXXXXXX", style: quicksandRegular.copyWith(fontSize: Dimensions.fontSizeTwelve, color: AppColor.grey4)),
                      ],
                    ),
                  ],
                ),
              ),
                Positioned(child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.close,size: 25,color: AppColor.blackOlive,))),)
        ]
            ),
            SizedBox(height: 20,),
            Divider(
              thickness: 2,
              indent: 15,
              endIndent: 15,
              color: AppColor.grey3.withOpacity(0.4),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () {
                //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage()));
              },
              leading: Icon(Icons.headphones, size: 22,color: AppColor.neviBlue,),
              title: Text("Help Line", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen,fontWeight: FontWeight.w700,color: AppColor.neviBlue)),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.settings_outlined, size: 22,color: AppColor.neviBlue,),
              title: Text("Settings", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen,fontWeight: FontWeight.w700,color: AppColor.neviBlue)),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.lock_open_outlined, size: 22,color: AppColor.neviBlue,),
              title: Text("Change Password", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen,fontWeight: FontWeight.w700,color: AppColor.neviBlue)),
            ),
            ListTile(
              onTap: () {
                //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignupPage()));
              },
              leading: Icon(Icons.logout, size: 22,color: AppColor.neviBlue,),
              title: Text("Log out", style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeSixteen,fontWeight: FontWeight.w700,color: AppColor.neviBlue)),
            ),
          ],
        ),
      ),
    );
  }
}