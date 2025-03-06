import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/util/dimensions.dart';
import 'package:tk_logistics/util/styles.dart';

import '../../../util/app_color.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
   void initState() {
    // TODO: implement initState
    navigateToInitialScreen();
    super.initState();
  }

    navigateToInitialScreen()async{
    await Future.delayed(const Duration(seconds: 3), () {
     Get.toNamed("InitialScreen");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.mintGreenBG,
              AppColor.mint
            ]
          )
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("T.K. LOGISTICS",style: sedanRegular.copyWith(fontSize: Dimensions.fontSizeTwentyFour,color: AppColor.neviBlue,fontWeight: FontWeight.bold),),
              SizedBox(height: 5,),
              Text("Drive Excellence",style: quicksandSemibold.copyWith(fontSize: Dimensions.fontSizeFourteen,color: AppColor.primaryRed,fontStyle: FontStyle.italic),),
            ],
          ),
        ),
      ),
    );
  }
}
