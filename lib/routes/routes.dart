import 'package:get/get.dart';
import 'package:tk_logistics/routes/routes_name.dart';

import '../features/auth/login/login_screen.dart';
import '../features/screens/home/create_trip/create_trip_screen.dart';
import '../features/screens/home/create_trip/pod/screen/proof_of_delivery_screen.dart';
import '../features/screens/home/create_trip/3ms/quotation/screen/quotation_screen.dart';
import '../features/screens/home/trip_history/screen/trip_history_screen.dart';
import '../features/screens/home/home_screen.dart';
import '../features/screens/initial/initial_screen.dart';
import '../features/screens/splash/splash_screen.dart';



class AppRoutes {
  static appRoutes() => [

    GetPage(
      name: RoutesName.splashScreen,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: RoutesName.initialScreen,
      page: () => const InitialScreen(),
    ),

    GetPage(
      name: RoutesName.loginScreen,
      page: () =>  LoginScreen(),
    ),

    GetPage(
     name: RoutesName.homeScreen,
     page: () =>  HomeScreen(),
    ),


    GetPage(
      name: RoutesName.createTripScreen,
      page: () =>  CreateTripScreen(),
    ),

    GetPage(
      name: RoutesName.quotationScreen,
      page: () =>  QuotationScreen(),
    ),

    GetPage(
      name: RoutesName.tripHistoryScreen,
      page: () =>  TripHistoryScreen(),
    ),

    GetPage(
      name: RoutesName.proofOfDeliveryScreen,
      page: () =>  ProofOfDeliveryScreen(),
    ),

    /*GetPage(
      name: RoutesName.registrationPage,
      page: () =>  RegistrationPage(),
    ),

    GetPage(
        name: RoutesName.loginPage,
        page: () =>  LoginPage(),
    ),

    GetPage(
      name: RoutesName.homePage,
      page: () =>  HomePage(),
    ),*/

    /*GetPage(
      name: RoutesName.applicationVerificationScreen,
      page: () => const ApplicationVerificationScreen(),
    ),*/

  ];
}