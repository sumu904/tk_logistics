import 'package:get/get.dart';
import 'package:tk_logistics/routes/routes_name.dart';

import '../features/auth/login/login_screen.dart';
import '../features/screens/home/challan/screen/challan_screen.dart';
import '../features/screens/home/create_trip/create_trip_screen.dart';
import '../features/screens/home/create_trip/pod/screen/proof_of_delivery_screen.dart';
import '../features/screens/home/create_trip/3ms/quotation/screen/quotation_screen.dart';
import '../features/screens/home/dashboard/billing_unit_report/screen/billing_unit_report.dart';
import '../features/screens/home/dashboard/dashboard_screen.dart';
import '../features/screens/home/dashboard/fuel_consumption_report/screen/fuel_consumption_report.dart';
import '../features/screens/home/dashboard/trip_type_report/screen/trip_type_report.dart';
import '../features/screens/home/fuel_entry/screen/fuel_entry_list.dart';
import '../features/screens/home/trip_history/screen/trip_history_screen.dart';
import '../features/screens/home/home_screen.dart';
import '../features/screens/home/trip_history/update trip/3ms/screen/update_3ms_trip.dart';
import '../features/screens/home/trip_history/update trip/tms/screen/update_tms_trip.dart';
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
      name: RoutesName.dashboardScreen,
      page: () =>  DashboardScreen(),
    ),

    GetPage(
      name: RoutesName.billingUnitReport,
      page: () =>  BillingUnitReport(),
    ),

    GetPage(
      name: RoutesName.tripTypeReport,
      page: () =>  TripTypeReport(),
    ),

    GetPage(
      name: RoutesName.fuelConsumptionReport,
      page: () =>  FuelConsumptionReport(),
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

    GetPage(
      name: RoutesName.fuelEntryList,
      page: () =>  FuelEntryList(),
    ),

    GetPage(
      name: RoutesName.updateTmsTrip,
      page: () =>  UpdateTmsTrip(),
    ),

    GetPage(
      name: RoutesName.update3msTrip,
      page: () =>  Update3msTrip(),
    ),

    GetPage(
      name: RoutesName.challanScreen,
      page: () => ChallanScreen(tripNo: Get.arguments as String), //  Pass via Get.arguments
    ),
  ];
}