import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../const/const_values.dart';
import '../../../../auth/login/controller/user_controller.dart';

class TripHistoryController extends GetxController {
  final userController = Get.find<UserController>();
  var selectedDate = DateTime.now().obs; // Observable for selected date
  final DateFormat formatter = DateFormat('yyyy-MM-dd'); // Format date
  var filteredTrips = <Trip>[].obs;
  var selectedOption = 'TMS'.obs; // Default value
  var zemail =  ''.obs;

  @override
  void onInit() {
    super.onInit();
    zemail.value = userController.user.value?.username ?? ''; // Assign inside onInit
  }

  void changeOption(String value) {
    selectedOption.value = value;
    fetchTrips(); // Fetch trips whenever option changes
  }

  void pickDate(DateTime date) {
    selectedDate.value = date;
    fetchTrips(); // Fetch trips whenever date changes
  }

  // Fetch trips from the API
  Future<void> fetchTrips() async {
    try {
      // Format the date as 'yyyy-MM-dd', then append 'T00:00:00' for time
      String formattedDate = formatter.format(selectedDate.value) + 'T00:00:00';


      final response = await http.get(
        Uri.parse('${baseUrl}/Trip_list').replace(
          queryParameters: {
            'xtype': selectedOption.value,
            'xdate': formattedDate, // Include time in the xdate parameter
            'zemail': zemail.value,
          },
        ),
      );

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        // Decode the JSON response to a map
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Print out the response to debug its structure
        print("Response Data: $responseData");

        // Check if the 'data' key exists and contains a list of trips
        if (responseData.containsKey('results')) {
          print('Found "results" key in response');

          var data = responseData['results'];
          // Print the type of 'data' to check if it's a List
          print('Type of results: ${data.runtimeType}');

          if (data is List) {
            // Directly assign fetched data to allTrips
            var allTrips = data.map((tripJson) => Trip.fromJson(tripJson)).toList();
            print("Fetched trip data: $allTrips");

            // Filter the trips based on the selected date
            filterTrips(allTrips); // Filter trips after fetching
          } else {
            print('The "results" key exists but is not a list');
          }
        } else {
          print('No "results" key found in the response');
        }
      } else {
        print('Failed to load trips, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching trips: $e');
    }
  }

  // Function to filter trips based on the selected date
  void filterTrips(List<Trip> allTrips) {
    String selected = formatter.format(selectedDate.value); // Format selected date to 'yyyy-MM-dd'

    // Filter trips by comparing the formatted trip date with the selected date
    filteredTrips.value = allTrips.where((trip) {
      // Format the trip's date to 'yyyy-MM-dd' to ignore the time part
      String tripDate = formatter.format(DateTime.parse(trip.date));
      return tripDate == selected; // Compare only the date part
    }).toList();
  }


}

class Trip {
  final String tripNo;
  final String vehicleID;
  final String vehicleNo;
  final String driverName;
  final String driverPhone;
  final String ? pickVendor;
  final String date;
  final String from;
  final String to;
  final String billingUnit;
  final String status;
  final String email;
  final String tripType;

  Trip({
    required this.tripNo,
    required this.vehicleID,
    required this.vehicleNo,
    required this.driverName,
    required this.driverPhone,
    required this.pickVendor,
    required this.date,
    required this.from,
    required this.to,
    required this.billingUnit,
    required this.status,
    required this.email,
    required this.tripType,
  });

  // Convert Trip object to a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      "xtype": tripType,
      "xsornum": tripNo,
      "xvehicle": vehicleID,
      "xvmregno": vehicleNo,
      "xdriver": driverName,
      "xmobile": driverPhone,
      "xsup":pickVendor,
      "xdate": date,
      "xsdestin": from,
      "xdestin": to,
      "xproj": billingUnit,
      "xstatusmove": status,
      "zemail": email,
    };
  }


  // Convert Map<String, dynamic> to Trip object
  factory Trip.fromJson(Map<String, dynamic> json, {String tripType = '3MS'}) {
    print("Received tripType: $tripType");
    return Trip(
      tripNo: (json['xsornum'] ?? 'Unknown').toString(),
      vehicleID: (json['xvehicle'] ?? 'Unknown').toString(),
      vehicleNo: tripType == '3MS' ? (json['xvmregno'] ?? '').toString() : '',
      driverName: (json['xdriver'] ?? 'Unknown').toString(),
      driverPhone: (json['xmobile'] ?? 'Unknown').toString(),
      pickVendor: tripType == '3MS' ? (json['xsup'] ?? 'Unknown').toString() : '',// Show vendor in 3MS only
      date: (json['xdate'] ?? 'Unknown').toString(),
      from: (json['xsdestin'] ?? 'Unknown').toString(),
      to: (json['xdestin'] ?? 'Unknown').toString(),
      billingUnit: (json['xproj'] ?? 'Unknown').toString(),
      status: (json['xstatusmove'] ?? 'Unknown').toString(),
      email: (json['zemail'] ?? 'Unknown').toString(),
      tripType: (json['xtype'] ?? 'Unknown').toString(),
    );
  }


  @override
  String toString() {
    return 'Trip(tripNo: $tripNo, vehicleID: $vehicleID, date: $date, from: $from, to: $to, billingUnit: $billingUnit, status: $status)';
  }
}