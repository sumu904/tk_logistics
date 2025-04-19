import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../const/const_values.dart';
import '../../../../auth/login/controller/user_controller.dart';

class EntryListController extends GetxController {
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final vehicleController = TextEditingController();

  final userController = Get.find<UserController>();
  RxnString selectedVehicle = RxnString();
  RxList<String> vehicleID = <String>[].obs;
  RxList<Map<String, dynamic>> vehicleData = <Map<String, dynamic>>[].obs;
  Rxn<DateTime> selectedFromDate = Rxn<DateTime>();
  Rxn<DateTime> selectedToDate = Rxn<DateTime>();
  RxList<Map<String, dynamic>> filteredEntries = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVehicleNumbers();
  }

  Future<void> fetchVehicleNumbers() async {
    String apiUrl = "${baseUrl}/vehicle_list";
    print("Fetching vehicle numbers from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded JSON: $data");

        if (data.containsKey('results') && data['results'] is List) {
          vehicleData.assignAll(List<Map<String, dynamic>>.from(data['results']));

          // Add "All Vehicle" to the list of vehicle codes
          vehicleID.assignAll(["All Vehicle", ...vehicleData.map((item) => item['xvehicle'].toString()).toList()]);

          print("Fetched Vehicle Numbers: $vehicleID");
        } else {
          print("Unexpected API Response Format for vehicle numbers");
        }
      } else {
        print("Failed to fetch vehicle numbers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching vehicle numbers: $e");
    }
  }


  void filterEntries() async {
    if (selectedFromDate.value == null || selectedToDate.value == null || selectedVehicle.value == null) {
      print("Please select From Date, To Date, and Vehicle.");
      return;
    }

    final fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate.value!);
    final toDate = DateFormat('yyyy-MM-dd').format(selectedToDate.value!);
    final zemail =  userController.user.value?.username;

    //  Check if not "All Vehicle"
    final isAllVehicle = selectedVehicle.value == "All Vehicle";

    //  Construct API URL conditionally
    final apiUrl = isAllVehicle
        ? "http://103.250.68.75/api/v1/Maintenance_list?fromDate=$fromDate&toDate=$toDate&zemail=$zemail"
        : "http://103.250.68.75/api/v1/Maintenance_list?fromDate=$fromDate&toDate=$toDate&zemail=$zemail&vehicle_code=${selectedVehicle.value}";

    print("Fetching maintenance list from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] is List) {
          final results = List<Map<String, dynamic>>.from(data['results']);
          filteredEntries.value = results.map((item) {
            return {
              "Date": item["xdate"] ?? "",
              "Vehicle Code": item["vehicle_code"] ?? "",
              "Vehicle Number": item["vehicle_number"] ?? "",
              "Driver Name": item["driver_name"] ?? "",
              "Workshop Type": item["workshop_type"] ?? "",
              "Workshop Name": item["workshop_name"] ?? "",
              "Total Cost": item["total_cost"] ?? "0.00",
              "Maintenance No": item["maintenance_no"] ?? "",
              "Maintenance Type": item["maintenance_type"] ?? "N/A",
              "Cost": item["cost"] ?? item["total_cost"] ?? "0.00",
            };
          }).toList();
        } else {
          filteredEntries.clear();
          print("No data found.");
        }
      } else {
        print("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching maintenance list: $e");
    }
    clearFields();
  }
  void clearFields() {
    selectedVehicle.value = null;
    selectedFromDate.value = null;
    selectedToDate.value = null;

    fromDateController.clear();
    toDateController.clear();
    vehicleController.clear();
  }
}
