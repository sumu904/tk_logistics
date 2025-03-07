import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/routes/routes.dart';

import 'features/auth/login/controller/user_controller.dart';
import 'features/screens/home/create_trip/tms/controller/tms_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(UserController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
        initialRoute: '/',
      getPages: AppRoutes.appRoutes(),
    );

  }
}
