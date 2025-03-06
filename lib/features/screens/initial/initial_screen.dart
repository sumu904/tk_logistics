import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../util/app_color.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      body: Column(
        children: [
          Stack(
            children: [Container(
              height: size.height * 0.6,
              width: double.infinity,
              child: const ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                child: Image(
                  image: AssetImage("assets/images/tk_logistics.png"),
                  fit: BoxFit.fill,

                ),
              ),
            ),
              Positioned(
                  right: 15,
                  top: 30,
                  child: Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("assets/images/logo.png"),
                  )
                ],
              ))
          ]),
          const SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeFifteen),
            child: Text(
              "Your logistics partner for seamless delivery.",
              style: quicksandBold.copyWith(fontSize: Dimensions.fontSizeTwenty),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomButton(
              text: "Login",
              height: 40,
              width: double.infinity,
              color: AppColor.neviBlue,
              onTap: () {
                Get.toNamed("LoginScreen"); // Using named routes
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
